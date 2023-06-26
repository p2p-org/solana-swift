//
//  BufferLayoutTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 06/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SolanaSwift
import XCTest

class BufferLayoutTests: XCTestCase {
    // MARK: - Mint

    func testDecodingMint() throws {
        XCTAssertEqual(SPLTokenState.BUFFER_LENGTH, 82)

        let string =
            "AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)
        let mintLayout = try SPLTokenState(from: &binaryReader)

        XCTAssertEqual(mintLayout.mintAuthorityOption, 1)
        XCTAssertEqual(mintLayout.mintAuthority?.base58EncodedString, "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        XCTAssertEqual(mintLayout.supply, 1_000_000_000_000)
        XCTAssertEqual(mintLayout.decimals, 6)
        XCTAssertEqual(mintLayout.isInitialized, true)
        XCTAssertEqual(mintLayout.freezeAuthorityOption, 0)
        XCTAssertNil(mintLayout.freezeAuthority)
    }

    // MARK: - Account info

    func testDecodingAccountInfo() throws {
        XCTAssertEqual(SPLAccountState.BUFFER_LENGTH, 165)

        let string =
            "BhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQwCqmOzhzy1ve5l2AqL0ottCChJZ1XSIW3k3C7TaBQn7aCGAQAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWqAQAAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)
        let accountInfo = try SPLAccountState(from: &binaryReader)

        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", accountInfo.mint.base58EncodedString)
        XCTAssertEqual("BQWWFhzBdw2vKKBUX17NHeFbCoFQHfRARpdztPE2tDJ", accountInfo.owner.base58EncodedString)
        XCTAssertEqual(accountInfo.lamports, 100_000)
        XCTAssertEqual(accountInfo.delegateOption, 1)
        XCTAssertEqual("GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", accountInfo.delegate?.base58EncodedString)
        XCTAssertEqual(accountInfo.isInitialized, true)
        XCTAssertEqual(accountInfo.isFrozen, false)
        XCTAssertEqual(accountInfo.state, 1)
        XCTAssertEqual(accountInfo.isNativeOption, 0)
        XCTAssertEqual(accountInfo.rentExemptReserve, nil)
        XCTAssertEqual(accountInfo.isNativeRaw, 0)
        XCTAssertEqual(accountInfo.isNative, false)
        XCTAssertEqual(accountInfo.delegatedAmount, 100)
        XCTAssertEqual(accountInfo.closeAuthorityOption, 0)
        XCTAssertEqual(accountInfo.closeAuthority?.base58EncodedString, nil)
    }

    func testDecodingAccountInfo2() throws {
        let string =
            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq"

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)
        let accountInfo = try SPLAccountState(from: &binaryReader)

        XCTAssertEqual("11111111111111111111111111111111", accountInfo.mint.base58EncodedString)
        XCTAssertEqual("11111111111111111111111111111111", accountInfo.owner.base58EncodedString)
        XCTAssertEqual(accountInfo.lamports, 0)
        XCTAssertEqual(accountInfo.delegateOption, 0)
        XCTAssertNil(accountInfo.delegate)
        XCTAssertEqual(accountInfo.isInitialized, false)
        XCTAssertEqual(accountInfo.isFrozen, false)
        XCTAssertEqual(accountInfo.state, 0)
        XCTAssertEqual(accountInfo.isNativeOption, 0)
        XCTAssertNil(accountInfo.rentExemptReserve)
        XCTAssertEqual(accountInfo.isNativeRaw, 0)
        XCTAssertEqual(accountInfo.isNative, false)
        XCTAssertEqual(accountInfo.delegatedAmount, 0)
        XCTAssertEqual(accountInfo.closeAuthorityOption, 1)
        XCTAssertEqual(accountInfo.closeAuthority?.base58EncodedString, "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")

        let string2 =
            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq"
        let data2 = Data(base64Encoded: string2)!

        var binaryReader2 = BinaryReader(bytes: data2.bytes)
        let accountInfo2 = try SPLAccountState(from: &binaryReader2)

        XCTAssertEqual("11111111111111111111111111111111", accountInfo2.mint.base58EncodedString)
        XCTAssertEqual("11111111111111111111111111111111", accountInfo2.owner.base58EncodedString)
        XCTAssertEqual(accountInfo2.lamports, 0)
        XCTAssertEqual(accountInfo2.delegateOption, 0)
        XCTAssertNil(accountInfo2.delegate)
        XCTAssertEqual(accountInfo2.isInitialized, true)
        XCTAssertEqual(accountInfo2.isFrozen, true)
        XCTAssertEqual(accountInfo2.state, 2)
        XCTAssertEqual(accountInfo2.isNativeOption, 0)
        XCTAssertNil(accountInfo2.rentExemptReserve)
        XCTAssertEqual(accountInfo2.isNativeRaw, 0)
        XCTAssertEqual(accountInfo2.isNative, false)
        XCTAssertEqual(accountInfo2.delegatedAmount, 0)
        XCTAssertEqual(accountInfo2.closeAuthorityOption, 1)
        XCTAssertEqual(accountInfo2.closeAuthority?.base58EncodedString, "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
    }


    // MARK: - EmptyInfo

    func testDecodingEmptyInfo() throws {
        let string =
            "AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
        let data = Data(base64Encoded: string)!
        var binaryReader = BinaryReader(bytes: data.bytes)
        let _ = try EmptyInfo(from: &binaryReader)
    }
}
