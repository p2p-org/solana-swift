import SolanaSwift
import XCTest

class FeeCalculatorTests: XCTestCase {
    var lamportsPerSignature: UInt64 { 5000 }
    var minRentExemption: UInt64 { 2_039_280 }

    var feeCalculator: DefaultFeeCalculator!

    override func setUpWithError() throws {
        feeCalculator = DefaultFeeCalculator(
            lamportsPerSignature: lamportsPerSignature,
            minRentExemption: minRentExemption
        )
    }

    // MARK: - Testcases

    func testTransactionFee() throws {
        // owner is the fee payer
        let transaction = createTransaction(instructions: [
            SystemProgram.transferInstruction(
                from: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                to: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                lamports: 1000
            ),
        ])

        let fee = try feeCalculator.calculateNetworkFee(transaction: transaction).total
        XCTAssertEqual(fee, lamportsPerSignature)

        // owner is not the fee payer
        let transaction2 = createTransaction(
            instructions: [
                TokenProgram.transferCheckedInstruction(
                    source: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3",
                    mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                    destination: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                    owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                    multiSigners: [],
                    amount: 10000,
                    decimals: 6
                ),
            ],
            feePayer: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5"
        )

        let fee2 = try feeCalculator.calculateNetworkFee(transaction: transaction2).total
        XCTAssertEqual(fee2, lamportsPerSignature * 2)
    }

    func testAccountCreationFee() throws {
        // create and initialize
        let transaction = createTransaction(instructions: [
            SystemProgram.createAccountInstruction(
                from: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                toNewPubkey: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                lamports: 1000,
                space: 165,
                programId: TokenProgram.id
            ),
            TokenProgram.initializeAccountInstruction(
                account: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                mint: .wrappedSOLMint,
                owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
            ),
        ])

        let fee = try feeCalculator.calculateNetworkFee(transaction: transaction)
        XCTAssertEqual(fee.transaction, lamportsPerSignature * 2)
        XCTAssertEqual(fee.accountBalances, minRentExemption)
        XCTAssertEqual(fee.deposit, 0)

        // create, initialize and close
        let transaction2 = createTransaction(
            instructions: [
                SystemProgram.createAccountInstruction(
                    from: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                    toNewPubkey: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                    lamports: 1000,
                    space: 165,
                    programId: TokenProgram.id
                ),
                TokenProgram.initializeAccountInstruction(
                    account: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                    mint: .wrappedSOLMint,
                    owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
                ),
                TokenProgram.closeAccountInstruction(
                    account: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                    destination: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                    owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
                ),
            ],
            feePayer: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v" // fee payer is not the owner
        )

        let fee2 = try feeCalculator.calculateNetworkFee(transaction: transaction2)
        XCTAssertEqual(fee2.transaction,
                       lamportsPerSignature * 3) // owner's signature, fee payer's signature, new account signature
        XCTAssertEqual(fee2.accountBalances, 0)
        XCTAssertEqual(fee2.deposit, minRentExemption)

        // create associated token
        let transaction3 = try createTransaction(
            instructions: [
                AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                    mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                    owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                    payer: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                    tokenProgramId: TokenProgram.id
                ),
            ]
        )

        let fee3 = try feeCalculator.calculateNetworkFee(transaction: transaction3)
        XCTAssertEqual(fee3.transaction, lamportsPerSignature * 2) // owner's signature, fee payer's signature
        XCTAssertEqual(fee3.accountBalances, minRentExemption)
        XCTAssertEqual(fee3.deposit, 0)

        // create associated token and close
        let transaction4 = try createTransaction(
            instructions: [
                AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                    mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                    owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                    payer: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
                    tokenProgramId: TokenProgram.id
                ),
                TokenProgram.closeAccountInstruction(
                    account: PublicKey.associatedTokenAddress(
                        walletAddress: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                        tokenMintAddress: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                        tokenProgramId: TokenProgram.id
                    ),
                    destination: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
                    owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
                ),
            ]
        )

        let fee4 = try feeCalculator.calculateNetworkFee(transaction: transaction4)
        XCTAssertEqual(fee4.transaction, lamportsPerSignature * 2) // owner's signature, fee payer's signature
        XCTAssertEqual(fee4.accountBalances, 0)
        XCTAssertEqual(fee4.deposit, minRentExemption)
    }

    // MARK: - Helpers

    private func createTransaction(instructions: [TransactionInstruction], feePayer: PublicKey? = nil) -> Transaction {
        Transaction(
            instructions: instructions,
            recentBlockhash: nil,
            feePayer: feePayer ?? "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        )
    }
}
