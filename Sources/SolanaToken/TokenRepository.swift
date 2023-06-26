//
//  File.swift
//
//
//  Created by Giang Long Tran on 26.06.2023.
//

import Foundation
import SolanaSwift

public protocol TokenRepository {
    /// Get specific token.
    func get(address: String) async throws -> Token?

    /// Get all tokens
    func all() async throws -> Set<Token>

    /// Method to reset service
    func reset() async throws
}
