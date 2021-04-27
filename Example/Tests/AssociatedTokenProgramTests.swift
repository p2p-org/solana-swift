//
//  AssociatedTokenProgramTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 27/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import SolanaSwift

class AssociatedTokenProgramTests: XCTestCase {
    func testFindAssociatedTokenAddress() throws {
        let associatedTokenAddress = try SolanaSDK.findAssociatedTokenAddress(
            walletAddress: try SolanaSDK.PublicKey(string: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"),
            tokenMintAddress: try SolanaSDK.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
        )
        
    }
}
