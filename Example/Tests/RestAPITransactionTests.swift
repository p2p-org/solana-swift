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
    func testGetBalance() throws {
        let serializedTransaction = try TestHelper.testingSerializedTransaction()
        let result = try solanaSDK.sendTransaction(serializedTransaction: serializedTransaction).toBlocking().first()
        
    }
}
