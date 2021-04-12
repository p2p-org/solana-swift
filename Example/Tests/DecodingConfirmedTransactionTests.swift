//
//  DecodingConfirmedTransactionTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 05/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class DecodingConfirmedTransactionTests: XCTestCase {
    var solanaSDK: SolanaSDK!
    var network = SolanaSDK.Network.mainnetBeta
    var parser: SolanaSDK.TransactionParser!
    
    override func setUpWithError() throws {
        solanaSDK = SolanaSDK(network: network, accountStorage: InMemoryAccountStorage())
        let account = try SolanaSDK.Account(phrase: network.testAccount.components(separatedBy: " "), network: network)
        try solanaSDK.accountStorage.save(account)
        
        parser = SolanaSDK.TransactionParser(solanaSDK: solanaSDK)
    }
    
    func testDecodingSwapTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SwapTransaction")
        
        let myAccountSymbol = "SOL"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: myAccountSymbol)
            .toBlocking().first()?.value as! SolanaSDK.SwapTransaction
        
        XCTAssertEqual(transaction.source?.symbol, "SRM")
        XCTAssertEqual(transaction.source?.pubkey, "BjUEdE292SLEq9mMeKtY3GXL6wirn7DqJPhrukCqAUua")
        XCTAssertEqual(transaction.sourceAmount, 0.001)
        
        XCTAssertEqual(transaction.destination?.symbol, myAccountSymbol)
        XCTAssertEqual(transaction.destinationAmount, 0.000364885)
    }
    
    func testDecodingCreateAccountTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("CreateAccountTransaction")
        
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: nil)
            .toBlocking().first()?.value as! SolanaSDK.CreateAccountTransaction
        
        XCTAssertEqual(transaction.fee, 0.00203928)
        XCTAssertEqual(transaction.newToken?.symbol, "ETH")
        XCTAssertEqual(transaction.newToken?.pubkey, "8jpWBKSoU7SXz9gJPJS53TEXXuWcg1frXLEdnfomxLwZ")
    }
    
    func testDecodingCloseAccountTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("CloseAccountTransaction")
        
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: nil)
            .toBlocking().first()?.value as! SolanaSDK.CloseAccountTransaction
        
        XCTAssertEqual(transaction.reimbursedAmount, 0.00203928)
        XCTAssertEqual(transaction.closedToken?.symbol, "ETH")
    }
    
    func testDecodingSendSOLTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SendSOLTransaction")
        
        let myAccount = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.symbol, "SOL")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.amount, 0.01)
    }
    
    func testDecodingSendSPLToSOLTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SendSPLToSOLTransaction")
        let myAccount = "22hXC9c4SGccwCkjtJwZ2VGRfhDYh9KSRCviD8bs4Xbg"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.symbol, "USDT")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "GCmbXJRc6mfnNNbnh5ja2TwWFzVzBp8MovsrTciw1HeS")
        XCTAssertEqual(transaction.amount, 0.004325)
    }
    
    func testDecodingSendSPLToSPLTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SendSPLToSPLTransaction")
        let myAccount = "BjUEdE292SLEq9mMeKtY3GXL6wirn7DqJPhrukCqAUua"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.symbol, "SRM")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3YuhjsaohzpzEYAsonBQakYDj3VFWimhDn7bci8ERKTh")
        XCTAssertEqual(transaction.amount, 0.012111)
    }
    
    private func transactionInfoFromJSONFileName(_ name: String) throws -> SolanaSDK.TransactionInfo
    {
        let path = Bundle(for: Self.self).path(forResource: name, ofType: "json")
        let data = try Data(contentsOf: .init(fileURLWithPath: path!))
        let transactionInfo = try JSONDecoder().decode(SolanaSDK.TransactionInfo.self, from: data)
        return transactionInfo
    }
}
