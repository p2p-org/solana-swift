//
//  TokenSwapProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/01/2021.
//

import Foundation

extension SolanaSDK {
    struct TokenSwapProgram {
        public static func initialize(
            tokenSwapAccount: PublicKey,
            authority: PublicKey,
            tokenAccountA: PublicKey,
            tokenAccountB: PublicKey,
            tokenPool: PublicKey,
            feeAccount: PublicKey,
            tokenAccountPool: PublicKey,
            tokenProgramId: PublicKey,
            swapProgramId: PublicKey,
            nonce: UInt8,
            curveType: UInt8,
            tradeFeeNumerator: BInt,
            tradeFeeDenominator: BInt,
            ownerTradeFeeNumerator: BInt,
            ownerTradeFeeDenominator: BInt,
            ownerWithdrawFeeNumerator: BInt,
            ownerWithdrawFeeDenominator: BInt,
            hostFeeNumerator: BInt,
            hostFeeDenominator: BInt
        ) -> TransactionInstruction {
            let keys = [
                Account.Meta(publicKey: tokenSwapAccount, isSigner: false, isWritable: true),
                Account.Meta(publicKey: authority, isSigner: false, isWritable: false),
                Account.Meta(publicKey: authority, isSigner: false, isWritable: false),
                Account.Meta(publicKey: tokenAccountA, isSigner: false, isWritable: false),
                Account.Meta(publicKey: tokenAccountB, isSigner: false, isWritable: false),
                Account.Meta(publicKey: tokenPool, isSigner: false, isWritable: true),
                Account.Meta(publicKey: feeAccount, isSigner: false, isWritable: false),
                Account.Meta(publicKey: tokenAccountPool, isSigner: false, isWritable: true),
                Account.Meta(publicKey: tokenProgramId, isSigner: false, isWritable: false)
            ]
        }
    }
}

extension SolanaSDK.TokenSwapProgram {
    // MARK: - Nested type
    enum TransactionType: UInt32 {
        case initialize = 0
        case index = 1
        case deposit = 2
        case withdraw = 3
    }
}
