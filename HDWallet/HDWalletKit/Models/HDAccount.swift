//
//  Account.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 04.07.18.
//

import Foundation

public struct HDAccount {
    
    public init(privateKey: HDPrivateKey) {
        self.privateKey = privateKey
    }
    
    public let privateKey: HDPrivateKey
    
    public var rawPrivateKey: String {
        return privateKey.get()
    }
    
    public var rawPublicKey: String {
        return privateKey.publicKey.get()
    }
    
    public var address: String {
        return privateKey.publicKey.address
    }
}
