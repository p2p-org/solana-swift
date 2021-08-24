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
        var pointer = 0
        XCTAssertEqual(
            try SerumSwap.AccountFlags(buffer: Data(hex: "0000000000000000"), pointer: &pointer),
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
        
        pointer = 0
        XCTAssertEqual(
            try SerumSwap.AccountFlags(buffer: Data(hex: "0300000000000000"), pointer: &pointer),
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
        
        pointer = 0
        XCTAssertEqual(
            try SerumSwap.AccountFlags(buffer: Data(hex: "0500000000000000"), pointer: &pointer),
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
        
        pointer = 0
        XCTAssertEqual(
            try SerumSwap.AccountFlags(buffer: Data(hex: "4100000000000000"), pointer: &pointer),
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
            ).serialize().hexString,
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
            ).serialize().hexString,
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
            ).serialize().hexString,
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
            ).serialize().hexString,
            "4100000000000000"
        )
    }

}
