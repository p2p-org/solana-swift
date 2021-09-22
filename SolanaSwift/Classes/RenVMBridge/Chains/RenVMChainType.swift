//
//  RenVMChainType.swift
//  Action
//
//  Created by Chung Tran on 17/09/2021.
//

import Foundation
import RxSwift

public protocol RenVMChainType {
    var chainName: String {get}
    func getAssociatedTokenAddress(
        address: Data,
        mintTokenSymbol: String
    ) throws -> Data // represent as data, because there might be different encoding methods for various of chains
    func dataToAddress(
        data: Data
    ) throws -> String
    
    func signatureToData(
        signature: String
    ) throws -> Data
    
    func submitMint(
        address: Data,
        mintTokenSymbol: String,
        signer: Data,
        responceQueryMint: RenVM.ResponseQueryTxMint
    ) -> Single<String>
    
    func submitBurn(
        mintTokenSymbol: String,
        account: Data,
        amount: String,
        recipient: String,
        signer: Data
    ) -> Single<RenVM.BurnAndRelease.BurnDetails>
}

extension RenVMChainType {
    func selector(mintTokenSymbol: String, direction: RenVM.Selector.Direction) -> RenVM.Selector {
        .init(mintTokenSymbol: mintTokenSymbol, chainName: chainName, direction: direction)
    }
}
