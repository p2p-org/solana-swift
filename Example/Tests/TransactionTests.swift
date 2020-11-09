//
//  TransactionTests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
import SolanaSwift
import CryptoSwift

class TransactionTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        
    }
    
    func testCodingBytesLength() throws {
        let bytes = Data([5,3,1,2,3,7,8,5,4])
        XCTAssertEqual(bytes.decodedLength, 5)
        let bytes2 = Data([74,174,189,206,113,78 ,60,226,136,170])
        XCTAssertEqual(bytes2.decodedLength, 74)
        
        XCTAssertEqual(Data([0]), Data.encodeLength(0))
        XCTAssertEqual(Data([1]), Data.encodeLength(1))
        XCTAssertEqual(Data([5]), Data.encodeLength(5))
        XCTAssertEqual(Data([0x7f]), Data.encodeLength(127))
        XCTAssertEqual(Data([128, 1]), Data.encodeLength(128))
        XCTAssertEqual(Data([0xff, 0x01]), Data.encodeLength(255))
        XCTAssertEqual(Data([0x80, 0x02]), Data.encodeLength(256))
        XCTAssertEqual(Data([0xff, 0xff, 0x01]), Data.encodeLength(32767))
        XCTAssertEqual(Data([0x80, 0x80, 0x80, 0x01]), Data.encodeLength(2097152))
    }

    func testCreatingTransfer() throws {
        let compiled = [UInt8]([2, 2, 0, 1, 12, 2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0])
        var receiver = [UInt8]()
        let data = SolanaSDK.Transfer.compile()
        receiver.append(contentsOf: data)
        XCTAssertEqual(compiled, receiver)
    }
    
    func testSignAndSerialize() throws {
        let serializedTransaction = try TestHelper.testingSerializedTransaction()
        XCTAssertEqual("ASdDdWBaKXVRA+6flVFiZokic9gK0+r1JWgwGg/GJAkLSreYrGF4rbTCXNJvyut6K6hupJtm72GztLbWNmRF1Q4BAAEDBhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQzrerzQ2HXrwm2hsYGjM5s+8qMWlbt6vbxngnO8rc3lqgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAy+KIwZmU8DLmYglP3bPzrlpDaKkGu6VIJJwTOYQmRfUBAgIAAQwCAAAAuAsAAAAAAAA=", serializedTransaction)
    }
}
