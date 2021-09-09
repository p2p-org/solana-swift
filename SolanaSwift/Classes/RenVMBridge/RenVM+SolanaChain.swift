//
//  RenVM+SolanaChain.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import RxSwift

extension RenVM {
    public struct SolanaChain {
        // MARK: - Constants
        static let gatewayRegistryStateKey  = "GatewayRegistryState"
        static let gatewayStateKey          = "GatewayStateV0.1.4"
        
        // MARK: - Properties
        let gatewayRegistryData: GatewayRegistryData
        let client: RenVMRpcClientType
        
        // MARK: - Methods
        public static func load(
            client: RenVMRpcClientType,
            network: Network
        ) -> Single<Self> {
            do {
                let pubkey = try SolanaSDK.PublicKey(string: network.gatewayRegistry)
                let stateKey = try SolanaSDK.PublicKey.findProgramAddress(
                    seeds: [Self.gatewayRegistryStateKey.data(using: .utf8)!],
                    programId: pubkey
                )
                return client.getAccountInfo(
                    account: stateKey.0.base58EncodedString,
                    decodedTo: GatewayRegistryData.self
                )
                .map {$0.data}
                .map {.init(gatewayRegistryData: $0, client: client)}
            } catch {
                return .error(error)
            }
        }
        
        public func resolveTokenGatewayContract() throws {
            let sHash = Base58.encode(Hash)
        }
    }
}

extension RenVM.SolanaChain {
    public struct GatewayRegistryData: DecodableBufferLayout {
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
        
        public func serialize() throws -> Data {
            var data = Data()
            data += try isInitialized.serialize()
            data += try owner.serialize()
            data += try count.serialize()
            data += try (UInt32(selectors.count)).serialize()
            data += try selectors.reduce(Data(), {$0 + (try $1.serialize())})
            data += try (UInt32(gateways.count)).serialize()
            data += try gateways.reduce(Data(), {$0 + (try $1.serialize())})
            return data
        }
    }
}
