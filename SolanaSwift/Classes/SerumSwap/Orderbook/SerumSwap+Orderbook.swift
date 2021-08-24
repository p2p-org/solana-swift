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
        
        func getList(descending: Bool = false) -> LinkedList<ListItem> {
            let list = LinkedList<ListItem>()
            for item in self.slab.getNodeList(descending: descending) {
                let key = item.key
                let price = getPriceFromKey(key: key)
                list.append(
                    .init(orderId: key,
                          clientId: item.clientOrderId,
                          openOrdersAddress: item.owner,
                          openOrdersSlot: item.ownerSlot,
                          feeTier: item.feeTier,
                          price: market.priceLotsToNumber(price: price),
                          priceLots: price,
                          size: market.baseSizeLotsToNumber(quantity: item.quantity),
                          sizeLots: item.quantity,
                          side: isBids ? .buy: .sell
                    )
                )
            }
            
            return list
        }
        
        func getPriceFromKey(key: UInt128) -> BInt {
            BInt(key) >> 64
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
    
    struct ListItem {
        let orderId: UInt128    //key
        let clientId: UInt64    //clientOrderId
        let openOrdersAddress: SerumSwap.PublicKey  //owner
        let openOrdersSlot: UInt8   //ownerSlot
        let feeTier: UInt8
        let price: BInt       //this.market.priceLotsToNumber(price)
        let priceLots: BInt   //price
        let size: UInt64        //this.market.baseSizeLotsToNumber(quantity)
        let sizeLots: UInt64    //quantity
        let side: Side          //(this.isBids ? 'buy' : 'sell')
    }
    
    enum Side {
        case buy, sell
    }
}

private extension Bool {
    static func ^(lhs: Self, rhs: Self) -> Self {
        (lhs.bytes.first! ^ rhs.bytes.first!) != 0
    }
}
