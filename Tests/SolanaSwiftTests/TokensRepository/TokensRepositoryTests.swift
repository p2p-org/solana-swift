import XCTest
@testable import SolanaSwift

class TokensRepositoryTests: XCTestCase {
    
    let apiClient = JSONRPCAPIClient(endpoint: .defaultEndpoints.first!)
    
    func testTokenRepository() async throws {
        let mock = MockNetworkManager()
        let tokenRepository = TokensRepository(apiClient: apiClient, tokenListParser: TokensListParser(networkManager: mock))
        let list = try await tokenRepository.getTokensList()
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list.first?.chainId, 101)
        XCTAssertEqual(list.first?.address, "So11111111111111111111111111111111111111112")
        XCTAssertEqual(list.first?.name, "Wrapped SOL")
        XCTAssertEqual(list.first?.decimals, 9)
    }
    
    func testTokenRepositoryCacheWithNetworkError() async throws {
        // Putting to cache
        try? await {
            let mock = MockNetworkManager()
            let tokenRepository = TokensRepository(apiClient: apiClient, tokenListParser: TokensListParser(networkManager: mock))
            _ = try await tokenRepository.getTokensList()
        }()
        
        let mock = MockNetworkManager(withError: true)
        let tokenRepository = TokensRepository(apiClient: apiClient, tokenListParser: TokensListParser(networkManager: mock))
        let list = try await tokenRepository.getTokensList()
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list.count, 1)
    }
    
    func testTokenRepositoryNoCacheNetworkError() async throws {
        let mock = MockNetworkManager(withError: true)
        let tokenRepository = TokensRepository(apiClient: apiClient, tokenListParser: TokensListParser(networkManager: mock))
        do {
            let list = try await tokenRepository.getTokensList(useCache: false)
            XCTAssertTrue(list.isEmpty)
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func testGetTokenWallets() async throws {
        let mock = MockNetworkManager(withError: false)
        let tokenRepository = TokensRepository(apiClient: apiClient, tokenListParser: TokensListParser(networkManager: mock))
        let datas = try! await tokenRepository.getTokenWallets(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertNotEqual(datas.count, 0)
    }

    func testCheckAccountValidation() async throws {
        let mock = MockNetworkManager(withError: false)
        let tokenRepository = TokensRepository(apiClient: apiClient, tokenListParser: TokensListParser(networkManager: mock))
        // funding SOL address
        let isValid1 = try await tokenRepository.checkAccountValidation(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(isValid1, true)

        // no funding SOL address
        let isValid2 = try await tokenRepository.checkAccountValidation(account: "HnXJX1Bvps8piQwDYEYC6oea9GEkvQvahvRj3c97X9xr")
        XCTAssertEqual(isValid2, false)
    }

    class MockNetworkManager: NetworkManager {
        enum MockNetworkManagerError: Error {
            case some
        }
        let withError: Bool
        init(withError: Bool = false) {
            self.withError = withError
        }
        
        func requestData(request: URLRequest) async throws -> Data {
            if withError { throw MockNetworkManagerError.some }
            return json.data(using: .utf8)!
        }
    }
}


let json = """
{
\"name\": \"Solana Token List\",
\"logoURI\": \"https://cdn.jsdelivr.net/gh/trustwallet/assets@master/blockchains/solana/info/logo.png\",
\"keywords\": [
  \"solana\",
  \"spl\"
],
\"tags\": {},
\"timestamp\": \"2021-03-03T19:57:21+0000\",
\"tokens\": [
  {
    \"chainId\": 101,
    \"address\": \"So11111111111111111111111111111111111111112\",
    \"symbol\": \"SOL\",
    \"name\": \"Wrapped SOL\",
    \"decimals\": 9,
    \"logoURI\": \"https://cdn.jsdelivr.net/gh/trustwallet/assets@master/blockchains/solana/info/logo.png\",
    \"tags\": [],
    \"extensions\": {
      \"website\": \"https://solana.com/\"
    }
  }],
  \"version\": {
    \"major\": 0,
    \"minor\": 2,
    \"patch\": 0
   }
}
"""
