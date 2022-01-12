//
//  OrcaSwapFeesModel.swift
//  SolanaSwift
//
//  Created by Andrew Vasiliev on 11.01.2022.
//

public struct OrcaSwapFeesModel {
    public let transactionFees: UInt64
    public let accountCreationFee: UInt64?
    public let liquidityProviderFees: [UInt64]
}
