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
        account: SolanaSDK.Account? = nil,
        tokenPubkey: String,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        guard let account = account ?? accountStorage.account else {
            return .error(Error.unauthorized)
        }
        do {
            let tokenPubkey = try PublicKey(string: tokenPubkey)
            
            var transaction = Transaction()
            transaction.closeAccount(tokenPubkey, destination: account.publicKey, owner: account.publicKey)
            return serializeAndSend(transaction: transaction, signers: [account], isSimulation: isSimulation) { (keys) -> [Account.Meta] in
                var accountKeys: [Account.Meta] = keys.sorted { (lhs, rhs) -> Bool in
                    if lhs.isSigner != rhs.isSigner {return !lhs.isSigner}
                    if lhs.isWritable != rhs.isWritable {return !lhs.isWritable}
                    return false
                }.reversed()
                var feePayer = accountKeys.removeFirst()
                feePayer.isSigner = true
                feePayer.isWritable = true
                accountKeys.insert(feePayer, at: 0)
                return accountKeys
            }
        } catch {
            return .error(error)
        }
    }
}
