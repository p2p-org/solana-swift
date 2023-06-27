import Foundation

public protocol TokenRepository {
    /// Get specific token.
    func get(address: String) async throws -> TokenMetadata?

    /// Get all tokens
    func all() async throws -> Set<TokenMetadata>

    /// Method to reset service
    func reset() async throws
}

public extension TokenRepository {
    func get(address: PublicKey) async throws -> TokenMetadata? {
        try await get(address: address.base58EncodedString)
    }

    func safeGet(address: String?) async throws -> TokenMetadata {
        if let address {
            return try await get(address: address)
                ?? .unsupported(mint: address, decimals: 1, symbol: "", supply: nil)
        } else {
            return .unsupported(mint: "", decimals: 1, symbol: "", supply: nil)
        }
    }

    func safeGet(address: PublicKey?) async throws -> TokenMetadata {
        if let address {
            return try await safeGet(address: address.base58EncodedString)
        } else {
            return .unsupported(mint: "", decimals: 1, symbol: "", supply: nil)
        }
    }
}
