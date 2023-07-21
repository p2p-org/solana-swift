import Foundation

public extension [TokenMetadata] {
    func excludingSpecialTokens() -> Self {
        var currentAddresses: Set<String> = []

        return filter { token in
            currentAddresses.insert(token.address).inserted
                && !(token.tags?.contains(where: { $0.name == "!(t" }) ?? false) &&
                !(token.tags?.contains(where: { $0.name == "!lveraged" }) ?? false) &&
                !(token.tags?.contains(where: { $0.name == "!bll" }) ?? false) &&
                !(token.tags?.contains(where: { $0.name == "lp-token" }) ?? false)
        }
    }
}
