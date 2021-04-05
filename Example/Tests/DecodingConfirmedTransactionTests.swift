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
    }
}
