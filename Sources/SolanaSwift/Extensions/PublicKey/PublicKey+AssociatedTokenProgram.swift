import Foundation

// https://github.com/solana-labs/solana-web3.js/blob/dfb4497745c9fbf01e9633037bf9898dfd5adf94/src/publickey.ts#L224

// MARK: - Constants

private var maxSeedLength = 32
private let gf1 = NaclLowLevel.gf([1])

private extension Int {
    func toBool() -> Bool {
        self != 0
    }
}
