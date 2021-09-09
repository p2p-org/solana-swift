//
//  RenVM+SolanaChain.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import BufferLayoutSwift

extension RenVM {
    public struct SolanaChain {
        
    }
}

extension RenVM.SolanaChain {
    public struct GatewayRegistryData: BufferLayout {
        let isInitialized: Bool
        let owner: SolanaSDK.PublicKey
        let count: UInt64
        let selectors: [SolanaSDK.PublicKey]
        let gateways: [SolanaSDK.PublicKey]
        
        public init(buffer: Data, pointer: inout Int) throws {
            self.isInitialized = try Bool(buffer: buffer, pointer: &pointer)
            self.owner = try .init(buffer: buffer, pointer: &pointer)
            self.count = try UInt64(buffer: buffer, pointer: &pointer)
            
            // selectors
            let selectorsSize = try UInt32(buffer: buffer, pointer: &pointer)
            var selectors = [SolanaSDK.PublicKey]()
            for _ in 0..<selectorsSize {
                selectors.append(try .init(buffer: buffer, pointer: &pointer))
            }
            self.selectors = selectors
            
            // gateways:
            let gatewaysSize = try UInt32(buffer: buffer, pointer: &pointer)
            var gateways = [SolanaSDK.PublicKey]()
            for _ in 0..<gatewaysSize {
                gateways.append(try .init(buffer: buffer, pointer: &pointer))
            }
            self.gateways = gateways
        }
    }
}
