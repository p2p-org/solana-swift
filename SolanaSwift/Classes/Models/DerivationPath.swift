//
//  DerivationPath.swift
//  SolanaSwift
//
//  Created by Chung Tran on 06/05/2021.
//

import Foundation

extension SolanaSDK {
    enum DerivationPath: String {
        case deprecated     = "m/501'/0'/0/0"
        case bip44          = "m/44'/501'/0'/0'"
    }
}
