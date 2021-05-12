//
//  FeeRelayerTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 12/05/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import SolanaSwift
import RxBlocking

class FeeRelayerTests: XCTestCase {
    func testGetFeePayerPubkey() throws {
        let _ = try SolanaSDK.FeeRelayer.getFeePayerPubkey()
            .toBlocking().first()
    }
}
