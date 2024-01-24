import Foundation

struct VecU8: BorshCodable, Codable, Equatable, Hashable {
    let length: UInt16
    let data: Data
    init(from reader: inout BinaryReader) throws {
        length = try UInt16(from: &reader)
        data = try Data(reader.read(count: Int(length)))
    }

    func serialize(to data: inout Data) throws {
        try length.serialize(to: &data)
        try data.serialize(to: &data)
    }
}
