//
//  SolanaSDK+Close.swift
//  SolanaSwift
//
//  Created by Chung Tran on 02/02/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func closeToken(publicKey: String) -> Single<TransactionID> {
        guard let account = accountStorage.account,
              let publicKey = try? PublicKey(string: publicKey)
        else {return .error(Error.accountNotFound)}
        var transaction = Transaction()
        transaction.closeAccount(publicKey, destination: account.publicKey, owner: account.publicKey)
        return serializeTransaction(transaction, signers: [account])
            .flatMap {self.sendTransaction(serializedTransaction: $0)}
    }
}
