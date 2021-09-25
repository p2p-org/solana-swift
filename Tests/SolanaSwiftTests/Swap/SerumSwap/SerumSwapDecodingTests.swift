//
//  SerumSwapOtherTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 25/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class SerumSwapDecodingTests: XCTestCase {
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
    
    func testDecodingSlabLayout() throws {
        let hexString = "0900000000000000020000000000000008000000000000000400000000000000010000001e00000000000040952fe4da5c1f3c860200000004000000030000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d7b0000000000000000000000000000000200000002000000000000a0ca17726dae0f1e43010000001111111111111111111111111111111111111111111111111111111111111111410100000000000000000000000000000200000001000000d20a3f4eeee073c3f60fe98e010000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d7b000000000000000000000000000000020000000300000000000040952fe4da5c1f3c8602000000131313131313131313131313131313131313131313131313131313131313131340e20100000000000000000000000000010000001f0000000500000000000000000000000000000005000000060000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d7b0000000000000000000000000000000200000004000000040000000000000000000000000000001717171717171717171717171717171717171717171717171717171717171717020000000000000000000000000000000100000020000000000000a0ca17726dae0f1e430100000001000000020000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d7b000000000000000000000000000000040000000000000004000000000000000000000000000000171717171717171717171717171717171717171717171717171717171717171702000000000000000000000000000000030000000700000005000000000000000000000000000000171717171717171717171717171717171717171717171717171717171717171702000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        
        let data = Data(hex: hexString)
        var pointer = 0
        let slab = try SerumSwap.Slab(buffer: data, pointer: &pointer)
        
        XCTAssertEqual(slab.header.bumpIndex, 9)
        XCTAssertEqual(slab.nodes.count, 9)
    }
}
