import XCTest
@testable import SolanaSwift

class TokensRepositoryPerformanceTests: XCTestCase {
    func testGetPerformance() async throws {
        let source = TestableSolanaTokenListSource()
        let storage = TestableSolanaTokenListStorage()

        let service = SolanaTokenListRepository(
            tokenListSource: source,
            storage: storage
        )

        var records: [String: TokenMetadata] = [:]

        for _ in 0 ... 20000 {
            let uuid = UUID().uuidString

            records[uuid] = TokenMetadata(
                tags: nil,
                chainId: 0,
                mintAddress: uuid,
                symbol: String(uuid.prefix(3)),
                name: String(uuid.prefix(3)),
                decimals: 1,
                logoURI: nil,
                extensions: nil
            )
        }

        await service.updateRecords(records)

        measure {
            let exp = expectation(description: "Finished")

            Task { [records] in
                _ = try await service.get(address: Array(records.values)[10000].mintAddress)

                exp.fulfill()
            }

            wait(for: [exp], timeout: 200.0)
        }
    }
}
