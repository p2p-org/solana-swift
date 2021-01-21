//
//  AccountLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation

extension SolanaSDK {
    public struct AccountLayout: BufferLayout {
        let parsed: AccountLayoutParsed
        let program: String?
        let space: Int?
        
        public init?(_ keys: [String : [UInt8]]) {
            guard let mintBytes = keys["mint"],
                  let ownerBytes = keys["owner"],
                  let amountBytes = keys["amount"],
                  let mint = try? SolanaSDK.PublicKey(data: Data(mintBytes)).base58EncodedString,
                  let owner = try? SolanaSDK.PublicKey(data: Data(ownerBytes)).base58EncodedString,
                  let amount = amountBytes.toUInt64()
            else {
                return nil
            }
            self.parsed = AccountLayoutParsed(
                info: AccountLayoutParsedInfo(
                    isNative: false,
                    mint: mint,
                    owner: owner,
                    state: nil,
                    tokenAmount: AccountLayoutParsedInfoTokenAmount(
                        amount: "\(amount)",
                        decimals: nil,
                        uiAmount: nil)
                ),
                type: nil
            )
            self.program = nil
            self.space = nil
        }
        
        public static func layout() -> [(key: String?, length: Int)] {
            [
                (key: "mint", length: 32),
                (key: "owner", length: 32),
                (key: "amount", length: 8),
                (key: nil, length: 93)
            ]
        }
    }

    public struct AccountLayoutParsed: Codable {
        let info: AccountLayoutParsedInfo?
        let type: String?
    }

    public struct AccountLayoutParsedInfo: Codable {
        let isNative: Bool?
        let mint: String?
        let owner: String?
        let state: String?
        let tokenAmount: AccountLayoutParsedInfoTokenAmount?
    }

    public struct AccountLayoutParsedInfoTokenAmount: Codable {
        let amount: String?
        let decimals: Int?
        let uiAmount: Double?
    }
}

