//
//  RenVMLockAndMintTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 09/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class RenVMLockAndMintTests: XCTestCase {
    let destinationAddress: SolanaSDK.PublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
    private let sessionDay: Long = 18870
    private lazy var session = RenVM.LockAndMint.Session(
        destinationAddress: destinationAddress.base58EncodedString,
        sessionDay: sessionDay
    )
    
    func testSession() throws {
        XCTAssertEqual(session.expiryTime, 1630627200000)
        XCTAssertEqual(session.nonce, "2020202020202020202020202020202020202020202020202020202034396236")
    }
}
