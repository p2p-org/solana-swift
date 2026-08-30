import SolanaSwift
import XCTest

final class MnemonicTests: XCTestCase {
    // The canonical BIP39 test vector: all-zero (128-bit) entropy maps to this
    // 12-word phrase with a valid checksum ("about" is the checksum word).
    private let validPhrase = [
        "abandon", "abandon", "abandon", "abandon", "abandon", "abandon",
        "abandon", "abandon", "abandon", "abandon", "abandon", "about",
    ]

    // MARK: - toEntropy

    func testToEntropyThrowsInvalidMnemonicForUnknownWord() {
        // Previously `toEntropy` force-unwrapped `wordlist.firstIndex(of:)`, so an
        // unknown word (e.g. a mistyped seed word) crashed the app instead of
        // throwing. It should surface `MnemonicError.invalidMnemonic`.
        let phrase = ["notabip39word", "abandon", "abandon", "abandon",
                      "abandon", "abandon", "abandon", "abandon",
                      "abandon", "abandon", "abandon", "about"]
        XCTAssertThrowsError(try Mnemonic.toEntropy(phrase)) { error in
            XCTAssertEqual(error as? MnemonicError, .invalidMnemonic)
        }
    }

    func testToEntropyReturnsZeroEntropyForCanonicalVector() throws {
        // The all-"abandon"/"about" phrase decodes to 16 zero bytes.
        let entropy = try Mnemonic.toEntropy(validPhrase)
        XCTAssertEqual(entropy, [UInt8](repeating: 0, count: 16))
    }

    // MARK: - isValid (guards the same lookup — kept as a contrast)

    func testIsValidReturnsFalseForUnknownWord() {
        var phrase = validPhrase
        phrase[0] = "notabip39word"
        XCTAssertFalse(Mnemonic.isValid(phrase: phrase))
    }

    func testIsValidReturnsTrueForValidPhrase() {
        XCTAssertTrue(Mnemonic.isValid(phrase: validPhrase))
    }

    // MARK: - init(phrase:) surfaces the same error path

    func testInitWithInvalidPhraseThrows() {
        var phrase = validPhrase
        phrase[0] = "notabip39word"
        XCTAssertThrowsError(try Mnemonic(phrase: phrase))
    }
}
