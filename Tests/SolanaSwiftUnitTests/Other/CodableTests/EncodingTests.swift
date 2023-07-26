import SolanaSwift
import XCTest

class EncodingTests: XCTestCase {
    func testEncodingBytesLength() throws {
        XCTAssertEqual(Data([0]), Data.encodeLength(0))
        XCTAssertEqual(Data([1]), Data.encodeLength(1))
        XCTAssertEqual(Data([5]), Data.encodeLength(5))
        XCTAssertEqual(Data([0x7F]), Data.encodeLength(127))
        XCTAssertEqual(Data([128, 1]), Data.encodeLength(128))
        XCTAssertEqual(Data([0xFF, 0x01]), Data.encodeLength(255))
        XCTAssertEqual(Data([0x80, 0x02]), Data.encodeLength(256))
        XCTAssertEqual(Data([0xFF, 0xFF, 0x01]), Data.encodeLength(32767))
        XCTAssertEqual(Data([0x80, 0x80, 0x80, 0x01]), Data.encodeLength(2_097_152))
    }

    func test_givenBytes_whenDecodeLength_thenReturnsExpectedLength() throws {
        // given
        var bytes = Data([5, 3, 1, 2, 3, 7, 8, 5, 4])

        // when
        let result = bytes.decodeLength()

        // then
        XCTAssertEqual(result, 5)
    }

    func test_givenBytes_whenDecodeLengthTwice_thenReturnsExpectedLengths() throws {
        // given
        var bytes = Data([5, 0xF3, 1, 2, 3, 7, 8, 5, 4])

        // when
        let result1 = bytes.decodeLength()
        let result2 = bytes.decodeLength()

        // then
        XCTAssertEqual(result1, 5)
        XCTAssertEqual(result2, 0xF3)
    }

    func test_givenBytes_whenDecodeLength_thenRemovesFirstByte() throws {
        // given
        var bytes = Data([5, 1, 2, 3, 7, 8, 3, 4])
        let numberOfBytes = bytes.count

        // when
        _ = bytes.decodeLength()

        // then
        XCTAssertFalse(bytes.contains(5))
        XCTAssertEqual(bytes.count, numberOfBytes - 1)
    }

    func test_givenZeroBytes_whenDecodeLength_thenReturnsZero() throws {
        // given
        var bytes = Data()

        // when
        let result = bytes.decodeLength()

        // then
        XCTAssertEqual(result, 0)
    }
}
