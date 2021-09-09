//
//  RenVM+LockAndMint.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation

public typealias Long = Int64

extension RenVM {
    public struct LockAndMint {
        let network: Network
        let provider: RenVMProviderType
        let session: Session
    }
}

extension RenVM.LockAndMint {
    public struct State {
        public let gHash: Data
        public let gPubKey: Data
        public let sendTo: SolanaSDK.PublicKey
        public let txid: Data
        public let nHash: Data
        public let pHash: Data
        public let txHash: String
        public let txIndex: String
        public let amount: String
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
