//
//  Instructions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/04/2021.
//

import Foundation

public protocol SolanaSDKInstructionType: Decodable {
    var programId: String {get}
}
