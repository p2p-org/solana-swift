//
//  p2p_walletTests.swift
//  p2p walletTests
//
//  Created by Chung Tran on 10/22/20.
//

import XCTest
import SolanaSwift

class AccountTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSeed() throws {
        let mnemonic = try Mnemonic(phrase: "ordinary cover language pole achieve pause focus core sing lady zoo fix".components(separatedBy: " "))
        let seed = mnemonic.seed
        XCTAssertEqual(seed.toHexString(), "95b0b004517ede8c3bd09659b5767045086d421f16874db281a4e068f510e3f85d23e92b1d9d748bdb8cebeb06f64f72dae6fc750c15a8e6c7fa7e67165ef9bb")
//        XCTAssertEqual(account.publicKey, "C7PLa6JhGaqFwuhtMXxtjYiV1CkzVrTvqusQ12D1cY4F")
    }
    
    func testCreateAccount() throws {
        let account = try SolanaSDK.Account(phrase: "ordinary cover language pole achieve pause focus core sing lady zoo fix".components(separatedBy: " "))
        XCTAssertEqual(account.publicKey.base58EncodedString, "C7PLa6JhGaqFwuhtMXxtjYiV1CkzVrTvqusQ12D1cY4F")
    }
}
