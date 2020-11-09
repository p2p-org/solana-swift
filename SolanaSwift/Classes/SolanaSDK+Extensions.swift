//
//  SolanaSDK+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/9/20.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func send(to toPublicKey: String, amount: Int64) -> Single<String> {
        getRecentBlockhash()
            .map {$0.blockhash}
            .map { recentBlockhash -> String in
                if recentBlockhash == nil {
                    throw Error.other("Could not retrieve recent blockhash")
                }
                return recentBlockhash!
            }
            .flatMap { recentBlockhash in
                guard let account = self.accountStorage.account else {
                    throw Error.publicKeyNotFound
                }
                let toPublicKey = try PublicKey(string: toPublicKey)
                let signer = self.accountStorage.account!
                
                var transaction = Transaction()
                transaction.message.add(instruction: SystemProgram.transfer(from: account.publicKey, to: toPublicKey, lamports: amount))
                transaction.message.recentBlockhash = recentBlockhash
                try transaction.sign(signer: signer)
                guard let serializedTransaction = try transaction.serialize().toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return self.sendTransaction(serializedTransaction: serializedTransaction)
            }
    }
}
