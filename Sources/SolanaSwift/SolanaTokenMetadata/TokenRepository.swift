import Foundation

public protocol TokenRepository {
    /// Get specific token.
    func get(address: String) async throws -> TokenMetadata?

    func get(addresses: [String]) async throws -> [String: TokenMetadata]

    /// Get all tokens
    func all() async throws -> [String: TokenMetadata]

    /// Prepare function
    func setup() async throws

    /// Method to reset service
    func reset() async throws
}

public extension TokenRepository {
    func get(address: PublicKey) async throws -> TokenMetadata? {
        try await get(address: address.base58EncodedString)
    }
}
