//
//  RenVM+State.swift
//  SolanaSwift
//
//  Created by Chung Tran on 14/09/2021.
//

import Foundation

extension RenVM {
    public struct State {
        public var gHash: Data?
        public var gPubKey: Data?
        public var sendTo: String? // PublicKey
        public var txid: Data?
        public var nHash: Data?
        public var pHash: Data?
        public var txHash: String?
        public var txIndex: String?
        public var amount: String?
    }
}
