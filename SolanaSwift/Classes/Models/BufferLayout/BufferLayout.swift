//
//  BufferLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation

public protocol BufferLayout: Codable {
    init?(_ keys: [String: [UInt8]])
    static func layout() -> [(key: String?, length: Int)]
}

extension BufferLayout {
    static var BUFFER_LENGTH: Int {
        layout().reduce(0, {$0 + ($1.key != nil ? $1.length: 0)})
    }
}

public struct Buffer<T: BufferLayout>: Codable {
    let value: T?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // decode parsedJSON
        do {
            let parsedData = try container.decode(T.self)
            value = parsedData
            return
        } catch {
            Logger.log(message: "Unable to get parsed data, fallback to decoding base64, error: \(error)", event: .info, apiMethod: "getProgramAccounts")
        }
        
        // decode base64 data
        let strings = try container.decode([String].self)
        guard let string = strings.first, let data = Data(base64Encoded: string)?.bytes,
              data.count >= T.BUFFER_LENGTH
        else {
            value = T([:])
            return
        }
        
        var dict = [String: [UInt8]]()
        
        let layout = T.layout()
        for i in 0..<layout.count {
            if layout[i].key == nil {continue}
            var from: Int = 0
            if i > 0 {
                from = layout[i-1].length
            }
            let to: Int = from + layout[i].length
            let bytes = Array(data[from..<to])
            dict[layout[i].key!] = bytes
        }
        value = T(dict)
    }
}
