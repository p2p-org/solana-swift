//
//  AccountInfo2.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/08/2021.
//

import Foundation
import BufferLayoutSwift
import Runtime

extension SolanaSDK.PublicKey: BufferLayoutProperty {
    public static func fromBytes(bytes: [UInt8]) throws -> SolanaSDK.PublicKey {
        try .init(bytes: bytes)
    }
}

extension SolanaSDK {
    public struct AccountInfo2: BufferLayout {
        public let mint: PublicKey
        public let owner: PublicKey
        public let lamports: UInt64
        public let delegateOption: UInt32
        public var delegate: PublicKey?
        public let state: UInt8
        public let isNativeOption: UInt32
        public let isNativeRaw: UInt64
        public var delegatedAmount: UInt64
        public let closeAuthorityOption: UInt32
        public var closeAuthority: PublicKey?
        
        // non-parsing
        public var isInitialized: Bool {
            state != 0
        }
        public var isFrozen: Bool {
            state == 2
        }
        
        public var rentExemptReserve: UInt64? {
            if isNativeOption == 1 {
                return isNativeRaw
            }
            return nil
        }
        
        public var isNative: Bool {
            isNativeOption == 1
        }
        
        public static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout SolanaSDK.AccountInfo2) throws {
            if currentInstance.delegateOption == 0 {
                currentInstance.delegate = nil
                currentInstance.delegatedAmount = 0
            }
            
            if currentInstance.closeAuthorityOption == 0 {
                currentInstance.closeAuthority = nil
            }
        }
    }
}
