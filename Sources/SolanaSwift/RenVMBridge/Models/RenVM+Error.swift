//
//  RenVM+Error.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation

extension RenVM {
    public struct Error: Swift.Error, Equatable {
        public let message: String
        
        public init(_ message: String) {
            self.message = message
        }
        
        public static var unknown: Self {
            .init("Unknown")
        }
        
        public static var paramsMissing: Self {
            .init("One or some parameters are missing")
        }
    }
}
