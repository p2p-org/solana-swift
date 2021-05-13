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
            
            let instruction = TokenProgram.closeAccountInstruction(
                account: tokenPubkey,
                destination: account.publicKey,
                owner: account.publicKey
            )
            
            return serializeAndSendWithFee(instructions: [instruction], signers: [account], isSimulation: isSimulation)
        } catch {
            return .error(error)
        }
    }
}
