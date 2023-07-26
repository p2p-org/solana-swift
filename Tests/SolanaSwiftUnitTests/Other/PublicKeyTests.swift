@testable import SolanaSwift
import XCTest

class PublicKeyTests: XCTestCase {
    func testPublicKeyFromString() throws {
        let fromPublicKey = try PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        XCTAssertEqual(
            fromPublicKey.bytes,
            [6, 26, 217, 208, 83, 135, 21, 72, 83, 126, 222, 62, 38, 24, 73, 163, 223, 183, 253, 2, 250, 188, 117, 178,
             35, 200, 228, 106, 219, 133, 61, 12]
        )

        let toPublicKey = try PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        XCTAssertEqual(
            toPublicKey.bytes,
            [235, 122, 188, 208, 216, 117, 235, 194, 109, 161, 177, 129, 163, 51, 155, 62, 242, 163, 22, 149, 187, 122,
             189, 188, 103, 130, 115, 188, 173, 205, 229, 170]
        )

        let programPubkey = try PublicKey(string: "11111111111111111111111111111111")
        XCTAssertEqual(
            programPubkey.bytes,
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        )
    }

    func testPublicKeyToString() throws {
        let key =
            try PublicKey(
                data: Data([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0])
            )
        XCTAssertEqual("CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3", key.base58EncodedString)

        let key1 = try PublicKey(string: "CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3")
        XCTAssertEqual("CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3", key1.base58EncodedString)

        let key2 = try PublicKey(string: "11111111111111111111111111111111")
        XCTAssertEqual("11111111111111111111111111111111", key2.base58EncodedString)

        let key3 =
            try PublicKey(
                data: Data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 1])
            )
        XCTAssertEqual(
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            key3.bytes
        )
    }

    func testCreateWithSeeds() throws {
        let defaultPublicKey: PublicKey = "11111111111111111111111111111111"
        let derivedKey = try PublicKey.createWithSeed(
            fromPublicKey: defaultPublicKey,
            seed: "limber chicken: 4/45",
            programId: defaultPublicKey
        )
        XCTAssertEqual(derivedKey, "9h1HyLCW5dZnBVap8C5egQ9Z6pHyjsh5MNy83iPqqRuq")
    }
}
