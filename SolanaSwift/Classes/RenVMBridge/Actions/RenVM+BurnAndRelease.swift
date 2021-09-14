//
//  RenVM+BurnAndRelease.swift
//  SolanaSwift
//
//  Created by Chung Tran on 14/09/2021.
//

import Foundation
import RxSwift

extension RenVM {
    public class BurnAndRelease {
        // MARK: - Dependencies
        let rpcClient: RenVMRpcClientType
        let chain: RenVMChainType
        let mintTokenSymbol: String
        let version: String
        let burnToChainName: String // Ex.: Bitcoin
        
        // MARK: - State
        var state = State()
        var nonceBuffer = Data()
        var recipient: String?
        
        // MARK: - Initializer
        init(
            rpcClient: RenVMRpcClientType,
            chain: RenVMChainType,
            mintTokenSymbol: String,
            version: String,
            burnTo: String
        ) {
            self.rpcClient = rpcClient
            self.chain = chain
            self.mintTokenSymbol = mintTokenSymbol
            self.version = version
            self.burnToChainName = burnTo
        }
        
        func submitBurnTransaction(
            account: Data,
            amount: String,
            recipient: String,
            signer: Data
        ) -> Single<BurnDetails> {
            self.recipient = recipient
            return chain.submitBurn(
                mintTokenSymbol: mintTokenSymbol,
                account: account,
                amount: amount,
                recipient: recipient,
                signer: signer
            )
        }
        
        func getBurnState(
            burnDetails: BurnDetails,
            amount: String
        ) throws -> State {
            let txid = try chain.signatureToData(signature: burnDetails.confirmedSignature)
            nonceBuffer = getNonceBuffer(nonce: burnDetails.nonce)
            let nHash = Hash.generateNHash(nonce: nonceBuffer.bytes, txId: txid.bytes, txIndex: 0)
            let pHash = Hash.generatePHash()
            let sHash = Hash.generateSHash(selector: .init(mintTokenSymbol: mintTokenSymbol, chainName: burnToChainName, direction: .to)) // "BTC/toBitcoin"
            let gHash = Hash.generateGHash(to: try Self.addressToBytes(address: burnDetails.recipient).hexString, tokenIdentifier: sHash.toHexString(), nonce: nonceBuffer.bytes)
            
            let mintTx = MintTransactionInput(gHash: gHash, gPubkey: Data(), nHash: nHash, nonce: nonceBuffer, amount: amount, pHash: pHash, to: burnDetails.recipient, txIndex: "0", txid: txid)
            
            let txHash = try mintTx.hash(selector: chain.selector(mintTokenSymbol: mintTokenSymbol, direction: .from), version: version)
                .base64urlEncodedString()
            
            state.txIndex = "0"
            state.amount = amount
            state.nHash = nHash
            state.txid = txid
            state.pHash = pHash
            state.gHash = gHash
            state.txHash = txHash
            state.gPubKey = Data()
            return state
        }
        
        func release() -> Single<String> {
            let selector = selector(direction: .from)
            
            // get input
            let mintTx: MintTransactionInput
            let hash: String
            do {
                mintTx = try MintTransactionInput(state: state, chain: chain, nonce: nonceBuffer)
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
        
        private func getNonceBuffer(nonce: BInt) -> Data {
            var data = Data(repeating: 0, count: 32-nonce.data.count)
            data += nonce.data
            return data
        }
        
        private func selector(direction: Selector.Direction) -> Selector {
            chain.selector(mintTokenSymbol: mintTokenSymbol, direction: direction)
        }
        
        static func addressToBytes(address: String) throws -> Data {
            let bech32 = try Bech32().decode(address).checksum
            let type = bech32[0]
            let words = Data(bech32[1...])
            let fromWords = try convert(data: words, inBits: 5, outBits: 8, pad: false)
            var data = Data()
            data += [type]
            data += fromWords
            return data
        }
        
    }
}

private func convert(
    data: Data,
    inBits: UInt8,
    outBits: UInt8,
    pad: Bool
) throws -> Data {
    var value: UInt8 = 0
    var bits: UInt8 = 0
    let maxV: UInt8 = (1 << outBits) - 1
    
    var data = Data()
    
    for i in 0..<data.count {
        value = (value << inBits) | data[i]
        bits += inBits
        
        while bits >= outBits {
            bits -= outBits
            data.append(UInt8(value >> bits & maxV))
        }
    }
    if pad {
        if bits > 0 {
            data.append(UInt8((value << (outBits - bits)) & maxV))
        }
    } else {
        if bits >= inBits {throw RenVM.Error("Excess padding")}
    }
    return data
}
