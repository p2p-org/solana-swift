//
//  File.swift
//
//
//  Created by Giang Long Tran on 13.01.2023.
//

import Foundation

protocol IMessage {
    var version: TransactionVersion { get }
    var header: MessageHeader { get }

    func serialize() throws -> Data
    
    var staticAccountKeys: [PublicKey] { get }
}
