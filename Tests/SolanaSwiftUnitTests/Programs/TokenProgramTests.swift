import SolanaSwift
import XCTest

class TokenProgramTests: XCTestCase {
    func testInitializeMintInstruction() throws {
        let instruction = TokenProgram.initializeMintInstruction(
            mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            decimals: 6,
            authority: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            freezeAuthority: nil
        )

        XCTAssertEqual(instruction.keys.count, 2)
        XCTAssertEqual(
            instruction.keys[0],
            .writable(publicKey: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[1],
            .readonly(publicKey: "SysvarRent111111111111111111111111111111111", isSigner: false)
        )
        XCTAssertEqual(instruction.programId, TokenProgram.id)
        XCTAssertEqual(Base58.encode(instruction.data), "195AHs4ykNczn89ynGjJ5v7rSfaK9giG1eL2bNrmUqn1oNw")
    }

    func testInitializeAccountInstruction() throws {
        let instruction = TokenProgram.initializeAccountInstruction(
            account: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
            mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        )

        XCTAssertEqual(instruction.keys.count, 4)
        XCTAssertEqual(
            instruction.keys[0],
            .writable(publicKey: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[1],
            .readonly(publicKey: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[2],
            .readonly(publicKey: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[3],
            .readonly(publicKey: "SysvarRent111111111111111111111111111111111", isSigner: false)
        )
        XCTAssertEqual(instruction.programId, TokenProgram.id)
        XCTAssertEqual(Base58.encode(instruction.data), "2")
    }

    func testTransferInstruction() throws {
        let instruction = TokenProgram.transferInstruction(
            source: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
            destination: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3",
            owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            amount: 100
        )

        XCTAssertEqual(instruction.keys.count, 3)
        XCTAssertEqual(
            instruction.keys[0],
            .writable(publicKey: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[1],
            .writable(publicKey: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[2],
            .writable(publicKey: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG", isSigner: true)
        )
        XCTAssertEqual(instruction.programId, TokenProgram.id)
        XCTAssertEqual("3WBgs5fm8oDy", Base58.encode(instruction.data))
    }

    func testTransferCheckedInstruction() throws {
        let instruction = TokenProgram.transferCheckedInstruction(
            source: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
            mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            destination: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3",
            owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            multiSigners: [],
            amount: 100,
            decimals: 6
        )

        XCTAssertEqual(instruction.keys.count, 4)
        XCTAssertEqual(
            instruction.keys[0],
            .writable(publicKey: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[1],
            .readonly(publicKey: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[2],
            .writable(publicKey: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[3],
            .readonly(publicKey: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG", isSigner: true)
        )
        XCTAssertEqual(instruction.programId, TokenProgram.id)
        XCTAssertEqual("hNmtbNYibdzwf", Base58.encode(instruction.data))
    }

    func testBurnCheckedInstruction() throws {
        let instruction = TokenProgram.burnCheckedInstruction(
            mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            account: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
            owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            amount: 100,
            decimals: 6
        )

        XCTAssertEqual(instruction.keys.count, 3)
        XCTAssertEqual(
            instruction.keys[0],
            .writable(publicKey: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[1],
            .writable(publicKey: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[2],
            .readonly(publicKey: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG", isSigner: true)
        )
        XCTAssertEqual(instruction.programId, TokenProgram.id)
        XCTAssertEqual("s9m8UUrvs3fBT", Base58.encode(instruction.data))
    }

    func testApproveInstruction() throws {
        let instruction = TokenProgram.approveInstruction(
            account: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
            delegate: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo",
            owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            multiSigners: [],
            amount: 1000
        )

        XCTAssertEqual(instruction.keys.count, 3)
        XCTAssertEqual(
            instruction.keys[0],
            .writable(publicKey: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[1],
            .readonly(publicKey: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[2],
            .readonly(publicKey: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG", isSigner: true)
        )
        XCTAssertEqual(instruction.programId, TokenProgram.id)
        XCTAssertEqual("4d5tSvUuzUVM", Base58.encode(instruction.data))
    }

    func testMintToInstruction() throws {
        let instruction = TokenProgram.mintToInstruction(
            mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            destination: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3",
            authority: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            amount: 1_000_000_000
        )

        XCTAssertEqual(instruction.keys.count, 3)
        XCTAssertEqual(
            instruction.keys[0],
            .writable(publicKey: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[1],
            .writable(publicKey: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[2],
            .writable(publicKey: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG", isSigner: true)
        )
        XCTAssertEqual(instruction.programId, TokenProgram.id)
        XCTAssertEqual("6AsKhot84V8s", Base58.encode(instruction.data))
    }

    func testCloseAccountInstruction() throws {
        let instruction = TokenProgram.closeAccountInstruction(
            account: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3",
            destination: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo",
            owner: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        )

        XCTAssertEqual(instruction.keys.count, 3)
        XCTAssertEqual(
            instruction.keys[0],
            .writable(publicKey: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[1],
            .writable(publicKey: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", isSigner: false)
        )
        XCTAssertEqual(
            instruction.keys[2],
            .readonly(publicKey: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG", isSigner: false)
        )
        XCTAssertEqual(instruction.programId, TokenProgram.id)
        XCTAssertEqual("A", Base58.encode(instruction.data))
    }
}
