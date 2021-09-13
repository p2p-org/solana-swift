//
//  RenVM+Models.swift
//  SolanaSwift
//
//  Created by Chung Tran on 12/09/2021.
//

import Foundation

extension RenVM {
    public struct ResponseQueryTxMint: Decodable {
        
    }

    public struct ResponseQueryBlockState: Decodable {
        public let state: State
        public var shards: [Shard] {
            state.v.btc.shards
        }
        public var publicKey: String? {
            shards.first?.pubKey
        }
        
        public struct State: Decodable {
            public let v: Values
        }
        
        public struct Values: Decodable {
            public let btc: Btc
        }
        
        public struct Btc: Decodable {
            public let fees: Fees
            public let gasCap: String
            public let gasLimit: String
            public let gasPrice: String
            public let latestHeight: String
            public let minimumAmount: String
            public let shards: [Shard]
        }
        
        public struct Fees: Decodable {
            public let chains: [Chain]
        }
        
        public struct Chain: Decodable {
            public let burnFee: String
            public let chain: String
            public let mintFee: String
        }
        
        public struct Shard: Decodable {
            public let pubKey: String
            public let shard: String
            public let state: ShardState
        }
        
        public struct ShardState: Decodable {
            public let outpoint: Outpoint
            public let pubKeyScript: String
            public let value: String
        }
        
        public struct Outpoint: Decodable {
            public let hash: String
            public let index: String
        }
    }
    
    public struct ResponseQueryConfig: Decodable {
        
    }

    public struct ResponseSubmitTxMint: Decodable {
        
    }

    public struct ParamsSubmitMint: Encodable {
        let hash: String
        let input: MintTransactionInput
    }
    struct MintTransactionInput: Encodable {
        init(txid: String, txindex: String, ghash: String, gpubkey: String, nhash: String, nonce: String, payload: String, phash: String, to: String, amount: String) {
            self.txid = txid
            self.txindex = txindex
            self.ghash = ghash
            self.gpubkey = gpubkey
            self.nhash = nhash
            self.nonce = nonce
            self.payload = payload
            self.phash = phash
            self.to = to
            self.amount = amount
        }
        
        init(
            gHash: Data,
            gPubkey: Data,
            nHash: Data,
            nonce: Data,
            amount: String,
            pHash: Data,
            to: String,
            txIndex: String,
            txid: Data
        ) {
            self.txid       = txid.base64urlEncodedString()
            self.txindex    = txIndex
            self.ghash      = gHash.base64urlEncodedString()
            self.gpubkey    = gPubkey.base64urlEncodedString()
            self.nhash      = nHash.base64urlEncodedString()
            self.nonce      = nonce.base64urlEncodedString()
            self.payload    = ""
            self.phash      = pHash.base64urlEncodedString()
            self.to         = to
            self.amount     = amount
        }
        
        let txid: String
        let txindex: String
        let ghash: String
        let gpubkey: String
        let nhash: String
        let nonce: String
        let payload: String
        let phash: String
        let to: String
        let amount: String
    }
}
