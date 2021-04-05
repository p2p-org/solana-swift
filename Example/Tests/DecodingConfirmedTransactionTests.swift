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
    func testDecodingConfirmedTransaction() throws {
        let path = Bundle(for: Self.self).path(forResource: "ConfirmedTransaction", ofType: "json")
        let data = try Data(contentsOf: .init(fileURLWithPath: path!))
        let confirmedTransaction = try JSONDecoder().decode(SolanaSDK.TransactionInfo.self, from: data)
        
        XCTAssertEqual(confirmedTransaction.blockTime, 1617564245)
        XCTAssertEqual(confirmedTransaction.slot, 72208574)
        XCTAssertEqual(confirmedTransaction.transaction.message.instructions[0].parsed?.type, .createAccount)
        XCTAssertEqual(confirmedTransaction.transaction.message.instructions[1].parsed?.type, .initializeAccount)
        XCTAssertEqual(confirmedTransaction.transaction.message.instructions[2].parsed?.type, .approve)
        XCTAssertEqual(confirmedTransaction.transaction.message.instructions[4].parsed?.type, .closeAccount)
    }
}
