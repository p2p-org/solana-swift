//
//  FeeRelayer+Models.swift
//  SolanaSwift
//
//  Created by Chung Tran on 12/05/2021.
//

import Foundation

protocol SolanaFeeRelayerTransferParams: Encodable {
    var sender: String {get}
    var recipient: String {get}
    var amount: SolanaSDK.Lamports {get}
}

extension SolanaSDK.FeeRelayer {
    struct TransferSolParams: SolanaFeeRelayerTransferParams {
        let sender: String
        let recipient: String
        let amount: SolanaSDK.Lamports
        
        enum CodingKeys: String, CodingKey {
            case sender     =   "sender_pubkey"
            case recipient  =   "recipient_pubkey"
            case amount     =   "lamports"
        }
    }
    
    struct TransferSPLTokenParams: SolanaFeeRelayerTransferParams {
        let sender: String
        let recipient: String
        let mintAddress: String
        let authority: String
        let amount: SolanaSDK.Lamports
        let decimals: SolanaSDK.Decimals
        
        enum CodingKeys: String, CodingKey {
            case sender         =   "sender_token_account_pubkey"
            case recipient      =   "recipient_pubkey"
            case mintAddress    =   "token_mint_pubkey"
            case authority      =   "authority_pubkey"
            case amount
            case decimals
        }
    }
    
    struct InstructionsAndParams {
        let instructions: [SolanaSDK.TransactionInstruction]
        let transferParams: SolanaFeeRelayerTransferParams
        let path: String
    }
}
