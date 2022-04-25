//
//  SystemProgramTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 25/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class SystemProgramTests: XCTestCase {
    func testTransferInstruction() throws {
        let fromPublicKey = try SolanaSDK.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        let toPublicKey = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        
        let instruction = SolanaSDK.SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: 3000)
        
        XCTAssertEqual(SolanaSDK.PublicKey.programId, instruction.programId)
        XCTAssertEqual(2, instruction.keys.count)
        XCTAssertEqual(toPublicKey, instruction.keys[1].publicKey)
        XCTAssertEqual([2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0], instruction.data)
    }
    
    func testCreateAccountInstruction() throws {
        let instruction = SolanaSDK.SystemProgram.createAccountInstruction(from: SolanaSDK.PublicKey.programId, toNewPubkey: SolanaSDK.PublicKey.programId, lamports: 2039280, space: 165, programPubkey: SolanaSDK.PublicKey.programId)
        
        XCTAssertEqual("11119os1e9qSs2u7TsThXqkBSRUo9x7kpbdqtNNbTeaxHGPdWbvoHsks9hpp6mb2ed1NeB", Base58.encode(instruction.data))
    }
}
