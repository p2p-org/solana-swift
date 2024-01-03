import Foundation

@available(*, deprecated, message: "[Legacy code] Will be removed in future.")
public extension TokenMetadata {
    static var nativeSolana: TokenMetadata =
        .init(
            tags: [],
            chainId: 101,
            mintAddress: "So11111111111111111111111111111111111111112",
            symbol: "SOL",
            name: "Solana",
            decimals: 9,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png",
            extensions: ["coingeckoId": .string("solana")],
            isNative: true
        )

    static var renBTC: TokenMetadata =
        .init(
            tags: nil,
            chainId: 101,
            mintAddress: PublicKey.renBTCMint.base58EncodedString,
            symbol: "renBTC",
            name: "renBTC",
            decimals: 8,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5/logo.png",
            extensions: [
                "website": .string("https://renproject.io/"),
                "serumV3Usdc": .string("74Ciu5yRzhe8TFTHvQuEVbFZJrbnCMRoohBK33NNiPtv"),
                "coingeckoId": .string("renbtc"),
            ]
        )

    static var usdc: TokenMetadata =
        .init(
            tags: nil,
            chainId: 101,
            mintAddress: PublicKey.usdcMint.base58EncodedString,
            symbol: "USDC",
            name: "USDC",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png",
            extensions: ["coingeckoId": .string("usd-coin")]
        )

    static var usdt: TokenMetadata =
        .init(
            tags: nil,
            chainId: 101,
            mintAddress: PublicKey.usdtMint.base58EncodedString,
            symbol: "USDT",
            name: "USDT",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB/logo.png",
            extensions: ["coingeckoId": .string("tether")]
        )

    static var eth: TokenMetadata =
        .init(
            tags: nil,
            chainId: 101,
            mintAddress: "7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs",
            symbol: "ETH",
            name: "Ether (Portal)",
            decimals: 8,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs/logo.png",
            extensions: ["coingeckoId": .string("ethereum")]
        )

    static var usdcet: TokenMetadata =
        .init(
            tags: nil,
            chainId: 101,
            mintAddress: "A9mUU4qviSctJVPJdBJWkb28deg915LYJKrzQ19ji3FM",
            symbol: "USDCet",
            name: "USD Coin (Wormhole)",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/A9mUU4qviSctJVPJdBJWkb28deg915LYJKrzQ19ji3FM/logo.png",
            extensions: ["coingeckoId": .string("usd-coin")]
        )
}
