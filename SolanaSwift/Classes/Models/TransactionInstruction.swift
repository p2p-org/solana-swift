//
//  TransactionInstruction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct TransactionInstruction: Decodable {
        public let keys: [SolanaSDK.Account.Meta]
        public let programId: SolanaSDK.PublicKey
        public let data: [UInt8]
        
        init(keys: [SolanaSDK.Account.Meta], programId: SolanaSDK.PublicKey, data: [BytesEncodable])
        {
            self.keys = keys
            self.programId = programId
            self.data = data.bytes
        }
    }
}
