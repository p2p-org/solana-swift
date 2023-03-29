import SolanaSwift
import XCTest

class MemoProgramTests: XCTestCase {
    func testCreateMemoInstruction() throws {
        let instruction = try MemoProgram.createMemoInstruction(memo: "HelloWorld")
        XCTAssertEqual(instruction.keys.count, 0)
        XCTAssertEqual(instruction.programId, "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr")
        XCTAssertEqual(Base58.encode(instruction.data), "54uZdajEaDdN6F")
    }
}
