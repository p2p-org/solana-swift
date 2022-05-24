import Foundation

struct BorshDecoder {
    func decode<T>(_: T.Type, from data: Data) throws -> T where T: BorshDeserializable {
        var reader = BinaryReader(bytes: [UInt8](data))
        return try T(from: &reader)
    }
}
