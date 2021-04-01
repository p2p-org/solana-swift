//
//  SupportedTokens.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/11/2020.
//

import Foundation

extension SolanaSDK {
    struct SupportedTokens {
        static var shared: [Network: String] {
            [
                // MARK: - mainnet-Beta
                .mainnetBeta: """
                [
                  {
                    "mintAddress": "So11111111111111111111111111111111111111112",
                    "symbol": "WSOL",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt",
                    "symbol": "SRM",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "MSRMcoVyrFxnSgo5uXwone5SKcGhT1KEJMFEkMEWf9L",
                    "symbol": "MSRM",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E",
                    "symbol": "BTC",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk",
                    "symbol": "ETH",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "AGFEad2et2ZJif9jaGpdMixQqvW5i81aBdvKe7PHNfz3",
                    "symbol": "FTT",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "3JSf5tPeuscJGtaCp5giEiDhv51gQ4v3zWg8DGgyLfAB",
                    "symbol": "YFI",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "CWE8jPTUYhdCTZYWPTe1o5DFqfdjzWKc9WKz6rSjQUdG",
                    "symbol": "LINK",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "Ga2AXHpfAF6mv2ekZwcsJFqu7wB4NV331qNH7fW9Nst8",
                    "symbol": "XRP",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "BQcdHdAQW1hczDbBi9hiegXAR7A98Q9jx3X3iBBBDiq4",
                    "symbol": "USDT",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                    "symbol": "USDC",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "BXXkv6z8ykpG1yuvUDPgh732wzVHB69RnB9YgSYh3itW",
                    "symbol": "WUSDC",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "AR1Mtgh7zAtxuxGd2XPovXPVjcSdY3i4rQYisNadjfKy",
                    "symbol": "SUSHI",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "CsZ5LZkDS7h9TDKjrbL7VAwQZ9nsRu8vJLhRYfmGaN8K",
                    "symbol": "ALEPH",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "SF3oTvfWzEP3DTwGSvUXRrGTvr75pdZNnBLAH9bzMuX",
                    "symbol": "SXP",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "BtZQfWqDGbk9Wf2rXEiWyQBdBY1etnUUn6zEphvVS7yN",
                    "symbol": "HGET",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "5Fu5UUgbjpUvdBveb3a1JTNirL8rXtiYeSMWvKjtUNQv",
                    "symbol": "CREAM",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "873KLxCbz7s9Kc4ZzgYRtNmhfkQrhfyWGZJBmyCbC3ei",
                    "symbol": "UBXT",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "HqB7uswoVg4suaQiDP3wjxob1G5WdZ144zhdStwMCq7e",
                    "symbol": "HNT",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "9S4t2NEAiJVMvPdRYKVrfJpBafPBLtvbvyS3DecojQHw",
                    "symbol": "FRONT",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "6WNVCuxCGJzNjmMZoKyhZJwvJ5tYpsLyAtagzYASqBoF",
                    "symbol": "AKRO",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "DJafV9qemGp7mLMEn5wrfqaFwxsbLgUsGVS16zKRk9kc",
                    "symbol": "HXRO",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "DEhAasscXF4kEGxFgJ3bq4PpVGp5wyUxMRvn6TzGVHaw",
                    "symbol": "UNI",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza",
                    "symbol": "MATH",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "GXMvfY2jpQctDqZ9RoU3oWPhufKiCcFEfchvYumtX7jd",
                    "symbol": "TOMO",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "EqWCKXfs3x47uVosDpTRgFniThL9Y8iCztJaapxbEaVX",
                    "symbol": "LUA",
                    "wrappedBy": "FTX"
                  }
                ]
                """,
                
                // MARK: - devnet
                .devnet: """
                [
                  {
                    "mintAddress": "96oUA9Zu6hdpp9rv41b8Z6DqRyVQm1VMqVU4cBxQupNJ",
                    "symbol": "EXMPL",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "E8H1ofiyDHuFx5c8RWHiUkBHRDE38JA3sgkbrtrCHx7j",
                    "symbol": "EXMPL2",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "2tQ2LU4Rw48fEGZpJMKxpDbY7UgFaK2rRYb8sn2WbbYY",
                    "symbol": "EXMPL3",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "2tQ2LU4Rw48fEGZpJMKxpDbY7UgFaK2rRYb8sn2WbbYY",
                    "symbol": "EXMPL4",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "YndHQW5PsSbANHi8tiu9P83bVUQfxcRfKcFDgBHet5AH",
                    "symbol": "EXMPL5",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "uWVZz7uZ1Dx3J2vNtgn9V3cT9hzayqVEjrzAC6RUHc7A",
                    "symbol": "EXMPL6",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "6tFfrTsrZBg4MqaP2LkKn9kKH4zyB2L8ikpLboDQ9SEn",
                    "symbol": "EXMPL7",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "3CcnMLgDjXvWsYNg4JwBT2Un3N5zh4UR1iz1RJB4CXEX",
                    "symbol": "EXMPL8",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "HHpyfYteg2MjMBaZC6Vj43ppMKt8MUxSCxPzRaruTbpM",
                    "symbol": "EXMPL9",
                    "wrappedBy": "FTX"
                  },
                  {
                    "mintAddress": "4TJRe6gZZG3ybtjn5GPCGtQtVCG4zG5URC4t6u4ddTwM",
                    "symbol": "EXMPL10",
                    "wrappedBy": "FTX"
                  }
                ]
                """
            ]
        }
    }
}
