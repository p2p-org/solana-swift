//
//  RenVM+BurnAndRelease.swift
//  SolanaSwift
//
//  Created by Chung Tran on 14/09/2021.
//

import Foundation

extension RenVM {
    public class BurnAndRelease {
        // MARK: - Dependencies
        let rpcClient: RenVMRpcClientType
        let chain: RenVMChainType
        let mintTokenSymbol: String
        let version: String
        let recipient: String
        
        // MARK: - State
        var state = State()
        var nonceBuffer = Data()
        
        // MARK: - Initializer
        init(
            rpcClient: RenVMRpcClientType,
            chain: RenVMChainType,
            mintTokenSymbol: String,
            version: String,
            recipient: String
        ) {
            self.rpcClient = rpcClient
            self.chain = chain
            self.mintTokenSymbol = mintTokenSymbol
            self.version = version
            self.recipient = recipient
        }
        
//        func submitBurnTransaction(account: SolanaSDK.PublicKey, amount: String, recipient: String, signer: SolanaSDK.PublicKey)
    }
}
