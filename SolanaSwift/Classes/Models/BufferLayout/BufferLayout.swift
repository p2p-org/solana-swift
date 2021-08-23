//
//  BufferLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation
import BufferLayoutSwift

extension SolanaSDK.PublicKey: BufferLayoutProperty {
    public static func getNumberOfBytes() throws -> Int {
        numberOfBytes
    }
    
    public init(buffer: Data) throws {
        try self.init(data: buffer)
    }
    public func encode() throws -> Data {
        Data(bytes)
    }
}

public protocol DecodableBufferLayout: BufferLayout, Decodable {}

public protocol EncodableBufferLayout: BufferLayout, Encodable {}

public typealias CodableBufferLayout = DecodableBufferLayout & EncodableBufferLayout

public extension DecodableBufferLayout {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Unable to get parsed data, fallback to decoding base64
        let stringData = (try? container.decode([String].self).first) ?? (try? container.decode(String.self))
        guard let string = stringData,
              !string.isEmpty,
              let data = Data(base64Encoded: string)
        else {
            throw SolanaSDK.Error.couldNotRetrieveAccountInfo
        }
        
        do {
            try self.init(buffer: data)
        } catch {
            throw SolanaSDK.Error.couldNotRetrieveAccountInfo
        }
    }
    
    static var BUFFER_LENGTH: Int {
        guard let length = try? Self.getBufferLength() else {return 0}
        return length
    }
    
    static var span: UInt64 {
        UInt64(BUFFER_LENGTH)
    }
}

