import Foundation

public protocol TokenRepository {
    /// Get specific token.
    func get(address: String) async throws -> TokenMetadata?

    func get(addresses: [String]) async throws -> [String: TokenMetadata]

    /// Get all tokens
    func all() async throws -> [String: TokenMetadata]

    /// Prepare function
    func setup() async throws

    /// Get preloaded token
    @available(*, deprecated, message: "This method is used for backward support legacy code.")
    func get(preloaded: String) -> TokenMetadata

    /// Method to reset service
    func reset() async throws
}

public extension TokenRepository {
    func get(address: PublicKey) async throws -> TokenMetadata? {
        try await get(address: address.base58EncodedString)
    }
}
