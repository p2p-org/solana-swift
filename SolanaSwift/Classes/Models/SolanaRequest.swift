//
//  SolanaRequest.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

extension SolanaSDK {
    struct EncodableWrapper: Encodable {
        let wrapped: Encodable
        
        func encode(to encoder: Encoder) throws {
            try self.wrapped.encode(to: encoder)
        }
    }

    public struct RequestAPI: Encodable {
        public let id = UUID().uuidString
        public let method: String
        public let jsonrpc: String
        public let params: [Encodable]
        
        enum CodingKeys: String, CodingKey {
            case id
            case method
            case jsonrpc
            case params
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(method, forKey: .method)
            try container.encode(jsonrpc, forKey: .jsonrpc)
            let wrappedDict = params.map(EncodableWrapper.init(wrapped:))
            try container.encode(wrappedDict, forKey: .params)
        }
    }
    
    public struct RequestConfiguration: Encodable {
        public let commitment: Commitment?
        public let encoding: String?
        public let dataSlice: DataSlice?
        
        public init(commitment: Commitment? = nil, encoding: String? = nil, dataSlice: DataSlice? = nil)
        {
            self.commitment = commitment
            self.encoding = encoding
            self.dataSlice = dataSlice
        }
    }
    
    public struct DataSlice: Encodable {
        public let offset: Int
        public let length: Int
    }
}
