import Foundation

struct Token2022Extension: BorshCodable {
    let type: ExtensionType
    let data: Data

    func serialize(to _: inout Data) throws {}

    init(from reader: inout BinaryReader) throws {
        let type = try ExtensionType(rawValue: UInt16(from: &reader))
        guard let type else {
            throw BorshCodableError.invalidData
        }
        self.type = type
        let length = try UInt16(from: &reader)
        data = try Data(reader.read(count: Int(length)))
    }
}
