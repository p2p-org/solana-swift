//
//  RenVM+LockAndMint.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import RxSwift

public typealias Long = Int64

extension RenVM {
    public struct LockAndMint {
        public typealias GatewayAddressResponse = (gatewayAddress: Data, sendTo: Data, gHash: Data, gPubkey: Data)
        
        // MARK: - Dependencies
        private let rpcClient: RenVMRpcClientType
        private let chain: RenVMChainType
        private let mintTokenSymbol: String
        private let version: String
        private let destinationAddress: Data
        
        // MARK: - State
        public private(set) var session: Session
        
        // MARK: - Initializer
        /// Create LockAndMint by creating new session or restoring existing session
        public init(
            rpcClient: RenVMRpcClientType,
            chain: RenVMChainType,
            mintTokenSymbol: String,
            version: String,
            destinationAddress: Data,
            session: Session? = nil
        ) throws {
            self.rpcClient = rpcClient
            self.chain = chain
            self.mintTokenSymbol = mintTokenSymbol
            self.version = version
            self.destinationAddress = destinationAddress
            
            if let session = session {
                self.session = session
            } else {
                self.session = try Session()
            }
        }
        
        // MARK: - Methods
        public func generateGatewayAddress() -> Single<GatewayAddressResponse> {
            let sendTo: Data
            do {
                sendTo = try chain.getAssociatedTokenAddress(address: destinationAddress, mintTokenSymbol: mintTokenSymbol)
            } catch {
                return .error(error)
            }
            let sendToHex = sendTo.hexString
            let tokenGatewayContractHex = Hash.generateSHash(
                selector: selector(direction: .to)
            ).hexString
            let gHash = Hash.generateGHash(to: sendToHex, tokenIdentifier: tokenGatewayContractHex, nonce: Data(hex: session.nonce).bytes)
            
            return rpcClient.selectPublicKey(mintTokenSymbol: mintTokenSymbol)
                .observe(on: CurrentThreadScheduler.instance)
                .map { gPubkey in
                    guard let gPubkey = gPubkey
                    else {throw Error("Provider's public key not found")}
                    
                    let gatewayAddress = Script.createAddressByteArray(
                        gGubKeyHash: gPubkey.hash160,
                        gHash: gHash,
                        prefix: Data([self.rpcClient.network.p2shPrefix])
                    )
                    return (gatewayAddress: gatewayAddress, sendTo: sendTo, gHash: gHash, gPubkey: gPubkey)
                }
        }
        
        @discardableResult
        public func getDepositState(
            transactionHash: String,
            txIndex: String,
            amount: String,
            sendTo to: Data,
            gHash: Data,
            gPubkey: Data
        ) throws -> State {
            let nonce = Data(hex: session.nonce)
            let txid = Data(hex: reverseHex(src: transactionHash))
            let nHash = Hash.generateNHash(nonce: nonce.bytes, txId: txid.bytes, txIndex: UInt32(txIndex) ?? 0)
            let pHash = Hash.generatePHash()
            
            let mintTx = MintTransactionInput(
                gHash: gHash,
                gPubkey: gPubkey,
                nHash: nHash,
                nonce: nonce,
                amount: amount,
                pHash: pHash,
                to: try chain.dataToAddress(data: to),
                txIndex: txIndex,
                txid: txid
            )
            
            let txHash = try mintTx
                .hash(selector: selector(direction: .to), version: version)
                .base64urlEncodedString()
            
            let state = State(
                gHash: gHash,
                gPubKey: gPubkey,
                sendTo: try chain.dataToAddress(data: to),
                txid: txid,
                nHash: nHash,
                pHash: pHash,
                txHash: txHash,
                txIndex: txIndex,
                amount: amount
            )
            
            return state
        }
        
        public func submitMintTransaction(state: State) -> Single<String> {
            let selector = selector(direction: .to)
            
            // get input
            let mintTx: MintTransactionInput
            let hash: String
            do {
                mintTx = try MintTransactionInput(state: state, nonce: Data(hex: session.nonce))
                hash = try mintTx
                    .hash(selector: selector, version: version)
                    .base64urlEncodedString()
            } catch {
                return .error(error)
            }
            
            // send transaction
            return rpcClient.submitTx(
                hash: hash,
                selector: selector,
                version: version,
                input: mintTx
            )
                .map {_ in hash}
        }
        
        public func mint(state: State, signer: Data) -> Single<(amountOut: String?, signature: String)> {
            guard let txHash = state.txHash else {
                return .error(Error("txHash not found"))
            }
            var amountOut: String?
            return rpcClient.queryMint(txHash: txHash)
                .map {response in
                    guard response.txStatus == "done" else {
                        throw Error.paramsMissing
                    }
                    amountOut = response.tx.out.v.amount
                    return response
                }
                .flatMap {res in
                    chain.submitMint(
                        address: self.destinationAddress,
                        mintTokenSymbol: self.mintTokenSymbol,
                        signer: signer,
                        responceQueryMint: res
                    )
                }
                .map {(amountOut: amountOut, signature: $0)}
        }
        
        private func selector(direction: Selector.Direction) -> Selector {
            chain.selector(mintTokenSymbol: mintTokenSymbol, direction: direction)
        }
    }
}

private func reverseHex(src: String) -> String {
    var newStr = Array(src)
    for i in stride(from: 0, to: src.count / 2, by: 2) {
        newStr.swapAt(i, newStr.count - i - 2)
        newStr.swapAt(i + 1, newStr.count - i - 1)
    }
    return String(newStr)
}
