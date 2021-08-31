//
//  SerumSwap+Instructions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 18/08/2021.
//

import Foundation

/// https://github.com/p2p-org/serum-rs/blob/master/src/instruction.rs
extension SerumSwap {
    static let staticBytes = UInt64(14449647541112719096) // ? UNKNOWN: got from anchor's tx
    
    // MARK: - Orders
    static func closeOrderInstruction(
        order: PublicKey,
        marketAddress: PublicKey,
        owner: PublicKey,
        destination: PublicKey
    ) -> TransactionInstruction {
        .init(
            keys: [
                .init(publicKey: order, isSigner: false, isWritable: true), // open_orders
                .init(publicKey: owner, isSigner: true, isWritable: false), // authority
                .init(publicKey: destination, isSigner: false, isWritable: true), // destination
                .init(publicKey: marketAddress, isSigner: false, isWritable: false), // market
                .init(publicKey: .dexPID, isSigner: false, isWritable: false), // dex_program_id
            ],
            programId: .serumSwapPID,
            data: []
        )
    }
    
    // https://github.com/p2p-org/serum-rs/blob/master/src/instruction.rs#L40-L59
    static func initOrderInstruction(
        order: PublicKey,
        marketAddress: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction {
        .init(
            keys: [
                .init(publicKey: order, isSigner: false, isWritable: true), // open_orders
                .init(publicKey: owner, isSigner: true, isWritable: false), // authority
                .init(publicKey: marketAddress, isSigner: false, isWritable: false), // market
                .init(publicKey: .dexPID, isSigner: false, isWritable: false), // dex_program_id
                .init(publicKey: .sysvarRent, isSigner: false, isWritable: false), // sysvar::rent::id()
            ],
            programId: .serumSwapPID,
            data: []
        )
    }
    
    // MARK: - Swap
    static func directSwapInstruction(
        authority: PublicKey,
        side: Side,
        amount: Lamports,
        minExchangeRate: ExchangeRate,
        market: Market,
        vaultSigner: PublicKey,
        openOrders: PublicKey,
        pcWallet: PublicKey,
        coinWallet: PublicKey,
        referral: PublicKey?
    ) -> TransactionInstruction {
        .init(
            keys: [
                .init(publicKey: market.address, isSigner: false, isWritable: true),
                .init(publicKey: openOrders, isSigner: false, isWritable: true),
                .init(publicKey: market.requestQueue, isSigner: false, isWritable: true),
                .init(publicKey: market.eventQueue, isSigner: false, isWritable: true),
                .init(publicKey: market.bidsAddress, isSigner: false, isWritable: true),
                .init(publicKey: market.asksAddress, isSigner: false, isWritable: true),
                .init(publicKey: side == .bid ? pcWallet: coinWallet, isSigner: false, isWritable: true), // market.order_payer_token_account
                .init(publicKey: market.coinVault, isSigner: false, isWritable: true),
                .init(publicKey: market.pcVault, isSigner: false, isWritable: true),
                .init(publicKey: vaultSigner, isSigner: false, isWritable: false),
                .init(publicKey: coinWallet, isSigner: false, isWritable: true),
                .init(publicKey: authority, isSigner: true, isWritable: false),
                .init(publicKey: pcWallet, isSigner: false, isWritable: true),
                .init(publicKey: .dexPID, isSigner: false, isWritable: false),
                .init(publicKey: .tokenProgramId, isSigner: false, isWritable: false),
                .init(publicKey: .tokenProgramId, isSigner: false, isWritable: false)
            ],
            programId: .serumSwapPID,
            data: [
                staticBytes,
                side.byte,
                amount,
                minExchangeRate
            ]
        )
    }
    
    static func transitiveSwapInstruction(
        authority: PublicKey,
        fromMarket: Market,
        toMarket: Market,
        fromVaultSigner: PublicKey,
        toVaultSigner: PublicKey,
        fromOpenOrder: PublicKey,
        toOpenOrder: PublicKey,
        fromWallet: PublicKey,
        toWallet: PublicKey,
        amount: Lamports,
        minExchangeRate: ExchangeRate,
        pcWallet: PublicKey,
        referral: PublicKey?
    ) -> TransactionInstruction {
        .init(
            keys: [
                .init(publicKey: fromMarket.address, isSigner: false, isWritable: true),
                .init(publicKey: fromOpenOrder, isSigner: false, isWritable: true),
                .init(publicKey: fromMarket.requestQueue, isSigner: false, isWritable: true),
                .init(publicKey: fromMarket.eventQueue, isSigner: false, isWritable: true),
                .init(publicKey: fromMarket.bidsAddress, isSigner: false, isWritable: true),
                .init(publicKey: fromMarket.asksAddress, isSigner: false, isWritable: true),
                .init(publicKey: fromWallet, isSigner: false, isWritable: true), // from.order_payer_token_account
                .init(publicKey: fromMarket.coinVault, isSigner: false, isWritable: true),
                .init(publicKey: fromMarket.pcVault, isSigner: false, isWritable: true),
                .init(publicKey: fromVaultSigner, isSigner: false, isWritable: false),
                .init(publicKey: fromWallet, isSigner: false, isWritable: true),
                .init(publicKey: toMarket.address, isSigner: false, isWritable: true),
                .init(publicKey: toOpenOrder, isSigner: false, isWritable: true),
                .init(publicKey: toMarket.requestQueue, isSigner: false, isWritable: true),
                .init(publicKey: toMarket.eventQueue, isSigner: false, isWritable: true),
                .init(publicKey: toMarket.bidsAddress, isSigner: false, isWritable: true),
                .init(publicKey: toMarket.asksAddress, isSigner: false, isWritable: true),
                .init(publicKey: fromWallet, isSigner: false, isWritable: true), // to.order_payer_token_account
                .init(publicKey: toMarket.coinVault, isSigner: false, isWritable: true),
                .init(publicKey: toMarket.pcVault, isSigner: false, isWritable: true),
                .init(publicKey: toVaultSigner, isSigner: false, isWritable: false),
                .init(publicKey: toWallet, isSigner: false, isWritable: true),
                .init(publicKey: authority, isSigner: true, isWritable: false),
                .init(publicKey: pcWallet, isSigner: false, isWritable: true),
                .init(publicKey: .dexPID, isSigner: false, isWritable: false),
                .init(publicKey: .tokenProgramId, isSigner: false, isWritable: false),
                .init(publicKey: .tokenProgramId, isSigner: false, isWritable: false),
            ],
            programId: .serumSwapPID,
            data: [
                staticBytes,
                amount,
                minExchangeRate
            ]
        )
    }
}
