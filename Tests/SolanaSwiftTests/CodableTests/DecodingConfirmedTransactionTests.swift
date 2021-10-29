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
    let endpoint = SolanaSDK.APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )
    var solanaSDK: SolanaSDK!
    
    var parser: SolanaSDK.TransactionParser!
    var oldParser: SolanaSDK.TransactionParser!
    
    override func setUpWithError() throws {
        let accountStorage = InMemoryAccountStorage()
        solanaSDK = SolanaSDK(endpoint: endpoint, accountStorage: accountStorage)
        
        let account = try SolanaSDK.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        
        try accountStorage.save(account)
        
        parser = SolanaSDK.TransactionParser(solanaSDK: solanaSDK, orcaSwapParser: nil)
        oldParser = SolanaSDK.TransactionParser(solanaSDK: solanaSDK, orcaSwapParser: SolanaSDK.OldOrcaSwapParserImpl(solanaSDK: solanaSDK))
    }
    
    func testDecodingCreateAccountTransaction() throws {
        let transaction = try parse(fileName: "CreateAccountTransaction").value as! SolanaSDK.CreateAccountTransaction
        
        XCTAssertEqual(transaction.fee, 0.00203928)
        XCTAssertEqual(transaction.newWallet?.token.symbol, "ETH")
        XCTAssertEqual(transaction.newWallet?.pubkey, "8jpWBKSoU7SXz9gJPJS53TEXXuWcg1frXLEdnfomxLwZ")
    }

    func testDecodingCreateBOPAccountTransaction() throws {
        let transaction = try parse(fileName: "CreateBOPAccountTransaction").value as! SolanaSDK.CreateAccountTransaction
        
        XCTAssertEqual(transaction.newWallet?.token.symbol, "BOP")
        XCTAssertEqual(transaction.newWallet?.pubkey, "3qjHF2CHQbPEkuq3cTbS9iwfWfSsHsqmgyMj7M2ZuVSx")
    }
    
    func testDecodingCloseAccountTransaction() throws {
        let transaction = try parse(fileName: "CloseAccountTransaction").value as! SolanaSDK.CloseAccountTransaction
        
        XCTAssertEqual(transaction.reimbursedAmount, 0.00203928)
        XCTAssertEqual(transaction.closedWallet?.token.symbol, "ETH")
    }
    
    func testDecodingSendSOLTransaction() throws {
        let myAccount = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let transaction = try parse(fileName: "SendSOLTransaction", myAccount: myAccount).value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SOL")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.authority, nil)
        XCTAssertEqual(transaction.destinationAuthority, nil)
        XCTAssertEqual(transaction.amount, 0.01)
        XCTAssertEqual(transaction.wasPaidByP2POrg, false)
    }
    
    func testDecodingSendSOLTransactionPaidByP2PORG() throws {
        let myAccount = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let transaction = try parse(fileName: "SendSOLTransactionPaidByP2PORG", myAccount: myAccount).value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SOL")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.authority, nil)
        XCTAssertEqual(transaction.destinationAuthority, nil)
        XCTAssertEqual(transaction.amount, 0.00001)
        XCTAssertEqual(transaction.wasPaidByP2POrg, true)
    }
    
    func testDecodingSendSPLToSOLTransaction() throws {
        let myAccount = "22hXC9c4SGccwCkjtJwZ2VGRfhDYh9KSRCviD8bs4Xbg"
        let transaction = try parse(fileName: "SendSPLToSOLTransaction", myAccount: myAccount).value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "wUSDT")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "GCmbXJRc6mfnNNbnh5ja2TwWFzVzBp8MovsrTciw1HeS")
        XCTAssertEqual(transaction.authority, "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm")
        XCTAssertEqual(transaction.destinationAuthority, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.amount, 0.004325)
    }
    
    func testDecodingSendSPLToSPLTransaction() throws {
        let myAccount = "BjUEdE292SLEq9mMeKtY3GXL6wirn7DqJPhrukCqAUua"
        let transaction = try parse(fileName: "SendSPLToSPLTransaction", myAccount: myAccount).value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SRM")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3YuhjsaohzpzEYAsonBQakYDj3VFWimhDn7bci8ERKTh")
        XCTAssertEqual(transaction.authority, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.amount, 0.012111)
    }
    
    func testDecodingSendTokenToNewAssociatedTokenAddress() throws {
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        let transaction = try parse(fileName: "SendTokenToNewAssociatedTokenAddress", myAccount: myAccount, myAccountSymbol: "MAPS").value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "MAPS")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.amount, 0.001)
        XCTAssertEqual(transaction.authority, "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm")
        XCTAssertEqual(transaction.destinationAuthority, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        
        // transfer checked type
        let transaction2 = try parse(fileName: "SendTokenToNewAssociatedTokenAddressTransferChecked", myAccount: myAccount, myAccountSymbol: "MAPS").value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction2.source?.token.symbol, "MAPS")
        XCTAssertEqual(transaction2.source?.pubkey, myAccount)
        XCTAssertEqual(transaction2.amount, 0.001)
        XCTAssertEqual(transaction.authority, "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm")
        XCTAssertEqual(transaction.destinationAuthority, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
    }
    
    func testDecodingSendSPLTokenParsedInNativeSOLWallet() throws {
        let myAccount = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let transaction = try parse(fileName: "SendSPLTokenParsedInNativeSOLWallet", myAccount: myAccount).value as! SolanaSDK.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "RAY")
        XCTAssertEqual(transaction.authority, myAccount)
        XCTAssertEqual(transaction.source?.pubkey, "5ADqZHdZzL3xd2NiP8MrM4pCFj5ijC4oQWSBzvXx4fbY")
        XCTAssertEqual(transaction.destination?.pubkey, "4ijqHixcbzhxQbfJWAoPkvBhokBDRGtXyqVcMN8ywj8W")
        XCTAssertEqual(transaction.authority, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
//        XCTAssertEqual(transaction.destinationAuthority, "B4PdyoVU39hoCaiTLPtN9nJxy6rEpbciE3BNPvHkCeE2")
        XCTAssertEqual(transaction.transferType, .send)
        XCTAssertEqual(transaction.wasPaidByP2POrg, true)
    }
    
    func testDecodingProvideLiquidityToPoolTransaction() throws {
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        let transaction = try parse(fileName: "ProvideLiquidityToPoolTransaction", myAccount: myAccount)
        
        XCTAssertNil(transaction.value)
    }
    
    func testDecodingBurnLiquidityInPoolTransaction() throws {
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        let transaction = try parse(fileName: "BurnLiquidityInPoolTransaction", myAccount: myAccount)
        
        XCTAssertNil(transaction.value)
    }
    
    func testDecodingSwapTransaction() throws {
        let myAccountSymbol = "SOL"
        let transaction = try parse(fileName: "SwapTransaction", myAccountSymbol: myAccountSymbol).value as! SolanaSDK.SwapTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SRM")
        XCTAssertEqual(transaction.source?.pubkey, "BjUEdE292SLEq9mMeKtY3GXL6wirn7DqJPhrukCqAUua")
        XCTAssertEqual(transaction.sourceAmount, 0.001)
        
        XCTAssertEqual(transaction.destination?.token.symbol, myAccountSymbol)
        XCTAssertEqual(transaction.destinationAmount, 0.000364885)
    }
    
    func testDecodingSwapErrorTransaction() throws {
        let myAccount = "G8PrkEwmVx3kt3rXBin5o1bdDC1cvz7oBnXbHksNg7R4"
        let parsedTransaction = try parse(fileName: "SwapErrorTransaction", myAccount: myAccount)
        let transaction = parsedTransaction.value as! SolanaSDK.SwapTransaction
        
        XCTAssertEqual(parsedTransaction.status, .error("Swap instruction exceeds desired slippage limit"))
        XCTAssertEqual(transaction.source?.token.symbol, "KIN")
        XCTAssertEqual(transaction.source?.pubkey, "2xKofw1wK2CVMVUssGTv3G5pVrUALAR9r8J9zZnwtrUG")
        XCTAssertEqual(transaction.sourceAmount?.rounded(), 100)
        
        XCTAssertEqual(transaction.destination?.token.symbol, "SOL")
        XCTAssertEqual(transaction.destination?.pubkey, "G8PrkEwmVx3kt3rXBin5o1bdDC1cvz7oBnXbHksNg7R4")
    }
    
    func testDecodingSerumSwapTransaction() throws {
        let parsedTransaction = try parse(fileName: "SerumSwapTransaction")
        let transaction = parsedTransaction.value as! SolanaSDK.SwapTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SOL")
        XCTAssertEqual(transaction.source?.pubkey, "D7XYERWodEGaoN2X855T2qLvse28BSjfkvfCyW2EDBWy")
        XCTAssertEqual(transaction.sourceAmount, 0.1)
        
        XCTAssertEqual(transaction.destination?.token.symbol, "USDC")
        XCTAssertEqual(transaction.destination?.pubkey, "375DTPnEBUjCnvQpGQtg5nRQudwa6oXWEYB15X6MmJs6")
        XCTAssertEqual(transaction.destinationAmount?.toLamport(decimals: 6), 14198095)
    }
    
    func testDecodingSerumSwapTransaction2() throws {
        let parsedTransaction = try parse(fileName: "SerumSwapTransaction2")
        let transaction = parsedTransaction.value as! SolanaSDK.SwapTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "BTC")
        XCTAssertEqual(transaction.source?.pubkey, "FfH77kuL45qgqALsxtz6ktfSgbLSPfrB23AsoDnBxqUj")
        XCTAssertEqual(transaction.sourceAmount, 0.001)
        
        XCTAssertEqual(transaction.destination?.token.symbol, "ETH")
        XCTAssertEqual(transaction.destination?.pubkey, "FT3A24vCezU25TzvDfPmDdHwpHDQdYZU4Z6Lt3Kf8WsT")
        XCTAssertEqual(transaction.destinationAmount?.toLamport(decimals: transaction.destination?.token.decimals ?? 0), 13000)
    }
    
    func testDecodingSerumSwapTransaction3() throws {
        let parsedTransaction = try parse(fileName: "SerumSwapTransaction3")
        let transaction = parsedTransaction.value as! SolanaSDK.SwapTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "USDC")
        XCTAssertEqual(transaction.source?.pubkey, "375DTPnEBUjCnvQpGQtg5nRQudwa6oXWEYB15X6MmJs6")
        XCTAssertEqual(transaction.sourceAmount, 5)
        
        XCTAssertEqual(transaction.destination?.token.symbol, "SRM")
        XCTAssertEqual(transaction.destination?.pubkey, "6Q49AE4NGeTXYDyyXx8gEVxJV28Vsn6bVJp4w3UqTByg")
        XCTAssertEqual(transaction.destinationAmount?.toLamport(decimals: transaction.destination?.token.decimals ?? 0), 500000)
    }
    
    func testDecodingSerumSwapTransaction4() throws {
        // USDT -> USDC
        let parsedTransaction = try parse(fileName: "SerumSwapTransaction4")
        let transaction = parsedTransaction.value as! SolanaSDK.SwapTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "USDT")
        XCTAssertEqual(transaction.source?.pubkey, "GYYHwdXW7v8RaXv7zXvhQSJYKU9b9RMtRB2dufu9fnpR")
        XCTAssertEqual(transaction.sourceAmount, 2)
        
        XCTAssertEqual(transaction.destination?.token.symbol, "USDC")
        XCTAssertEqual(transaction.destination?.pubkey, "8TnZDzWSzkSrRVxwGY6uPTaPSt2NDBvKD6uA5SZD3P87")
        XCTAssertEqual(transaction.destinationAmount?.toLamport(decimals: transaction.destination?.token.decimals ?? 0), 1993604)
    }
    
    func testSwap01() throws {
        let trx1 = try parse(fileName: "Swap1").value as! SolanaSDK.SwapTransaction
        let trx2 = try parse(fileName: "Swap1", parser: oldParser).value as! SolanaSDK.SwapTransaction
        
        XCTAssertEqual(trx1.source?.token.symbol, trx2.source?.token.symbol)
        XCTAssertEqual(trx1.source?.pubkey, trx2.source?.pubkey)
        XCTAssertEqual(trx1.sourceAmount, trx2.sourceAmount)
        
        XCTAssertEqual(trx1.destination?.token.symbol, trx2.destination?.token.symbol)
        XCTAssertEqual(trx1.destination?.pubkey, trx2.destination?.pubkey)
        XCTAssertEqual(trx1.destinationAmount, trx2.destinationAmount)
    }
    
    private func parse(
        fileName: String,
        parser: SolanaSDK.TransactionParser? = nil,
        myAccount: String? = nil,
        myAccountSymbol: String? = nil
    ) throws -> SolanaSDK.ParsedTransaction {
        let transactionInfo = try transactionInfoFromJSONFileName(fileName)
        
        let _parser: SolanaSDK.TransactionParser = parser ?? self.parser
        return try _parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: myAccountSymbol, p2pFeePayerPubkeys: ["FG4Y3yX4AAchp1HvNZ7LfzFTewF2f6nDoMDCohTFrdpT"])
            .toBlocking().first()!
    }
    
    private func transactionInfoFromJSONFileName(_ name: String) throws -> SolanaSDK.TransactionInfo
    {
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let resourceURL = thisDirectory.appendingPathComponent("../Resources/\(name).json")
        let data = try! Data(contentsOf: resourceURL)
        let transactionInfo = try JSONDecoder().decode(SolanaSDK.TransactionInfo.self, from: data)
        return transactionInfo
    }
}
