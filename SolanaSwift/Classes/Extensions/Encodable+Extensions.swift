//
//  Encodable+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 18/08/2021.
//

import Foundation

extension Encodable {
    func toEncodabledString() throws -> String? {
        let data = try JSONEncoder().encode(self)
        return try String(data: data, encoding: .utf8)
    }
}
