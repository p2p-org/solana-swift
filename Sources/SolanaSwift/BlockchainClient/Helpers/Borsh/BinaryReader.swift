import Foundation

public enum BinaryReaderError: Error {
    case invalidBytesCount(Int)
    case dataMismatch
}

public struct BinaryReader {
    internal var cursor: Int
    internal let bytes: [UInt8]

    public init(bytes: [UInt8]) {
        cursor = 0
        self.bytes = bytes
    }

    public var isEmpty: Bool {
        bytes.isEmpty
    }

    public var count: Int {
        bytes.count
    }

    public var remainBytes: Int {
        count - cursor
    }
}

public extension BinaryReader {
    mutating func readAll() throws -> [UInt8] {
        try read(count: count - cursor)
    }

    mutating func read() throws -> UInt8 {
        let newPosition = cursor + 1
        guard bytes.count >= newPosition else {
            throw BinaryReaderError.dataMismatch
        }
        let result = bytes[cursor]
        cursor = newPosition
        return result
    }

    mutating func read(count: Int) throws -> [UInt8] {
        guard count <= UInt32.max else {
            throw BinaryReaderError.invalidBytesCount(count)
        }

        return try read(count: UInt32(count))
    }

    mutating func read(count: UInt32) throws -> [UInt8] {
        let newPosition = cursor + Int(count)
        guard bytes.count >= newPosition else {
            throw BinaryReaderError.dataMismatch
        }
        let result = bytes[cursor ..< newPosition]
        cursor = newPosition
        return Array(result)
    }

    mutating func decodeLength() throws -> Int {
        var len: UInt8 = 0
        var size: UInt8 = 0
        while true {
            let elem: UInt8 = try read()
            len |= (elem & 0x7F) << (size * 7)
            size += 1
            if elem & 0x80 == 0 {
                break
            }
        }
        return Int(len)
    }
}
