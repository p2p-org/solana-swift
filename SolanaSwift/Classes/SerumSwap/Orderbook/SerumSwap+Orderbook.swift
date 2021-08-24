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
        
    }
}

extension SerumSwap.Orderbook {
    struct Layout: BufferLayout {
        let blob5: SerumSwap.Blob5
        let accountFlags: SerumSwap.AccountFlags
        let slab: SerumSwap.Slab
    }
}
