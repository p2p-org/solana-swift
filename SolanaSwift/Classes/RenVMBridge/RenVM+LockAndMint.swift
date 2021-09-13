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
    public class LockAndMint {
        let network: Network
        let provider: RenVMProviderType
        var session: Session
        let chain: RenVMChainType
        var state = State()
        
        init(
            network: Network,
            provider: RenVMProviderType,
            chain: RenVMChainType,
            destinationAddress: Data,
            sessionDay: Long
        ) {
            self.network = network
            self.provider = provider
            self.chain = chain
            self.session = Session(destinationAddress: destinationAddress, sessionDay: sessionDay)
        }
        
        func generateGatewayAddress() -> Single<Data> {
            let sendTo: Data
            do {
                sendTo = try chain.getAssociatedTokenAddress(address: session.destinationAddress)
            } catch {
                return .error(error)
            }
            state.sendTo = sendTo
            let sendToHex = sendTo.hexString
            let tokenGatewayContractHex = Hash.generateSHash().hexString
            let gHash = Hash.generateGHash(to: sendToHex, tokenIdentifier: tokenGatewayContractHex, nonce: Data(hex: session.nonce).bytes)
            state.gHash = gHash
            
            return provider.selectPublicKey()
                .observe(on: CurrentThreadScheduler.instance)
                .map {[weak self] gPubkey in
                    guard let self = self else {throw Error.unknown}
                    guard let gPubkey = gPubkey
                    else {throw Error("Provider's public key not found")}
                    
                    self.state.gPubKey = gPubkey
                    
                    let gatewayAddress = Script.createAddressByteArray(
                        gGubKeyHash: gPubkey.hash160,
                        gHash: gHash,
                        prefix: Data([self.network.p2shPrefix])
                    )
                    self.session.gatewayAddress = gatewayAddress
                    return self.session.gatewayAddress
                }
        }
        
//        func getDepositState(
//            transactionHash: String,
//            txIndex: String,
//            amount: String
//        ) -> Single<State> {
//            let nonce = Data(hex: session.nonce)
//            let txid = Data(hex: reverseHex(src: transactionHash))
//            let nHash = Hash.generateNHash(nonce: nonce.bytes, txId: txid.bytes, txIndex: UInt32(txIndex) ?? 0)
//            let pHash = Hash.generatePHash()
//            
//            
//        }
    }
}

extension RenVM.LockAndMint {
    public struct State {
        public var gHash: Data?
        public var gPubKey: Data?
        public var sendTo: Data? // PublicKey
        public var txid: Data?
        public var nHash: Data?
        public var pHash: Data?
        public var txHash: String?
        public var txIndex: String?
        public var amount: String?
    }
    
    public struct Session {
        init(
            destinationAddress: Data,
            nonce: String? = nil,
            sessionDay: Long = Long(Date().timeIntervalSince1970 / 1000 / 60 / 60 / 24),
            expiryTimeInDays: Long = 3,
            gatewayAddress: Data = Data()
        ) {
            self.destinationAddress = destinationAddress
            self.nonce = nonce ?? generateNonce(sessionDay: sessionDay)
            self.createdAt = sessionDay
            self.expiryTime = (sessionDay + 3) * 60 * 60 * 24 * 1000
            self.gatewayAddress = gatewayAddress
        }
        
        public private(set) var destinationAddress: Data
        public private(set) var nonce: String
        public private(set) var createdAt: Long
        public private(set) var expiryTime: Long
        public internal(set) var gatewayAddress: Data
        
    }
}

private func generateNonce(sessionDay: Long) -> String {
    let string = String(repeating: " ", count: 28) + sessionDay.hexString
    let data = string.getBytes() ?? Data()
    return data.hexString
}

private func reverseHex(src: String) -> String {
    var newStr = Array(src)
    for i in stride(from: 0, to: src.count / 2, by: 2) {
        newStr.swapAt(i, newStr.count - i - 2)
        newStr.swapAt(i + 1, newStr.count - i - 1)
    }
    return String(newStr)
}

private extension Long {
    var hexString: String {
        String(self, radix: 16, uppercase: false)
    }
}

private extension String {
    func getBytes() -> Data? {
        data(using: .utf8)
    }
}
