//
//  SolanaRequest.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

extension SolanaSDK {
    // MARK: - Private
    struct EncodableWrapper: Encodable {
        let wrapped: Encodable
        
        func encode(to encoder: Encoder) throws {
            try self.wrapped.encode(to: encoder)
        }
    }

    struct RequestAPI: Encodable {
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
    
    // MARK: - Transfer
    public struct Transfer {
        public static func compile() -> Data {
            var result = Data(capacity: 17) // FIXME: - capacity
            result.append(0x2) // program index
            let keyIndeces = [UInt8]([0, 1])
            result.append(Data.encodeLength(UInt(UInt8(keyIndeces.count)))) // key size
            result.append(contentsOf: keyIndeces) // keyIndeces
            result.append(UInt8(12))   // FIXME transfer data size
            var littleEndian = UInt32(2).littleEndian
            result += withUnsafeBytes(of: &littleEndian) { Array($0) }
            
            let lamports = 3000
            var newEdian = lamports.littleEndian
            result += withUnsafeBytes(of: &newEdian) { Array($0) }
            
            return result
        }
    }
    
    // MARK: - Public
    public typealias Commitment = String
    
    public struct RequestConfiguration: Encodable {
        public let commitment: Commitment?
        public let encoding: String?
        public let dataSlice: DataSlice?
        
        public init?(commitment: Commitment? = nil, encoding: String? = nil, dataSlice: DataSlice? = nil)
        {
            if commitment == nil && encoding == nil && dataSlice == nil {
                return nil
            }
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
