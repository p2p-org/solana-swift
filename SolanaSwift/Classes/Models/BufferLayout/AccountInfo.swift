//
//  AccountLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation

extension SolanaSDK {
    public struct AccountInfo: BufferLayout {
        let mint: PublicKey
        let owner: PublicKey
        let amount: UInt64
        let delegateOption: UInt32
        var delegate: PublicKey?
        let isInitialized: Bool
        let isFrozen: Bool
        let state: UInt8
        let isNativeOption: UInt32
        let rentExemptReserve: UInt64?
        let isNativeRaw: UInt64
        let isNative: Bool
        var delegatedAmount: UInt64
        let closeAuthorityOption: UInt32
        var closeAuthority: PublicKey?
        
        public init?(_ keys: [String : [UInt8]]) {
            guard let mint = try? PublicKey(bytes: keys["mint"]),
                  let owner = try? PublicKey(bytes: keys["owner"]),
                  let amount = keys["amount"]?.toUInt64(),
                  let delegateOption = keys["delegateOption"]?.toUInt32(),
                  let delegate = try? PublicKey(bytes: keys["delegate"]),
                  let state = keys["state"]?.first,
                  let isNativeOption = keys["isNativeOption"]?.toUInt32(),
                  let isNativeRaw = keys["isNativeRaw"]?.toUInt64(),
                  let delegatedAmount = keys["delegatedAmount"]?.toUInt64(),
                  let closeAuthorityOption = keys["closeAuthorityOption"]?.toUInt32(),
                  let closeAuthority = try? PublicKey(bytes: keys["closeAuthority"])
            else {
                return nil
            }
            
            self.mint = mint
            self.owner = owner
            self.amount = amount
            self.delegateOption = delegateOption
            self.delegate = delegate
            self.state = state
            self.isNativeOption = isNativeOption
            self.isNativeRaw = isNativeRaw
            self.delegatedAmount = delegatedAmount
            self.closeAuthorityOption = closeAuthorityOption
            self.closeAuthority = closeAuthority
            
            if delegateOption == 0 {
                self.delegate = nil
                self.delegatedAmount = 0
            }
            
            self.isInitialized = state != 0
            self.isFrozen = state == 2
            
            if isNativeOption == 1 {
                self.rentExemptReserve = isNativeRaw
                self.isNative = true
            } else {
                self.rentExemptReserve = nil
                isNative = false
            }
            
            if closeAuthorityOption == 0 {
                self.closeAuthority = nil
            }
        }
        
        public static func layout() -> [(key: String?, length: Int)] {
            [
                (key: "mint", length: PublicKey.LENGTH),
                (key: "owner", length: PublicKey.LENGTH),
                (key: "amount", length: 8),
                (key: "delegateOption", length: 4),
                (key: "delegate", length: PublicKey.LENGTH),
                (key: "state", length: 1),
                (key: "isNativeOption", length: 4),
                (key: "isNativeRaw", length: 8),
                (key: "delegatedAmount", length: 8),
                (key: "closeAuthorityOption", length: 4),
                (key: "closeAuthority", length: PublicKey.LENGTH),
            ]
        }
    }
}

