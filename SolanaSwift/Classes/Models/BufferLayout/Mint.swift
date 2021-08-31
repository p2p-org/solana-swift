//
//  MintLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation
import Runtime

extension SolanaSDK {
    public struct Mint: DecodableBufferLayout, Equatable, Hashable, Encodable {
        public let mintAuthorityOption: UInt32
        public private(set) var mintAuthority: PublicKey?
        public let supply: UInt64
        public let decimals: UInt8
        public let isInitialized: Bool
        public let freezeAuthorityOption: UInt32
        public private(set) var freezeAuthority: PublicKey?
        
        public static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout SolanaSDK.Mint) throws {
            if currentInstance.mintAuthorityOption == 0 {
                currentInstance.mintAuthority = nil
            }
            if currentInstance.freezeAuthorityOption == 0 {
                currentInstance.freezeAuthority = nil
            }
        }
        
        public static var BUFFER_LENGTH: Int { 82 }
        
        public static var span: UInt64 { UInt64(BUFFER_LENGTH) }
    }
}
