//
//  SerumSwap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift

protocol SerumSwapClient {
    
}

extension SolanaSDK {
    class SerumSwap {
        // MARK: - Properties
        let client: SerumSwapClient
        
        // MARK: - Initializers
        init(client: SerumSwapClient) {
            self.client = client
        }
        
        /**
         * Sends a transaction to initialize all accounts required for a swap between
         * the two mints. I.e., creates the DEX open orders accounts.
         *
         * @throws if all open orders accounts already exist.
         */
        public func initAccounts(from: PublicKey, to: PublicKey, feePayer: PublicKey, recentBlockhash: String) -> Single<PublicKey> {
            
            var signers = [Account]()
            var transaction = Transaction()
            
            
        }
    }
}
