//
//  Account.swift
//  p2p wallet
//
//  Created by Chung Tran on 10/22/20.
//

import Foundation
import TweetNacl
import CryptoSwift

public extension SolanaSDK_Deprecated {
    public typealias Account = SolanaSwift.Account
}

//public extension SolanaSDK_Depricated.Account {
//    struct Meta: Codable, CustomDebugStringConvertible {
//        public let publicKey: SolanaSDK_Depricated.PublicKey
//        public var isSigner: Bool
//        public var isWritable: Bool
//
//        // MARK: - Decodable
//        enum CodingKeys: String, CodingKey {
//            case pubkey, signer, writable
//        }
//
//        public init(from decoder: Decoder) throws {
//            let values = try decoder.container(keyedBy: CodingKeys.self)
//            publicKey = try SolanaSDK_Depricated.PublicKey(string: try values.decode(String.self, forKey: .pubkey))
//            isSigner = try values.decode(Bool.self, forKey: .signer)
//            isWritable = try values.decode(Bool.self, forKey: .writable)
//        }
//
//        public func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(publicKey.base58EncodedString, forKey: .pubkey)
//            try container.encode(isSigner, forKey: .signer)
//            try container.encode(isWritable, forKey: .writable)
//        }
//
//        // Initializers
//        public init(publicKey: SolanaSDK_Depricated.PublicKey, isSigner: Bool, isWritable: Bool) {
//            self.publicKey = publicKey
//            self.isSigner = isSigner
//            self.isWritable = isWritable
//        }
//
//        public static func readonly(publicKey: SolanaSDK_Depricated.PublicKey, isSigner: Bool) -> Self {
//            .init(publicKey: publicKey, isSigner: isSigner, isWritable: false)
//        }
//
//        public static func writable(publicKey: SolanaSDK_Depricated.PublicKey, isSigner: Bool) -> Self {
//            .init(publicKey: publicKey, isSigner: isSigner, isWritable: true)
//        }
//
//        public var debugDescription: String {
//            "{\"publicKey\": \"\(publicKey.base58EncodedString)\", \"isSigner\": \(isSigner), \"isWritable\": \(isWritable)}"
//        }
//    }
//}
