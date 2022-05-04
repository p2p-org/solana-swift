//
//  BufferLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation
import BufferLayoutSwift

extension PublicKey: BufferLayoutProperty {
    public init(buffer: Data, pointer: inout Int) throws {
        guard buffer.bytes.count > pointer else {throw BufferLayoutSwift.Error.bytesLengthIsNotValid}
        try self.init(data: buffer[pointer..<pointer+Self.numberOfBytes])
        pointer += Self.numberOfBytes
    }
    public func serialize() throws -> Data {
        Data(bytes)
    }
}

public protocol DecodableBufferLayout: BufferLayout, Decodable {}

public protocol EncodableBufferLayout: BufferLayout, Encodable {}

public typealias CodableBufferLayout = DecodableBufferLayout & EncodableBufferLayout

extension DecodableBufferLayout {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Unable to get parsed data, fallback to decoding base64
        let stringData = (try? container.decode([String].self).first) ?? (try? container.decode(String.self))
        guard let string = stringData,
              let data = Data(base64Encoded: string)
        else {
            throw SolanaError.couldNotRetrieveAccountInfo
        }
        
        if string.isEmpty && !(Self.self == EmptyInfo.self) {
            throw SolanaError.couldNotRetrieveAccountInfo
        }
        
        do {
            var pointer = 0
            try self.init(buffer: data, pointer: &pointer)
        } catch {
            throw SolanaError.couldNotRetrieveAccountInfo
        }
    }
}

