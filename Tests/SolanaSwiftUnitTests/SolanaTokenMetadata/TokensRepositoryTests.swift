import XCTest
@testable import SolanaSwift

class TokensRepositoryTests: XCTestCase {
    func testFill_WithStorageData_ShouldLoadFromStorage() async throws {
        let tokens = Set([TokenMetadata.usdc, TokenMetadata.nativeSolana])

        let source = TestableSolanaTokenListSource()
        source.mockTokens = tokens

        let storage = TestableSolanaTokenListStorage()
        storage.mockTokens = tokens

        let service = SolanaTokenListRepository(
            tokenListSource: source,
            storage: storage
        )

        try await service.fill()

        XCTAssertEqual(storage.getTokensCalled, 1)
        XCTAssertEqual(storage.saveTokensCalled, 0)
        XCTAssertEqual(source.downloadCalled, 0)

        let records = await service.records
        XCTAssertEqual(records[TokenMetadata.usdc.address]?.generalTokenExtensions.coingeckoId, "usd-coin")
        XCTAssertEqual(records.count, 2)
        XCTAssertNotNil(records[TokenMetadata.usdc.address])
        XCTAssertNotNil(records[TokenMetadata.nativeSolana.address])
        XCTAssertNil(records[TokenMetadata.usdt.address])
    }

    func testFill_WithoutStorageData_ShouldLoadFromSource() async throws {
        let tokens = Set([TokenMetadata.usdc, TokenMetadata.nativeSolana])

        let source = TestableSolanaTokenListSource()
        source.mockTokens = tokens

        let storage = TestableSolanaTokenListStorage()
        storage.mockTokens = nil

        let service = SolanaTokenListRepository(
            tokenListSource: source,
            storage: storage
        )

        try await service.fill()

        XCTAssertEqual(storage.getTokensCalled, 1)
        XCTAssertEqual(storage.saveTokensCalled, 1)
        XCTAssertEqual(source.downloadCalled, 1)

        let records = await service.records
        XCTAssertEqual(records.count, 2)
        XCTAssertNotNil(records[TokenMetadata.usdc.address])
        XCTAssertNotNil(records[TokenMetadata.nativeSolana.address])
        XCTAssertNil(records[TokenMetadata.usdt.address])
    }

    func testReset_ShouldRecordBeEmpty() async throws {
        let tokens = Set([TokenMetadata.usdc, TokenMetadata.nativeSolana])

        let source = TestableSolanaTokenListSource()
        source.mockTokens = tokens

        let storage = TestableSolanaTokenListStorage()
        storage.mockTokens = tokens

        let service = SolanaTokenListRepository(
            tokenListSource: source,
            storage: storage
        )

        await service.updateRecords(Dictionary(uniqueKeysWithValues: tokens.map { ($0.address, $0) }))

        try await service.reset()

        let records = await service.records
        XCTAssertTrue(records.isEmpty)
    }

    func testGet_RecordsIsEmpty_ShouldFill() async throws {
        let tokens = Set([TokenMetadata.usdc, TokenMetadata.nativeSolana])

        let source = TestableSolanaTokenListSource()
        source.mockTokens = tokens

        let storage = TestableSolanaTokenListStorage()
        storage.mockTokens = []

        let service = SolanaTokenListRepository(
            tokenListSource: source,
            storage: storage
        )

        let token = try await service.get(address: TokenMetadata.usdc.address)

        XCTAssertEqual(storage.getTokensCalled, 1)
        XCTAssertEqual(storage.saveTokensCalled, 1)
        XCTAssertEqual(source.downloadCalled, 1)

        XCTAssertEqual(token?.name, "USDC")
    }
}

extension SolanaTokenListRepository {
    func updateRecords(_ records: [String: TokenMetadata]) async {
        self.records = records
    }
}
