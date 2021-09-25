//
//  RenVMRenProgramTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 13/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class RenVMRenProgramTests: XCTestCase {
    func testCreateInstructionWithEthAddress2() throws {
        let ethAddress = Base58.decode("xYC479LDEE556R1CtbXsoZStA9y")
        let message = Base58
            .decode("71nK5AmnXQVYxHsA1JCF96MUuTxkgUKfXRPX97EZ5D41c8VFDyDeMunKmVp5tFbVfWNLg9S9W3Z5wKy2ZhYeMW4HJQV1tvnbizp5jM3E1wNVrvDJAcBS6xoMEMoVasZDJgvtmHtcSKNMRTJTzCf5ZBimkvdBKX9V9w81Bn8TX8apojeJQGKK3XMtAeoJWTwKqorTdewKQYwVg7iqn5xE5B1zgMy")
        let signature = Base58
            .decode("45fWmpxgZEsWN7eHxQ6i3KCxpE7eQDpfUJ7qawW3eAyKzt4Zx9wZWM6iPz75TR7BPwfjkrjDeBQghFku6ySUEZ6j")
        let recoveryId: UInt8 = 0
        
        let instruction = RenVM.SolanaChain.RenProgram.createInstructionWithEthAddress2(ethAddress: Data(ethAddress), message: Data(message), signature: Data(signature), recoveryId: recoveryId)
        XCTAssertEqual(instruction.data.toHexString(), "012100010d00016200a000010044bb4ef43408072bc888afd1a5986ba0ce35cb549a12b4cef7faaa82fbd78e48797364be8763b2558dc51fe57d0f1c774f6759c345335373d7b4ce8d8799b05b27a6846c7ec40e54cd8a11cfac3cb8a85e70c3a400c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47000000000000000000000000000000000000000000000000000000000000023e216ac6fb8b800ff9e24220479d69d38b59a077966f500c7bbd3435dad78d8fc0234cef1aee9a983b47366dddb37f5327263737f3551cf4ce30125668c41331a802f590f165eb3330fe4ffa55ce86664b2b2de4f6e7044e166c1b444cb396ff4e4")
    }
    
    func testBurnInstruction() throws {
        let publicKey: SolanaSDK.PublicKey = "11111111111111111111111111111111"
        let recipient = "tb1ql7w62elx9ucw4pj5lgw4l028hmuw80sndtntxt".bytes
        let instruction = RenVM.SolanaChain.RenProgram.burnInstruction(
            account: publicKey,
            source: publicKey,
            gatewayAccount: publicKey,
            tokenMint: publicKey,
            burnLogAccountId: publicKey,
            recipient: Data(recipient),
            programId: publicKey
        )
        
        XCTAssertEqual(instruction.data.toHexString(), "022a746231716c37773632656c783975637734706a356c6777346c303238686d75773830736e64746e747874")
    }
}
