import Foundation

public struct VecU8<T: FixedWidthInteger & Codable>: BorshCodable, Codable, Equatable, Hashable {
    public let length: T
    public let data: Data

    public init(from reader: inout BinaryReader) throws {
        length = try T(from: &reader)
        data = try Data(reader.read(count: Int(length)))
    }

    public init(length: T, data: Data) {
        self.length = length
        self.data = data
    }

    public func serialize(to writer: inout Data) throws {
        try length.serialize(to: &writer)
        try data.serialize(to: &writer)
    }
}
