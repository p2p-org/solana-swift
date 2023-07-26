@testable import SolanaSwift
import XCTest

class MessageTests: XCTestCase {
    func test_givenRawMessage_whenFrom_thenReturnsExpectedMessage() throws {
        // given
        let expectedMessge = Message.StubFactory.makeSignedWithInstructions()
        // Base64-encoded message containing two instructions some accounts and signers.
        let base64 = "AgADBSxW7AhRsOx/s4ecSWrcic9vfD5asiW3d287f4uUsKeb7oz2DHCBpIZPzhc3kCRgNxVedAceB6yMl6hi5hPA1OkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAan1RcZLFxRIYzJTD1K8X9Y2u4Im6H9ROPb2YoAAAAABt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKkHQqjYoL28uYrjQx7GX6lt1z+mBGwH0eqdU9JknzvwfQICAgABNAAAAADwHR8AAAAAAKUAAAAAAAAABt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKkEAgADQwAALFbsCFGw7H+zh5xJatyJz298PlqyJbd3bzt/i5Swp5sAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
        let rawMessage = try XCTUnwrap(Data(base64Encoded: base64))

        // when
        let result = try Message.from(data: rawMessage)

        // then
        XCTAssertEqual(result.header, expectedMessge.header)
        XCTAssertEqual(result.recentBlockhash, expectedMessge.recentBlockhash)
        XCTAssertEqual(result.accountKeys, expectedMessge.accountKeys)
        zip(result.instructions, expectedMessge.instructions).forEach {
            XCTAssertEqual($0.accounts, $1.accounts)
            XCTAssertEqual($0.data, $1.data)
            XCTAssertEqual($0.dataLength, $1.dataLength)
            XCTAssertEqual($0.keyIndicesCount, $1.keyIndicesCount)
            XCTAssertEqual($0.serializedData, $1.serializedData)
        }
    }
}
