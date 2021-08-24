//
//  SerumSwap+Orderbook.swift
//  SolanaSwift
//
//  Created by Chung Tran on 20/08/2021.
//

import Foundation
import BufferLayoutSwift

extension SerumSwap {
    public struct Orderbook {
        let market: Market
        let isBids: Bool
        let slab: Slab
        
        init(market: Market, accountFlags: AccountFlags, slab: Slab) throws {
            if !accountFlags.initialized || !(accountFlags.bids ^ accountFlags.asks) {
                throw SerumSwapError("Invalid orderbook")
            }
            self.market = market
            self.isBids = accountFlags.bids
            self.slab = slab
        }
    }
}

extension SerumSwap.Orderbook {
    struct Layout: DecodableBufferLayout {
        let blob5: SerumSwap.Blob5
        let accountFlags: SerumSwap.AccountFlags
        let slab: SerumSwap.Slab
        let blob7: SerumSwap.Blob7
    }
}

private extension Bool {
    static func ^(lhs: Self, rhs: Self) -> Self {
        (lhs.bytes.first! ^ rhs.bytes.first!) != 0
    }
}
