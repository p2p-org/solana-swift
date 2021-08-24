//
//  SerumSwap+Models.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/08/2021.
//

import Foundation
import BufferLayoutSwift

extension SerumSwap {
    public struct SignersAndInstructions {
        public let signers: [Account]
        public let instructions: [TransactionInstruction]
    }
    
    /**
     * Parameters to perform a swap.
     */
    public struct SwapParams {
        public init(fromMint: SerumSwap.PublicKey, toMint: SerumSwap.PublicKey, quoteMint: SerumSwap.PublicKey?, amount: SerumSwap.Lamports, minExchangeRate: SerumSwap.ExchangeRate, referral: SerumSwap.PublicKey?, fromWallet: SerumSwap.PublicKey?, toWallet: SerumSwap.PublicKey?, quoteWallet: SerumSwap.PublicKey?, fromMarket: SerumSwap.Market, toMarket: SerumSwap.Market?, fromOpenOrders: SerumSwap.PublicKey?, toOpenOrders: SerumSwap.PublicKey?, close: Bool?) {
            self.fromMint = fromMint
            self.toMint = toMint
            self.quoteMint = quoteMint
            self.amount = amount
            self.minExchangeRate = minExchangeRate
            self.referral = referral
            self.fromWallet = fromWallet
            self.toWallet = toWallet
            self.quoteWallet = quoteWallet
            self.fromMarket = fromMarket
            self.toMarket = toMarket
            self.fromOpenOrders = fromOpenOrders
            self.toOpenOrders = toOpenOrders
            self.close = close
        }
        
        /**
         * Token mint to swap from.
         */
        let fromMint: PublicKey
        
        /**
         * Token mint to swap to.
         */
        let toMint: PublicKey
        
        /**
         * Token mint used as the quote currency for a transitive swap, i.e., the
         * connecting currency.
         */
        let quoteMint: PublicKey?
        
        /**
         * Amount of `fromMint` to swap in exchange for `toMint`.
         */
        let amount: Lamports
        
        /**
         * The minimum rate used to calculate the number of tokens one
         * should receive for the swap. This is a safety mechanism to prevent one
         * from performing an unexpecteed trade.
         */
        let minExchangeRate: ExchangeRate
        
        /**
         * Token account to receive the Serum referral fee. The mint must be in the
         * quote currency of the trade (USDC or USDT).
         */
        let referral: PublicKey?
        
        /**
         * Wallet for `fromMint`. If not provided, uses an associated token address
         * for the configured provider.
         */
        let fromWallet: PublicKey?
        
        /**
         * Wallet for `toMint`. If not provided, an associated token account will
         * be created for the configured provider.
         */
        let toWallet: PublicKey?
        
        /**
         * Wallet of the quote currency to use in a transitive swap. Should be either
         * a USDC or USDT wallet. If not provided an associated token account will
         * be created for the configured provider.
         */
        let quoteWallet: PublicKey?
        
        /**
         * Market client for the first leg of the swap. Can be given to prevent
         * the client from making unnecessary network requests.
         */
        let fromMarket: Market
        
        /**
         * Market client for the second leg of the swap. Can be given to prevent
         * the client from making unnecessary network requests.
         */
        let toMarket: Market?
        
        /**
         * Open orders account for the first leg of the swap. If not given, an
         * open orders account will be created.
         */
        let fromOpenOrders: PublicKey?
        
        /**
         * Open orders account for the second leg of the swap. If not given, an
         * open orders account will be created.
         */
        let toOpenOrders: PublicKey?
        
        /**
         * RPC options. If not given the options on the program's provider are used.
         */
        let options: SolanaSDK.RequestConfiguration? = nil
        
        /**
         * True if all new open orders accounts should be automatically closed.
         * Currently disabled.
         */
        let close: Bool?
        
        /**
         * The payer that pays the creation transaction.
         * nil if the current user is the payer
         */
        let feePayer: PublicKey? = nil
        
        /**
         * Additional transactions to bundle into the swap transaction
         */
        let additionalTransactions: [SignersAndInstructions]? = nil
    }
    
    public struct ExchangeRate: BytesEncodable {
        public init(rate: SerumSwap.Lamports, fromDecimals: SerumSwap.Decimals, quoteDecimals: SerumSwap.Decimals, strict: Bool) {
            self.rate = rate
            self.fromDecimals = fromDecimals
            self.quoteDecimals = quoteDecimals
            self.strict = strict
        }
        
        let rate: Lamports
        let fromDecimals: Decimals
        let quoteDecimals: Decimals
        let strict: Bool
        
