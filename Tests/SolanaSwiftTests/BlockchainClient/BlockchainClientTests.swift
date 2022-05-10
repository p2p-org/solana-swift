import Foundation

import XCTest
import SolanaSwift

class BlockchainClientTests: XCTestCase {
    var lamportsPerSignature: UInt64 { 5000 }
    var minRentExemption: UInt64 { 2039280 }
    
    var feeCalculator: DefaultFeeCalculator!
    let endpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )
    
    override func setUpWithError() throws {
        let accountStorage = InMemoryAccountStorage()
        let account = try Account(phrase: (endpoint.network.testAccount).components(separatedBy: " "), network: endpoint.network)
        try accountStorage.save(account)
        
        feeCalculator = DefaultFeeCalculator(
            lamportsPerSignature: lamportsPerSignature,
            minRentExemption: minRentExemption
        )
    }
    
    // MARK: - Testcases
    
    func testPrepareSendingNativeSOL() async throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let account = try await Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        let blockchain = BlockchainClient(apiClient: JSONRPCAPIClient(endpoint: endpoint))
        let apiClient = JSONRPCAPIClient(endpoint: endpoint)
        
        let (lamportsPerSignature, minRentExemption) = try await (
            apiClient.getFees().feeCalculator?.lamportsPerSignature,
            apiClient.getMinimumBalanceForRentExemption(span: 165)
        )
        guard let lamportsPerSignature = lamportsPerSignature else {
            throw SolanaError.other("Fee calculator not found")
        }
        feeCalculator = DefaultFeeCalculator(lamportsPerSignature: lamportsPerSignature, minRentExemption: minRentExemption)
        
        let recentBlockhash = try await apiClient.getRecentBlockhash(commitment: nil)
        
        let tx = try await blockchain.prepareSendingNativeSOL(account: account,
                                                              to: toPublicKey,
                                                              amount: 0,
                                                              feePayer: account.publicKey,
                                                              recentBlockhash: recentBlockhash,
                                                              feeCalculator: feeCalculator)
        
        XCTAssertEqual(tx.expectedFee, .init(transaction: 5000, accountBalances: 0))
    }
    
    func testFindSPLTokenDestinationAddress() async throws {
        // USDC
        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        let destination = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        
        let blockchain = BlockchainClient(apiClient: JSONRPCAPIClient(endpoint: endpoint))
        let result = try await blockchain.findSPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: destination)
        XCTAssertEqual(result.destination, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
        XCTAssertEqual(result.isUnregisteredAsocciatedToken, false)
    }
    
    func testPrepareSendingSPLTokens() async throws {
        let serializedTx = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABVDg6PUgP0/j0vr9ikPMW6XfkjTjFIO3fUnGTc0jeLpRDcZvF4GaxvBeOfxYD6ldZGD/yTnGbn+CDHT6o9emsLAgABBZVzNUScL8XOGDuZ10tEfPOQu+xHxBtpXUDQYjWq91/PUGovppzL+Lnil9LlySMgCL9FHk19zxobvW2CEQYB/tq9MbTiQmankdqjmH2uZjpU9OB4Cg14/hOLUUY6cv3Fvys0aQm3mACZwx0qmTJR8WAhAmhoXy0B+vDEdgGHBP5sBt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKkDnx0J6XtIf2GzNZPI5gc77kjN9sIC6bnhGhtxCMtQHwEEAwIDAQkD6AMAAAAAAAA="
        // USDC
        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        let source = "DjY1uZozQTPz9c6WsjpPC3jXWp7u98KzyuyQTRzcGHFk"
        let destination = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        
        let account = try await Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        let api = JSONRPCAPIClient(endpoint: endpoint)
        let bc = BlockchainClient(apiClient: api)
        
        // calculate fees
        let tx = try await bc.prepareSendingSPLTokens(account: account,
                                                      mintAddress: mintAddress,
                                                      decimals: 6,
                                                      from: source,
                                                      to: destination,
                                                      amount: Double(0.001).toLamport(decimals: 6),
                                                      fee: try! await api.getFees(commitment: nil),
                                                      feePayer: "B4PdyoVU39hoCaiTLPtN9nJxy6rEpbciE3BNPvHkCeE2",
                                                      recentBlockhash: "F8wk1XcFVcd5M3UDx8S2jy3mEhSVkeBgYw979Mp2fF4").preparedTransaction
        XCTAssertEqual(try! tx.serialize(), serializedTx)
    }
    
    let json: [String: String] = [
        "prepareSendingNativeSOL": "AbGldIcg+coxW3idbrOM6lGA6hfBozLGcQwNUSc7fFWnHipqUS2H78BeTkBjnHLcVEBHsfaigKnhfycpVFuhDQwBAAEDUGovppzL+Lnil9LlySMgCL9FHk19zxobvW2CEQYB/ton97kEVYkyppO43UtuZxDeKV73hCs+rPNfzL6PmRAKxQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAjmPmh7ra9WkvBCyAZ3QzuN3hIn6PwTtCRCylLM5r3cQBAgIAAQwCAAAAAAAAAAAAAAA="
    ]
}
