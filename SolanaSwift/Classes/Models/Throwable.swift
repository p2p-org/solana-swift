//
//  Throwable.swift
//  SolanaSwift
//
//  Created by Chung Tran on 06/08/2021.
//

import Foundation

public struct Throwable<T: Decodable>: Decodable {
    
    public let result: Result<T, Error>

    public init(from decoder: Decoder) throws {
        let catching = { try T(from: decoder) }
        result = Result(catching: catching )
    }
}
