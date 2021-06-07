//
//  SolanaSDK+Close.swift
//  SolanaSwift
//
//  Created by Chung Tran on 24/02/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func closeTokenAccount(
        tokenPubkey: String,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        getCurrentAccount()
            .flatMap {account in
                let tokenPubkey = try PublicKey(string: tokenPubkey)
                
                let instruction = TokenProgram.closeAccountInstruction(
                    account: tokenPubkey,
                    destination: account.publicKey,
                    owner: account.publicKey
                )
                
                return self.serializeAndSendWithFee(instructions: [instruction], signers: [account], isSimulation: isSimulation)
            }
    }
}
