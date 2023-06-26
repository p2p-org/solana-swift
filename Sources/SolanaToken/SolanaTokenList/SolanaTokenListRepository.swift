import Foundation
import SolanaSwift

public actor SolanaTokenListRepository: TokenRepository {
    // MARK: - Properties

    let tokenListSource: SolanaTokenListSource
    let storage: SolanaTokenListStorage

    // Hash map for address and token.
    var records: [String: TokenMetadata] = [:]

    public init(
        tokenListSource: SolanaTokenListSource,
        storage: SolanaTokenListStorage = InMemorySolanaTokenListStorage()
    ) {
        self.storage = storage
        self.tokenListSource = tokenListSource
    }

    public func get(address: String) async throws -> TokenMetadata? {
        if records.isEmpty {
            try await fill()
        }

        return records[address]
    }

    public func all() async throws -> Set<TokenMetadata> {
        if records.isEmpty {
            try await fill()
        }

        return Set(records.values)
    }

    public func reset() async throws {
        records = [:]
        await storage.save(tokens: nil)
    }

    func fill() async throws {
        // Load from storage
        if let storageData = await storage.getTokens(), !storageData.isEmpty {
            records = Dictionary(storageData.map { ($0.address, $0) }, uniquingKeysWith: { lhs, _ in lhs })
            return
        }

        // Load from source
        let sourceData = try await tokenListSource.download()
        records = Dictionary(sourceData.map { ($0.address, $0) }, uniquingKeysWith: { lhs, _ in lhs })
        await storage.save(tokens: sourceData)
    }
}
