import XCTest
@testable import SolanaSwift

class APIClientExtensionsTests: XCTestCase {
    let endpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )
    
    func testCheckAccountValidation() async throws {
        // TODO:
//        // funding SOL address
//        let isValid1 = try solanaSDK.checkAccountValidation(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG").toBlocking().first()
//        XCTAssertEqual(isValid1, true)
//        
//        // no funding SOL address
//        let isValid2 = try solanaSDK.checkAccountValidation(account: "HnXJX1Bvps8piQwDYEYC6oea9GEkvQvahvRj3c97X9xr").toBlocking().first()
//        XCTAssertEqual(isValid2, false)
//        
//        // token address
//        let isValid3 = try solanaSDK.checkAccountValidation(account: "8J5wZ4Lo7QSwFWwBfWsWUgsbH4Jr44RFsEYj6qFdXYhM").toBlocking().first()
//        XCTAssertEqual(isValid3, true)
    }
    
    func testFindSPLTokenDestinationAddress() async throws {
        // TODO:
        // USDC
//        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
//        let destination = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
//
//        let mock = NetworkManagerMock(NetworkManagerMockJSON["simulateTransaction"]!)
//        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
//        let result = try await apiClient.findSPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: destination)
//        XCTAssertEqual(result.destination, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
//        XCTAssertEqual(result.isUnregisteredAsocciatedToken, false)
    }
    
    func testCheckIfAssociatedTokenAccountExists() async throws {
        // TODO:
    }
    
    func testGetTokenWallets() throws {
//        let datas = try solanaSDK.getTokenWallets(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG").toBlocking().first()
//        XCTAssertNotEqual(datas?.count, 0)
    }
}
