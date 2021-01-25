//
//  RestAPITransactionTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/9/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import SolanaSwift

class RestAPITransactionTests: RestAPITests {
    override var network: String {"mainnet-beta"}
    
    func testSendToken() throws {
        let accountToSend = "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5"
        
        XCTAssertNoThrow(try solanaSDK.sendTokens(from: account.publicKey.base58EncodedString, to: accountToSend, amount: 30).toBlocking().first())
    }
    
    func testSwapTransaction() throws {
        let fromToken = try SolanaSDK.PublicKey(string: "3sRavwSu5dmCjXnu66Y1Phe93MXwUC1Q8Kqi2eh9dWnL") // SOL
        let toToken = try SolanaSDK.PublicKey(string: "5t9sxN488df2SbCJen3YBV3koLfPJSkdhbGBEK8MSZXo") // USDC
        let recentBlockhash = "GL7QhRzn39oFsEX2aLmcJRDJKxCRjFUXx9fbiUSPGgn"

        let transactionAndSigner = try solanaSDK.swapTransaction(owner: account, fromToken: fromToken, toToken: toToken, slippage: 0.01, amount: 1000000, network: network).toBlocking().first()
        
        var transaction = transactionAndSigner?.0
        let signers = transactionAndSigner?.1
        transaction?.message.recentBlockhash = recentBlockhash
        try transaction?.sign(signers: signers ?? [])
        guard let serializedTransaction = try transaction?.serialize().toBase64() else {
            throw SolanaSDK.Error.other("Could not serialize transaction")
        }
        
        // TODO: - Value for serializedTransaction in test case
        XCTAssertEqual(serializedTransaction, "")
    }
}

