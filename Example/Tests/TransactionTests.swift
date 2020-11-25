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
    
    func testSignAndSerializeTransfer() throws {
        let fromPublicKey = try SolanaSDK.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        let toPublicKey = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        let lamports: UInt64 = 3000
        
        let signer = try SolanaSDK.Account(secretKey: Data(Base58.decode("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")))
        
        var transaction = SolanaSDK.Transaction()
        transaction.message.add(instruction: SolanaSDK.SystemProgram.transfer(from: fromPublicKey, to: toPublicKey, lamports: lamports))
        transaction.message.recentBlockhash = "Eit7RCyhUixAe2hGBS8oqnw59QK3kgMMjfLME5bm9wRn"
        try transaction.sign(signer: signer)
        let serializedTransaction = try transaction.serialize().toBase64()!
        
        XCTAssertEqual("ASdDdWBaKXVRA+6flVFiZokic9gK0+r1JWgwGg/GJAkLSreYrGF4rbTCXNJvyut6K6hupJtm72GztLbWNmRF1Q4BAAEDBhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQzrerzQ2HXrwm2hsYGjM5s+8qMWlbt6vbxngnO8rc3lqgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAy+KIwZmU8DLmYglP3bPzrlpDaKkGu6VIJJwTOYQmRfUBAgIAAQwCAAAAuAsAAAAAAAA=", serializedTransaction)
    }
    
    func testSignAndSerializeCreate() throws {
        // create new account for token
        let account = try SolanaSDK.Account(phrase: "village wealth begin kit desk rely employ wild ability country game click".components(separatedBy: " "), network: "mainnet-beta")
        let newAccount = try SolanaSDK.PublicKey(string: "HmeybTRHpBjfjgaYDG4wtZGrpwrCVMWpA58fjJppaPkg")
        let programPubkey = try SolanaSDK.PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        
        // forming transaction
        var transaction = SolanaSDK.Transaction()
        transaction.message.add(instruction: SolanaSDK.SystemProgram.createAccount(from: account.publicKey, toNewPubkey: newAccount, lamports: 2039280, programPubkey: programPubkey))
        transaction.message.add(instruction: try SolanaSDK.Transaction.Instruction.account(newAccount, mint: try SolanaSDK.PublicKey(string: "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk"), owner: account.publicKey, programPubkey: programPubkey))
        transaction.message.recentBlockhash = "JAQiEMPid1xJnNUBh4xxdKxRLnxja2sBRbEFCchandTH"
        try transaction.sign(signer: account)
        
        guard let serializedTransaction = try transaction.serialize().toBase64() else {
            throw SolanaSDK.Error.other("Could not serialize transaction")
        }
        XCTAssertEqual("AhbUHO/J+Rh/3v36tNjvw1e9XhR9bVR8OjFRv+7GFvBx/IzJMK7CHWLyNCkR4lWkkyuSlmCXHhmf/WyKfRBdPgEKHmPQPXxODWS6HF11Pj/fVT/k+5oDLA0g9Sp3MhVnGmhIABhfZIlE0PFJHnugAFqnotrtKkXmJoMTmMmiB2ABAgAEBvhKE7W8bXddL85iO5zhtgQdo0on/MP88pES9rX2QyHB+St8WhCYvRUffh0XFv9wpxJZI+OHLhiTJWuRpjiPz7USi8tkfYutHnJQ47g0vPqf2Yb01HfRu7kFTmArEevgYQan1RcZLFxRIYzJTD1K8X9Y2u4Im6H9ROPb2YoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8Aqf7/twmimy5jXqh/Rd7CGGzSD+9lf4qrk8iCAzGOSD5cAgQCAAE0AAAAAPAdHwAAAAAApQAAAAAAAAAG3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqQUEAQIAAwEB", serializedTransaction)
    }
}
