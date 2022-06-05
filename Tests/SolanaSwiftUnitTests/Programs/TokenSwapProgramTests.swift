import SolanaSwift
import XCTest

class TokenSwapProgramTests: XCTestCase {
    let publicKey: PublicKey = "11111111111111111111111111111111"

    func testSwapInstruction() throws {
        let instruction = TokenSwapProgram.swapInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            userTransferAuthority: publicKey,
            userSource: publicKey,
            poolSource: publicKey,
            poolDestination: publicKey,
            userDestination: publicKey,
            poolMint: publicKey,
            feeAccount: publicKey,
            hostFeeAccount: publicKey,
            swapProgramId: publicKey,
            tokenProgramId: publicKey,
            amountIn: 100_000,
            minimumAmountOut: 0
        )

        XCTAssertEqual(instruction.keys.count, 11)
        XCTAssertEqual(instruction.keys[0], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[1], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[2], .readonly(publicKey: "11111111111111111111111111111111", isSigner: true))
        XCTAssertEqual(instruction.keys[3], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[4], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[5], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[6], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[7], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[8], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[9], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[10], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.programId, publicKey)
        XCTAssertEqual(Base58.decode("tSBHVn49GSCW4DNB1EYv9M"), instruction.data)
    }

    func testDepositInstruction() throws {
        let instruction = TokenSwapProgram.depositInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            sourceA: publicKey,
            sourceB: publicKey,
            intoA: publicKey,
            intoB: publicKey,
            poolToken: publicKey,
            poolAccount: publicKey,
            tokenProgramId: publicKey,
            swapProgramId: publicKey,
            poolTokenAmount: 507_788,
            maximumTokenA: 51,
            maximumTokenB: 1038
        )

        XCTAssertEqual(instruction.keys.count, 9)
        XCTAssertEqual(instruction.keys[0], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[1], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[2], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[3], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[4], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[5], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[6], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[7], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[8], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.programId, publicKey)
        XCTAssertEqual(Base58.decode("22WQQtPPUknk68tx2dUGRL1Q4Vj2mkg6Hd"), instruction.data)
    }

    func testWithdrawInstruction() throws {
        let instruction = TokenSwapProgram.withdrawInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            poolMint: publicKey,
            feeAccount: publicKey,
            sourcePoolAccount: publicKey,
            fromA: publicKey,
            fromB: publicKey,
            userAccountA: publicKey,
            userAccountB: publicKey,
            swapProgramId: publicKey,
            tokenProgramId: publicKey,
            poolTokenAmount: 498_409,
            minimumTokenA: 49,
            minimumTokenB: 979
        )

        XCTAssertEqual(instruction.keys.count, 10)
        XCTAssertEqual(instruction.keys[0], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[1], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[2], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[3], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[4], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[5], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[6], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[7], .writable(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[8], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.keys[9], .readonly(publicKey: "11111111111111111111111111111111", isSigner: false))
        XCTAssertEqual(instruction.programId, publicKey)
        XCTAssertEqual(Base58.decode("2aJyv2ixHWcYWoAKJkYMzSPwTrGUfnSR9R"), instruction.data)
    }
}
