import Foundation

public extension Array where Element == TokenMetadata {
    func excludingSpecialTokens() -> Self {
        var currentAddresses: Set<String> = []

        return filter { token in
            currentAddresses.insert(token.mintAddress).inserted &&
                !token.tags.contains(where: { $0.name == "nft" }) &&
                !token.tags.contains(where: { $0.name == "leveraged" }) &&
                !token.tags.contains(where: { $0.name == "bull" }) &&
                !token.tags.contains(where: { $0.name == "lp-token" })
        }
    }
}
