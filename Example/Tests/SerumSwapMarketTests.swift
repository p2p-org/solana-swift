//
//  SerumSwapMarketTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 18/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class SerumSwapMarketTests: XCTestCase {

    func testAccountFlags() throws {
        // Decode
        XCTAssertEqual(
            try SerumSwap.AccountFlags.fromBytes(bytes: Data(hex: "0000000000000000").bytes),
            .init(
                initialized: false,
                market: false,
                openOrders: false,
                requestQueue: false,
                eventQueue: false,
                bids: false,
                asks: false
            )
        )
        
        XCTAssertEqual(
            try SerumSwap.AccountFlags.fromBytes(bytes: Data(hex: "0300000000000000").bytes),
            .init(
                initialized: true,
                market: true,
                openOrders: false,
                requestQueue: false,
                eventQueue: false,
                bids: false,
                asks: false
            )
        )
        
        XCTAssertEqual(
            try SerumSwap.AccountFlags.fromBytes(bytes: Data(hex: "0500000000000000").bytes),
            .init(
                initialized: true,
                market: false,
                openOrders: true,
                requestQueue: false,
                eventQueue: false,
                bids: false,
                asks: false
            )
        )
        
        XCTAssertEqual(
            try SerumSwap.AccountFlags.fromBytes(bytes: Data(hex: "4100000000000000").bytes),
            .init(
                initialized: true,
                market: false,
                openOrders: false,
                requestQueue: false,
                eventQueue: false,
                bids: false,
                asks: true
            )
        )
        
        // Encode
        XCTAssertEqual(
            try SerumSwap.AccountFlags(
                initialized: false,
                market: false,
                openOrders: false,
                requestQueue: false,
                eventQueue: false,
                bids: false,
                asks: false
            ).encode().hexString,
            "0000000000000000"
        )
        
        XCTAssertEqual(
            try SerumSwap.AccountFlags(
                initialized: true,
                market: true,
                openOrders: false,
                requestQueue: false,
                eventQueue: false,
                bids: false,
                asks: false
            ).encode().hexString,
            "0300000000000000"
        )
        
        XCTAssertEqual(
            try SerumSwap.AccountFlags(
                initialized: true,
                market: false,
                openOrders: true,
                requestQueue: false,
                eventQueue: false,
                bids: false,
                asks: false
            ).encode().hexString,
            "0500000000000000"
        )
        
        XCTAssertEqual(
            try SerumSwap.AccountFlags(
                initialized: true,
                market: false,
                openOrders: false,
                requestQueue: false,
                eventQueue: false,
                bids: false,
                asks: true
            ).encode().hexString,
            "4100000000000000"
        )
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
