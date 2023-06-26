import Foundation
import SolanaSwift

public extension Token {
    static var nativeSolana: Self {
        .init(
            _tags: [],
            chainId: 101,
            address: "So11111111111111111111111111111111111111112",
            symbol: "SOL",
            name: "Solana",
            decimals: 9,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png",
            tags: [],
            extensions: TokenExtensions(coingeckoId: "solana"),
            isNative: true
        )
    }

    static var renBTC: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: PublicKey.renBTCMint.base58EncodedString,
            symbol: "renBTC",
            name: "renBTC",
            decimals: 8,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5/logo.png",
            extensions: .init(
                website: "https://renproject.io/",
                serumV3Usdc: "74Ciu5yRzhe8TFTHvQuEVbFZJrbnCMRoohBK33NNiPtv",
                coingeckoId: "renbtc"
            )
        )
    }

    static var usdc: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: PublicKey.usdcMint.base58EncodedString,
            symbol: "USDC",
            name: "USDC",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png",
            extensions: .init(coingeckoId: "usd-coin")
        )
    }

    static var usdt: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: PublicKey.usdtMint.base58EncodedString,
            symbol: "USDT",
            name: "USDT",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB/logo.png",
            extensions: .init(coingeckoId: "tether")
        )
    }

    static var eth: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: "7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs",
            symbol: "ETH",
            name: "Ether (Portal)",
            decimals: 8,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs/logo.png",
            extensions: .init(coingeckoId: "ethereum")
        )
    }

    static var usdcet: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: "A9mUU4qviSctJVPJdBJWkb28deg915LYJKrzQ19ji3FM",
            symbol: "USDCet",
            name: "USD Coin (Wormhole)",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/A9mUU4qviSctJVPJdBJWkb28deg915LYJKrzQ19ji3FM/logo.png",
            extensions: .init(coingeckoId: "usd-coin")
        )
    }
}
