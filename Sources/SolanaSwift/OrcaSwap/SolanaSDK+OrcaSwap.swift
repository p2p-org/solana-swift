//
//  File.swift
//  
//
//  Created by Chung Tran on 18/10/2021.
//

import Foundation
import RxSwift

extension SolanaSDK: OrcaSwapSolanaClient {
    public func prepareCreatingWSOLAccountAndCloseWhenDone(owner: OrcaSwap.PublicKey, amount: UInt64, accountRentExempt: UInt64?) -> Single<AccountInstructions> {
        <#code#>
    }
    
    public func prepareCreatingAssociatedTokenAccount(owner: OrcaSwap.PublicKey, tokenMint: OrcaSwap.PublicKey) -> Single<AccountInstructions> {
        <#code#>
    }
}
extension SolanaSDK: OrcaSwapAccountProvider {}
extension SolanaSDK: OrcaSwapSignatureConfirmationHandler {}
