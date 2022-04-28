//
//  AssociatedTokenProgramTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 27/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class AssociatedTokenProgramTests_Deprecated: RestAPITests {
    override var overridingAccount: String? {
        "miracle pizza supply useful steak border same again youth silver access hundred"
    }
    
    func testFindAssociatedTokenAddress() throws {
        let associatedTokenAddress = try SolanaSDK.PublicKey.associatedTokenAddress(
            walletAddress: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            tokenMintAddress: "CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5"
        )
        
        XCTAssertEqual(associatedTokenAddress.base58EncodedString, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
    }
    
    func testCreateAssociatedTokenAddress() throws {
        let associatedTokenAddress = try solanaSDK.createAssociatedTokenAccount(
            for: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            tokenMint: "CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5",
            isSimulation: true
        ).toBlocking().first()
    }
}
