//
//  RenVM+Error.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation

extension RenVM {
    struct Error: Swift.Error {
        let message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        static var unknown: Self {
            .init("Unknown")
        }
        
        static var paramsMissing: Self {
            .init("One or some parameters are missing")
        }
    }
}