        var bytes: [UInt8] {
            rate.bytes + [fromDecimals] + [quoteDecimals] + strict.bytes
        }
    }
    
    public struct DidSwap: BufferLayout {
        public let givenAmount: UInt64
        public let minExpectedSwapAmount: UInt64
        public let fromAmount: UInt64
        public let toAmount: UInt64
        public let spillAmount: UInt64
        public let fromMint: PublicKey
        public let toMint: PublicKey
        public let quoteMint: PublicKey
        public let authority: PublicKey
    }
    
    // Side rust enum used for the program's RPC API.
    public enum Side {
        case bid, ask
        var params: [String: [String: String]] {
            switch self {
            case .bid:
                return ["bid": [:]]
            case .ask:
                return ["ask": [:]]
            }
        }
        var byte: UInt8 {
            switch self {
            case .bid:
                return 0
            case .ask:
                return 1
            }
        }
    }
}

// MARK: - BufferLayout properties
private protocol BlobType: Codable, BufferLayoutProperty {
    init(bytes: [UInt8])
    var bytes: [UInt8] {get}
    static var length: Int {get}
}

extension BlobType {
    public init(buffer: Data, pointer: inout Int) throws {
        self.init(bytes: [UInt8](buffer[pointer..<pointer+Self.length]))
        pointer += Self.length
    }
    public func serialize() throws -> Data {
        Data(bytes)
    }
}

extension SerumSwap {
    public struct Blob2: BlobType {
        static var length: Int {2}
        let bytes: [UInt8]
    }
    
    public struct Blob5: BlobType {
        static var length: Int {5}
        let bytes: [UInt8]
    }
    
    public struct AccountFlags: Codable, Equatable, BufferLayoutProperty {
        public init(initialized: Bool, market: Bool, openOrders: Bool, requestQueue: Bool, eventQueue: Bool, bids: Bool, asks: Bool) {
            self.initialized = initialized
            self.market = market
            self.openOrders = openOrders
            self.requestQueue = requestQueue
            self.eventQueue = eventQueue
            self.bids = bids
            self.asks = asks
        }
        
        public private(set) var initialized: Bool
        public private(set) var market: Bool
        public private(set) var openOrders: Bool
        public private(set) var requestQueue: Bool
        public private(set) var eventQueue: Bool
        public private(set) var bids: Bool
        public private(set) var asks: Bool
        
        public static var length: Int {8}
        
        public init(buffer: Data, pointer: inout Int) throws {
            var number = try UInt64(buffer: buffer, pointer: &pointer)
            
            let variablesCount = 7
            var bits = [Bool]()
            for _ in 0..<variablesCount {
                bits.append(number % 2 != 0)
                number /= 2
            }
            
            self.init(
                initialized:    bits[0],
                market:         bits[1],
                openOrders:     bits[2],
                requestQueue:   bits[3],
                eventQueue:     bits[4],
                bids:           bits[5],
                asks:           bits[6]
            )
        }
        
        public func serialize() throws -> Data {
            var number: UInt64 = 0
            if initialized      { number += 1 << 0 }
            if market           { number += 1 << 1 }
            if openOrders       { number += 1 << 2 }
            if requestQueue     { number += 1 << 3 }
            if eventQueue       { number += 1 << 4 }
            if bids             { number += 1 << 5 }
            if asks             { number += 1 << 6 }
            return try number.serialize()
        }
    }
    
    public struct Seq128Elements<T: FixedWidthInteger>: BufferLayoutProperty {
        var elements: [T]
        
        public static var length: Int { 128 * MemoryLayout<T>.size }
        
        public init(buffer: Data, pointer: inout Int) throws {
            let endIndex = pointer+Self.length
            guard buffer.count > endIndex else {
                throw BufferLayoutSwift.Error.bytesLengthIsNotValid
            }
            let bytes = [UInt8](buffer[pointer..<endIndex])
            
            var elements = [T]()
            let chunkedArray = bytes.chunked(into: MemoryLayout<T>.size)
            for element in chunkedArray {
                let data = Data(element)
                let num = T(littleEndian: data.withUnsafeBytes { $0.load(as: T.self) })
                elements.append(num)
            }
            
            self.elements = elements
            pointer += Self.length
        }
        
        public func serialize() throws -> Data {
            try elements.reduce(Data(), { $0 + (try $1.serialize()) })
        }
    }
    
    public struct Blob1024: BlobType {
        let bytes: [UInt8]
        static var length: Int {1024}
    }
    
    public struct Blob7: BlobType {
        let bytes: [UInt8]
        static var length: Int {7}
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
