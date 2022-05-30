import SolanaSwift
import XCTest

class OwnerValidationProgramTests: XCTestCase {
    func testAssertOwnerInstruction() throws {
        let instruction = OwnerValidationProgram.assertOwnerInstruction(
            account: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
            programId: SystemProgram.id
        )
        XCTAssertEqual(instruction.keys.count, 1)
        XCTAssertEqual(
            instruction.keys[0],
            .readonly(publicKey: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", isSigner: false)
        )
        XCTAssertEqual(instruction.programId, "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5")
        XCTAssertEqual(Base58.encode(instruction.data), "11111111111111111111111111111111")
    }
}
