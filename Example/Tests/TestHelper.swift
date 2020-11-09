//
//  TestHelper.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/9/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SolanaSwift

struct TestHelper {
    static func testingSerializedTransaction() throws -> String {
        let fromPublicKey = try SolanaSDK.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        let toPublicKey = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        let lamports: Int64 = 3000
        
        let signer = try SolanaSDK.Account(secretKey: Data(bytes: Base58.bytesFromBase58("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")))
        
        var transaction = SolanaSDK.Transaction()
        transaction.message.add(instruction: SolanaSDK.SystemProgram.transfer(from: fromPublicKey, to: toPublicKey, lamports: lamports))
        transaction.message.recentBlockhash = "Eit7RCyhUixAe2hGBS8oqnw59QK3kgMMjfLME5bm9wRn"
        try transaction.sign(signer: signer)
        return try transaction.serialize().toBase64()!
    }
}
