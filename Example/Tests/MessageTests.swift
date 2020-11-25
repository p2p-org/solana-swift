//
//  MessageTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class MessageTests: XCTestCase {
    func testSerializeMessage() throws {
        let fromPublicKey = try SolanaSDK.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        let toPublicKey = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        let lamports = Int64(3000)
        
        var message = SolanaSDK.Message()
        message.add(instruction: SolanaSDK.SystemProgram.transfer(from: fromPublicKey, to: toPublicKey, lamports: lamports))
        message.recentBlockhash = "Eit7RCyhUixAe2hGBS8oqnw59QK3kgMMjfLME5bm9wRn"
        
        XCTAssertEqual([1, 0, 1, 3, 6, 26, 217, 208, 83, 135, 21, 72, 83, 126, 222, 62, 38, 24, 73, 163, 223, 183, 253, 2, 250, 188, 117, 178, 35, 200, 228, 106, 219, 133, 61, 12, 235, 122, 188, 208, 216, 117, 235, 194, 109, 161, 177, 129, 163, 51, 155, 62, 242, 163, 22, 149, 187, 122, 189, 188, 103, 130, 115, 188, 173, 205, 229, 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 203, 226, 136, 193, 153, 148, 240, 50, 230, 98, 9, 79, 221, 179, 243, 174, 90, 67, 104, 169, 6, 187, 165, 72, 36, 156, 19, 57, 132, 38, 69, 245, 1, 2, 2, 0, 1, 12, 2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0], try message.serialize())
    }
}
