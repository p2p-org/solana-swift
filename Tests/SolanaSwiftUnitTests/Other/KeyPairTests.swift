import SolanaSwift
import TweetNacl
import XCTest

class KeyPairTests: XCTestCase {
    func testRestoreKeyPairFromSecretKey() throws {
        let secretKey = Base58
            .decode("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")
        XCTAssertNotNil(secretKey)

        let account = try KeyPair(secretKey: Data(secretKey))

        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", account.publicKey.base58EncodedString)
        XCTAssertEqual(64, account.secretKey.count)
    }

    func testRestoreKeyPairFromSeedPhrase() async throws {
        let phrase12 = "miracle pizza supply useful steak border same again youth silver access hundred"
            .components(separatedBy: " ")
        let account12 = try await KeyPair(phrase: phrase12, network: .mainnetBeta)
        XCTAssertEqual(account12.publicKey.base58EncodedString, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")

        let phrase24 =
            "budget resource fluid mutual ankle salt demise long burst sting doctor ozone risk magic wrap clap post pole jungle great update air interest abandon"
                .components(separatedBy: " ")
        let account24 = try await KeyPair(phrase: phrase24, network: .mainnetBeta)
        XCTAssertEqual(account24.publicKey.base58EncodedString, "9avcmC97zLPwHKXiDz6GpXyjvPn9VcN3ggqM5gsRnjvv")
    }

    func testRestoreKeyPairFromMnemonic() async throws {
        let mnemonic12 = try Mnemonic(phrase: "miracle pizza supply useful steak border same again youth silver access hundred"
            .components(separatedBy: " "))
        let account12 = try await KeyPair(mnemonic: mnemonic12, network: .mainnetBeta, derivablePath: .init(type: .deprecated, walletIndex: 0))
        XCTAssertEqual(account12.publicKey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")

        let mnemonic24 = try Mnemonic(phrase: "budget resource fluid mutual ankle salt demise long burst sting doctor ozone risk magic wrap clap post pole jungle great update air interest abandon"
            .components(separatedBy: " "))
        let account24 = try await KeyPair(mnemonic: mnemonic24, network: .mainnetBeta, derivablePath: .default)
        XCTAssertEqual(account24.publicKey, "9avcmC97zLPwHKXiDz6GpXyjvPn9VcN3ggqM5gsRnjvv")
    }

    func testRestoreKeyPairFromNonMnemonicSeedPhrase() async throws {
        let account = try await KeyPair(seed: "y 5 H M p D ^ G 6 3 9 x a b ^ 8", salt: "mnemonic", passphrase: "", network: .mainnetBeta, derivablePath: .default)
        XCTAssertEqual(account.publicKey, "7TJ2AEYmkUYJ3ESQv5B7Z1HwrTG9hUdj3PpqZn7DCxfo")

        let account2 = try await KeyPair(seed: "y5HMpD^G639xab^8", salt: "mnemonic", passphrase: "", network: .mainnetBeta, derivablePath: .default)
        XCTAssertEqual(account2.publicKey, "ADBWhBBb8di17PKfdXi4VhQwXnBBiUk8FJBNA6pwUdUc")
        XCTAssertEqual(Base58.encode(account2.secretKey), "5ruGYGx7Hco9gFoUAHo4nL9Ar7DwJZg9acQVofiYDof6pN8DFcv6vu1ikUbPmEoj7v8RvDGrXrcbDQ4c5jVqqqkC")

        let account3 = try await KeyPair(seed: "Lnj6uTyccG8WETn9", salt: "mnemonic", passphrase: "", network: .mainnetBeta, derivablePath: .default)
        XCTAssertEqual(account3.publicKey, "3mxR3Z2kBkxDJTfYTPcRHbZMeD4CvQTrW8UHvT1FEHd8")
        XCTAssertEqual(Base58.encode(account3.secretKey), "54oi838sVS7EnEdUgwaf1hLcYxDNZ7HLwrkAAggE9i9rCEPb5hZi9MkEU4r3ReDZ1EGWRpv36zTx7ZeLFZW3E1PL")

        let account4 = try await KeyPair(seed: "HelloWorld", salt: "mnemonic", passphrase: "", network: .mainnetBeta, derivablePath: .default)
        XCTAssertEqual(account4.publicKey, "E6R7yqi3Wh1p7fSrX7bMkSVB9Sh75dAGFgHVFevasSv6")
        XCTAssertEqual(Base58.encode(account4.secretKey), "YixumKVXM5QwZsKc1k1y3niyWtaH51UxUByVpJMxGswXL6cAp556htJ8rBGPe3m1Q9PiKmtKVgrcMrMATpDZDzJ")
    }

    // MARK: - Deprecated derivable path

    func testDerivedKeychain() throws {
        var keychain = try Keychain(
            seedString: "miracle pizza supply useful steak border same again youth silver access hundred",
            network: "mainnet-beta"
        )!

        keychain = try keychain.derivedKeychain(at: "m/501'/0'/0/0")

        let keys = try NaclSign.KeyPair.keyPair(fromSeed: keychain.privateKey!)

        XCTAssertEqual(
            [UInt8](keys.secretKey),
            [109, 13, 53, 177, 69, 45, 146, 184, 62, 55, 105, 133, 210, 89, 131, 218, 248, 101, 47, 64, 81, 56, 229, 25, 173, 154, 12, 41, 66, 143, 230, 117, 39, 247, 185, 4, 85, 137, 50, 166, 147, 184, 221, 75, 110, 103, 16, 222, 41, 94, 247, 132, 43, 62, 172, 243, 95, 204, 190, 143, 153, 16, 10, 197]
        )
    }
}
