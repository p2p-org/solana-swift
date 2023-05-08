//
//  File.swift
//  
//
//  Created by Chung Tran on 08/05/2023.
//

import Foundation

extension AccountInstructions {
    @available(*, deprecated, message: "use AccountInstructions.init(account:instructions:cleanupInstructions:signers:newTokenAccountPubkey:secretKey) instead")
    public init(
        account: PublicKey,
        instructions: [TransactionInstruction] = [],
        cleanupInstructions: [TransactionInstruction] = [],
        signers: [KeyPair] = [],
        newWalletPubkey: String? = nil,
        secretKey: Data? = nil
    ) {
        self.init(
            account: account,
            instructions: instructions,
            cleanupInstructions: cleanupInstructions,
            signers: signers,
            newTokenAccountPubkey: newWalletPubkey,
            secretKey: secretKey
        )
    }
    
    @available(*, deprecated, renamed: "newTokenAccountPubkey")
    public var newWalletPubkey: String? {
        newTokenAccountPubkey
    }
}
