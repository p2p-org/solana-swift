//
//  SupportedTokens.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/11/2020.
//

import Foundation

extension SolanaSDK {
    struct SupportedTokens {
        static var shared: [String: String] {
            [
                // MARK: - mainnet-Beta
                "mainnet-beta": """
                [
                  {
                    "mintAddress": "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt",
                    "name": "Serum",
                    "symbol": "SRM",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "mintAddress": "MSRMcoVyrFxnSgo5uXwone5SKcGhT1KEJMFEkMEWf9L",
                    "name": "MegaSerum",
                    "symbol": "MSRM",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "symbol": "BTC",
                    "mintAddress": "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E",
                    "name": "Wrapped Bitcoin",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/bitcoin/info/logo.png"
                  },
                  {
                    "symbol": "ETH",
                    "mintAddress": "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk",
                    "name": "Wrapped Ethereum",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png"
                  },
                  {
                    "symbol": "FTT",
                    "mintAddress": "AGFEad2et2ZJif9jaGpdMixQqvW5i81aBdvKe7PHNfz3",
                    "name": "Wrapped FTT",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/f3ffd0b9ae2165336279ce2f8db1981a55ce30f8/blockchains/ethereum/assets/0x50D1c9771902476076eCFc8B2A83Ad6b9355a4c9/logo.png"
                  },
                  {
                    "symbol": "YFI",
                    "mintAddress": "3JSf5tPeuscJGtaCp5giEiDhv51gQ4v3zWg8DGgyLfAB",
                    "name": "Wrapped YFI",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e/logo.png"
                  },
                  {
                    "symbol": "LINK",
                    "mintAddress": "CWE8jPTUYhdCTZYWPTe1o5DFqfdjzWKc9WKz6rSjQUdG",
                    "name": "Wrapped Chainlink",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x514910771AF9Ca656af840dff83E8264EcF986CA/logo.png"
                  },
                  {
                    "symbol": "XRP",
                    "mintAddress": "Ga2AXHpfAF6mv2ekZwcsJFqu7wB4NV331qNH7fW9Nst8",
                    "name": "Wrapped XRP",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ripple/info/logo.png"
                  },
                  {
                    "symbol": "USDT",
                    "mintAddress": "BQcdHdAQW1hczDbBi9hiegXAR7A98Q9jx3X3iBBBDiq4",
                    "name": "Wrapped USDT",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/f3ffd0b9ae2165336279ce2f8db1981a55ce30f8/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png"
                  },
                  {
                    "symbol": "USDC",
                    "mintAddress": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                    "name": "USD Coin",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/f3ffd0b9ae2165336279ce2f8db1981a55ce30f8/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png"
                  },
                  {
                    "symbol": "WUSDC",
                    "mintAddress": "BXXkv6z8ykpG1yuvUDPgh732wzVHB69RnB9YgSYh3itW",
                    "name": "Wrapped USDC",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/f3ffd0b9ae2165336279ce2f8db1981a55ce30f8/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
                    "deprecated": true
                  },
                  {
                    "symbol": "SUSHI",
                    "mintAddress": "AR1Mtgh7zAtxuxGd2XPovXPVjcSdY3i4rQYisNadjfKy",
                    "name": "Wrapped SUSHI",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x6B3595068778DD592e39A122f4f5a5cF09C90fE2/logo.png"
                  },
                  {
                    "symbol": "ALEPH",
                    "mintAddress": "CsZ5LZkDS7h9TDKjrbL7VAwQZ9nsRu8vJLhRYfmGaN8K",
                    "name": "Wrapped ALEPH",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/6996a371cd02f516506a8f092eeb29888501447c/blockchains/nuls/assets/NULSd6HgyZkiqLnBzTaeSQfx1TNg2cqbzq51h/logo.png"
                  },
                  {
                    "symbol": "SXP",
                    "mintAddress": "SF3oTvfWzEP3DTwGSvUXRrGTvr75pdZNnBLAH9bzMuX",
                    "name": "Wrapped SXP",
                    "icon": "https://github.com/trustwallet/assets/raw/b0ab88654fe64848da80d982945e4db06e197d4f/blockchains/ethereum/assets/0x8CE9137d39326AD0cD6491fb5CC0CbA0e089b6A9/logo.png"
                  },
                  {
                    "symbol": "HGET",
                    "mintAddress": "BtZQfWqDGbk9Wf2rXEiWyQBdBY1etnUUn6zEphvVS7yN",
                    "name": "Wrapped HGET"
                  },
                  {
                    "symbol": "CREAM",
                    "mintAddress": "5Fu5UUgbjpUvdBveb3a1JTNirL8rXtiYeSMWvKjtUNQv",
                    "name": "Wrapped CREAM",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/4c82c2a409f18a4dd96a504f967a55a8fe47026d/blockchains/smartchain/assets/0xd4CB328A82bDf5f03eB737f37Fa6B370aef3e888/logo.png"
                  },
                  {
                    "symbol": "UBXT",
                    "mintAddress": "873KLxCbz7s9Kc4ZzgYRtNmhfkQrhfyWGZJBmyCbC3ei",
                    "name": "Wrapped UBXT"
                  },
                  {
                    "symbol": "HNT",
                    "mintAddress": "HqB7uswoVg4suaQiDP3wjxob1G5WdZ144zhdStwMCq7e",
                    "name": "Wrapped HNT"
                  },
                  {
                    "symbol": "FRONT",
                    "mintAddress": "9S4t2NEAiJVMvPdRYKVrfJpBafPBLtvbvyS3DecojQHw",
                    "name": "Wrapped FRONT",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/6e375e4e5fb0ffe09ed001bae1ef8ca1d6c86034/blockchains/ethereum/assets/0xf8C3527CC04340b208C854E985240c02F7B7793f/logo.png"
                  },
                  {
                    "symbol": "AKRO",
                    "mintAddress": "6WNVCuxCGJzNjmMZoKyhZJwvJ5tYpsLyAtagzYASqBoF",
                    "name": "Wrapped AKRO",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/878dcab0fab90e6593bcb9b7d941be4915f287dc/blockchains/ethereum/assets/0xb2734a4Cec32C81FDE26B0024Ad3ceB8C9b34037/logo.png"
                  },
                  {
                    "symbol": "HXRO",
                    "mintAddress": "DJafV9qemGp7mLMEn5wrfqaFwxsbLgUsGVS16zKRk9kc",
                    "name": "Wrapped HXRO"
                  },
                  {
                    "symbol": "UNI",
                    "mintAddress": "DEhAasscXF4kEGxFgJ3bq4PpVGp5wyUxMRvn6TzGVHaw",
                    "name": "Wrapped UNI",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/08d734b5e6ec95227dc50efef3a9cdfea4c398a1/blockchains/ethereum/assets/0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984/logo.png"
                  },
                  {
                    "symbol": "MATH",
                    "mintAddress": "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza",
                    "name": "Wrapped MATH"
                  },
                  {
                    "symbol": "TOMO",
                    "mintAddress": "GXMvfY2jpQctDqZ9RoU3oWPhufKiCcFEfchvYumtX7jd",
                    "name": "Wrapped TOMO",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/08d734b5e6ec95227dc50efef3a9cdfea4c398a1/blockchains/tomochain/info/logo.png"
                  },
                  {
                    "symbol": "LUA",
                    "mintAddress": "EqWCKXfs3x47uVosDpTRgFniThL9Y8iCztJaapxbEaVX",
                    "name": "Wrapped LUA"
                  }
                ]
                """,
                
                // MARK: - devnet
                "devnet": """
                [
                  {
                    "name": "Example Token",
                    "mintAddress": "96oUA9Zu6hdpp9rv41b8Z6DqRyVQm1VMqVU4cBxQupNJ",
                    "symbol": "EXMPL",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 2",
                    "mintAddress": "E8H1ofiyDHuFx5c8RWHiUkBHRDE38JA3sgkbrtrCHx7j",
                    "symbol": "EXMPL2",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 3",
                    "mintAddress": "2tQ2LU4Rw48fEGZpJMKxpDbY7UgFaK2rRYb8sn2WbbYY",
                    "symbol": "EXMPL3",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 4",
                    "mintAddress": "2tQ2LU4Rw48fEGZpJMKxpDbY7UgFaK2rRYb8sn2WbbYY",
                    "symbol": "EXMPL4",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 5",
                    "mintAddress": "YndHQW5PsSbANHi8tiu9P83bVUQfxcRfKcFDgBHet5AH",
                    "symbol": "EXMPL5",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 6",
                    "mintAddress": "uWVZz7uZ1Dx3J2vNtgn9V3cT9hzayqVEjrzAC6RUHc7A",
                    "symbol": "EXMPL6",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 7",
                    "mintAddress": "6tFfrTsrZBg4MqaP2LkKn9kKH4zyB2L8ikpLboDQ9SEn",
                    "symbol": "EXMPL7",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 8",
                    "mintAddress": "3CcnMLgDjXvWsYNg4JwBT2Un3N5zh4UR1iz1RJB4CXEX",
                    "symbol": "EXMPL8",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 9",
                    "mintAddress": "6FoCxCt6d6LGgMCpB7iEuvstQKkoE9GUnaTYF36NRfaW",
                    "symbol": "EXMPL9",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  },
                  {
                    "name": "Example Token 10",
                    "mintAddress": "6Xd5kaN87U1CRmJH9r8BTdB91CBEGPkmCjNtn1HiGPcU",
                    "symbol": "EXMPL10",
                    "icon": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x476c5E26a75bd202a9683ffD34359C0CC15be0fF/logo.png"
                  }
                ]
                """
            ]
        }
    }
}
