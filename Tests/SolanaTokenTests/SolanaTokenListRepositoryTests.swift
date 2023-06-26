import XCTest
@testable import SolanaToken

class TokensRepositoryTests: XCTestCase {
    func testFill_WithStorageData_ShouldLoadFromStorage() async throws {
        let tokens = Set([Token.usdc, Token.nativeSolana])

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
        XCTAssertEqual(records.count, 2)
        XCTAssertNotNil(records[Token.usdc.address])
        XCTAssertNotNil(records[Token.nativeSolana.address])
        XCTAssertNil(records[Token.usdt.address])
    }

    func testFill_WithoutStorageData_ShouldLoadFromSource() async throws {
        let tokens = Set([Token.usdc, Token.nativeSolana])

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
        XCTAssertNotNil(records[Token.usdc.address])
        XCTAssertNotNil(records[Token.nativeSolana.address])
        XCTAssertNil(records[Token.usdt.address])
    }

    func testReset_ShouldRecordBeEmpty() async throws {
        let tokens = Set([Token.usdc, Token.nativeSolana])

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
        let tokens = Set([Token.usdc, Token.nativeSolana])

        let source = TestableSolanaTokenListSource()
        source.mockTokens = tokens

        let storage = TestableSolanaTokenListStorage()
        storage.mockTokens = []

        let service = SolanaTokenListRepository(
            tokenListSource: source,
            storage: storage
        )

        let token = try await service.get(address: Token.usdc.address)

        XCTAssertEqual(storage.getTokensCalled, 1)
        XCTAssertEqual(storage.saveTokensCalled, 1)
        XCTAssertEqual(source.downloadCalled, 1)

        XCTAssertEqual(token?.name, "USDC")
    }
}

extension SolanaTokenListRepository {
    func updateRecords(_ records: [String: Token]) async {
        self.records = records
    }
}
