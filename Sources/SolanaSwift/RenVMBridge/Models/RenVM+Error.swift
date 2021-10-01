//
//  RenVM+Error.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation

extension RenVM {
    public struct Error: Swift.Error, Equatable, Decodable {
        public let message: String
        public let code: Int?
        
        public init(_ message: String) {
            self.message = message
            self.code = nil
        }
        
        public static var unknown: Self {
            .init("Unknown")
        }
        
        public static var paramsMissing: Self {
            .init("One or some parameters are missing")
        }
    }
}
