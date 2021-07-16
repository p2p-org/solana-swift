//
//  DecodingSocketResponsesTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 31/05/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class DecodingSocketResponsesTests: XCTestCase {
    var decoder: JSONDecoder!

    override func setUpWithError() throws {
        decoder = JSONDecoder()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecodingSOLAccountNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"accountNotification","params":{"result":{"context":{"slot":80221533},"value":{"data":["","base64"],"executable":false,"lamports":41083620,"owner":"11111111111111111111111111111111","rentEpoch":185}},"subscription":46133}}"#
        let result = try decoder.decode(SolanaSDK.Socket.NativeAccountNotification.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.result?.value.lamports, 41083620)
        XCTAssertThrowsError(try decoder.decode(SolanaSDK.Socket.TokenAccountNotification.self, from: string.data(using: .utf8)!))
    }

    func testDecodingTokenAccountNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"accountNotification","params":{"result":{"context":{"slot":80216037},"value":{"data":{"parsed":{"info":{"isNative":false,"mint":"kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6","owner":"6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm","state":"initialized","tokenAmount":{"amount":"390000101","decimals":5,"uiAmount":3900.00101,"uiAmountString":"3900.00101"}},"type":"account"},"program":"spl-token","space":165},"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":185}},"subscription":42765}}"#
        
        XCTAssertThrowsError(try decoder.decode(SolanaSDK.Socket.NativeAccountNotification.self, from: string.data(using: .utf8)!))
        
        let result = try decoder.decode(SolanaSDK.Socket.TokenAccountNotification.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.result?.value.data.parsed.info.tokenAmount.amount, "390000101")
    }
    
    func testDecodingSignatureNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"signatureNotification","params":{"result":{"context":{"slot":80768508},"value":{"err":null}},"subscription":43601}}"#
        
        let result = try decoder.decode(SolanaSDK.Socket.Response<SolanaSDK.Socket.SignatureNotification>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.method, "signatureNotification")
    }

}
