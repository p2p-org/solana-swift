import SolanaSwift
import XCTest

class TransactionTests: XCTestCase {
    func test_givenSigner_whenPartialSign_thenSignerAppended() throws {
        // given
        let signer = KeyPair.StubFactory.make()
        var transaction = Self.makeTransaction(signer: signer)

        // when
        try transaction.partialSign(signers: [signer])

        // then
        XCTAssertTrue(transaction.signatures.contains(where: { $0.publicKey == signer.publicKey }))
    }

    func test_givenSignerAndInvalidTransaction_whenPartialSign_thenThrowsError() throws {
        // given
        let signer = KeyPair.StubFactory.make()
        var transaction = Transaction(
            instructions: [],
            recentBlockhash: "",
            feePayer: .StubFactory.make()
        )

        // when
        // then
        XCTAssertThrowsError(try transaction.partialSign(signers: [signer]))
    }

    func test_givenPartiallySignedTransactionAndSameSigner_whenPartialSign_thenSignerNotAdded() throws {
        // given
        let signer = KeyPair.StubFactory.make()
        var transaction = Self.makeTransaction(signer: signer)
        try transaction.partialSign(signers: [signer])
        let numberOfSignatures = transaction.signatures.count

        // when
        try transaction.partialSign(signers: [signer])

        // then
        XCTAssertEqual(numberOfSignatures, transaction.signatures.count)
    }

    func test_givenEmptySigners_whenPartialSign_thenThrowsError() throws {
        // given
        let signer = KeyPair.StubFactory.make()
        var transaction = Self.makeTransaction(signer: signer)

        // when
        // then
        XCTAssertThrowsError(try transaction.partialSign(signers: []))
    }
}

extension TransactionTests {
    static func makeTransaction(
        signer: KeyPair,
        feePayer: PublicKey = .StubFactory.make()
    ) -> Transaction {
        .init(
            instructions: [
                .init(
                    keys: [
                        .init(
                            publicKey: signer.publicKey,
                            isSigner: true,
                            isWritable: true
                        ),
                    ],
                    programId: .fake,
                    data: [UInt8]([0])
                ),
            ],
            recentBlockhash: "",
            feePayer: feePayer
        )
    }
}
