//
//  SerumSwapError.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/08/2021.
//

import Foundation

enum SerumSwapError: Error {
    case unknown
    case openOrdersLayoutIsInvalid
    case addressIsNotOwnedByTheProgram
    case invalidOpenOrdersAccount
}
