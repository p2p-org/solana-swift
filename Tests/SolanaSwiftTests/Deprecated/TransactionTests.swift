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
    func testCreatingTransfer() throws {
        let compiled = [UInt8]([2, 2, 0, 1, 12, 2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0])
        var receiver = [UInt8]()
        let data = SolanaSDK.Transfer.compile()
        receiver.append(contentsOf: data)
        XCTAssertEqual(compiled, receiver)
    }
    
    func testParsingTransaction() throws {
        let dataStr = "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAED4MQ2/ozgrYeTBlWsjcAfmZIxSjTy6NTV58f3AU2/orO47qr09DsGynz1aWlHXRwu629TuLT7Nmo+mV3k3pzCVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAxlZJpdn2LZr4n671TH3jHDuKJFC1Utk/eiayiy0R3u4BAgIAAQwCAAAAgJaYAAAAAAA="
        let data = Data(base64Encoded: dataStr)!
        let transaction = try SolanaSDK.Transaction.from(data: data)
        
        XCTAssert(transaction.signatures[0].publicKey.base58EncodedString == "G8PrkEwmVx3kt3rXBin5o1bdDC1cvz7oBnXbHksNg7R4")
        XCTAssert(transaction.signatures[0].signature == nil)
        
        XCTAssert(transaction.feePayer?.base58EncodedString == "G8PrkEwmVx3kt3rXBin5o1bdDC1cvz7oBnXbHksNg7R4")
        
        XCTAssert(transaction.recentBlockhash == "EME3Aty21v8HmNUf8ArVSSWbSzULBajdMTqHqfKHn4pM")
        
        XCTAssert(transaction.instructions.count == 1)
        XCTAssert(transaction.instructions[0].programId.base58EncodedString == "11111111111111111111111111111111")
        
        XCTAssert(transaction.instructions[0].keys.count == 2)
        XCTAssert(transaction.instructions[0].keys[0].isSigner == true)
        XCTAssert(transaction.instructions[0].keys[0].isWritable == true)
        XCTAssert(transaction.instructions[0].keys[0].publicKey.base58EncodedString == "G8PrkEwmVx3kt3rXBin5o1bdDC1cvz7oBnXbHksNg7R4")
        XCTAssert(transaction.instructions[0].keys[1].isSigner == false)
        XCTAssert(transaction.instructions[0].keys[1].isWritable == true)
        XCTAssert(transaction.instructions[0].keys[1].publicKey.base58EncodedString == "DSu6XvmzTnxK7i5qghoyw7byBFEnVDqiFrD86vSa7HMm")
    }
    
    func testSerializeMessage() throws {
        let dataStr = "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAED4MQ2/ozgrYeTBlWsjcAfmZIxSjTy6NTV58f3AU2/orO47qr09DsGynz1aWlHXRwu629TuLT7Nmo+mV3k3pzCVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAxlZJpdn2LZr4n671TH3jHDuKJFC1Utk/eiayiy0R3u4BAgIAAQwCAAAAgJaYAAAAAAA="
        
        var data = Data(base64Encoded: dataStr)!
        var transaction = try SolanaSDK.Transaction.from(data: data)
        var serializedMessage = try transaction.serialize().base64EncodedString()
        print("+++")
        print(serializedMessage)
        
        
        data = Data(base64Encoded: serializedMessage)!
        transaction = try SolanaSDK.Transaction.from(data: data)
        serializedMessage = try transaction.serialize().base64EncodedString()
        print("+++")
        print(serializedMessage)
        
        print("++++++++")
        print(transaction.signatures.count)
        print(serializedMessage)
        
        transaction = try SolanaSDK.Transaction.from(data: Data(base64Encoded: serializedMessage)!)
        
        XCTAssert(dataStr == serializedMessage)
    }

//    func testSerializeMessage() throws {
//        let fromPublicKey = try SolanaSDK.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
//        let toPublicKey = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
//        let lamports: UInt64 = 3000
//
//        var message = SolanaSDK.ConfirmedTransaction.Message()
//        message.add(instruction: SolanaSDK.SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: lamports))
//        message.recentBlockhash = "Eit7RCyhUixAe2hGBS8oqnw59QK3kgMMjfLME5bm9wRn"
//
//        XCTAssertEqual([1, 0, 1, 3, 6, 26, 217, 208, 83, 135, 21, 72, 83, 126, 222, 62, 38, 24, 73, 163, 223, 183, 253, 2, 250, 188, 117, 178, 35, 200, 228, 106, 219, 133, 61, 12, 235, 122, 188, 208, 216, 117, 235, 194, 109, 161, 177, 129, 163, 51, 155, 62, 242, 163, 22, 149, 187, 122, 189, 188, 103, 130, 115, 188, 173, 205, 229, 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 203, 226, 136, 193, 153, 148, 240, 50, 230, 98, 9, 79, 221, 179, 243, 174, 90, 67, 104, 169, 6, 187, 165, 72, 36, 156, 19, 57, 132, 38, 69, 245, 1, 2, 2, 0, 1, 12, 2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0], try message.serialize())
//    }
//    
//    func testSignAndSerializeTransfer() throws {
//        let fromPublicKey = try SolanaSDK.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
//        let toPublicKey = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
//        let lamports: UInt64 = 3000
//
//        let signer = try SolanaSDK.Account(secretKey: Data(Base58.decode("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")))
//
//        var transaction = SolanaSDK.ConfirmedTransaction()
//        transaction.add(instruction: SolanaSDK.SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: lamports))
//        transaction.set(recentBlockhash: "Eit7RCyhUixAe2hGBS8oqnw59QK3kgMMjfLME5bm9wRn")
//        try transaction.sign(signers: [signer])
//        let serializedTransaction = try transaction.serialize().toBase64()!
//
//        XCTAssertEqual("ASdDdWBaKXVRA+6flVFiZokic9gK0+r1JWgwGg/GJAkLSreYrGF4rbTCXNJvyut6K6hupJtm72GztLbWNmRF1Q4BAAEDBhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQzrerzQ2HXrwm2hsYGjM5s+8qMWlbt6vbxngnO8rc3lqgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAy+KIwZmU8DLmYglP3bPzrlpDaKkGu6VIJJwTOYQmRfUBAgIAAQwCAAAAuAsAAAAAAAA=", serializedTransaction)
//    }
    
}
