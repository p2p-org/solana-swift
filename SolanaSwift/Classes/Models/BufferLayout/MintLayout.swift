//
//  MintLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation

extension SolanaSDK {
    public struct MintLayout: BufferLayout {
        let decimal: UInt8
        public init?(_ keys: [String: [UInt8]]) {
            guard let bytes = keys["decimals"], bytes.count == 1 else {return nil}
            decimal = bytes.first!
        }
        
        public static func layout()  -> [(key: String?, length: Int)] {
            [
                (key: nil, length: 44),
                (key: "decimals", length: 1),
                (key: nil, length: 37)
            ]
        }
    }
}
