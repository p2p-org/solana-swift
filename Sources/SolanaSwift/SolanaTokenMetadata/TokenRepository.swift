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
}
