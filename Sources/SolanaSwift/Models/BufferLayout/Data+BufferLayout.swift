import Foundation

extension Data: BufferLayout, BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        self = try Data(reader.read(count: reader.count))
    }

    public func serialize(to writer: inout Data) throws {
        writer.append(self)
    }
}
