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
            destinationAddress: SolanaSDK.PublicKey
        ) {
            self.network = network
            self.provider = provider
            self.chain = chain
            self.session = Session(destinationAddress: destinationAddress.base58EncodedString)
        }
        
        func generateGatewayAddress() throws -> Single<String> {
            let sendTo = try chain.getAssociatedTokenAddress(address: session.destinationAddress)
            state.sendTo = sendTo
            let sendToHex = Data(hex: sendTo).hexString
            let tokenGatewayContractHex = Hash.generateSHash().hexString
            let gHash = Hash.generateGHash(to: sendToHex, tokenIdentifier: tokenGatewayContractHex, nonce: Data(hex: session.nonce).bytes)
            state.gHash = gHash
            
            return provider.selectPublicKey()
                .observe(on: CurrentThreadScheduler.instance)
                .map {[weak self] gPubkey in
                    guard let self = self else {throw Error.unknown}
                    guard let gPubkey = gPubkey, let data = Data(base64Encoded: gPubkey)
                    else {throw Error("Provider's public key not found")}
                    
                    self.state.gPubKey = gPubkey
                    
                    let gatewayAddress = Script.createAddressByteArray(
                        gGubKeyHash: data.hash160,
                        gHash: gHash,
                        prefix: Data([UInt8(self.network.p2shPrefix)])
                    )
                    self.session.gatewayAddress = Base58.encode(gatewayAddress.bytes)
                    return self.session.gatewayAddress
                }
        }
    }
}

extension RenVM.LockAndMint {
    public struct State {
        public var gHash: Data?
        public var gPubKey: String?
        public var sendTo: String?
        public var txid: Data?
        public var nHash: Data?
        public var pHash: Data?
        public var txHash: String?
        public var txIndex: String?
        public var amount: String?
    }
    
    public struct Session {
        init(
            destinationAddress: String,
            nonce: String? = nil,
            sessionDay: Long = Long(Date().timeIntervalSince1970 / 1000 / 60 / 60 / 24),
            expiryTimeInDays: Long = 3,
            gatewayAddress: String = ""
        ) {
            self.destinationAddress = destinationAddress
            self.nonce = nonce ?? generateNonce(sessionDay: sessionDay)
            self.createdAt = sessionDay
            self.expiryTime = (sessionDay + 3) * 60 * 60 * 24 * 1000
            self.gatewayAddress = gatewayAddress
        }
        
        public private(set) var destinationAddress: String
        public private(set) var nonce: String
        public private(set) var createdAt: Long
        public private(set) var expiryTime: Long
        public internal(set) var gatewayAddress: String
        
    }
}

private func generateNonce(sessionDay: Long) -> String {
    let string = String(repeating: " ", count: 28) + sessionDay.hexString
    let data = string.getBytes() ?? Data()
    return data.hexString
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
