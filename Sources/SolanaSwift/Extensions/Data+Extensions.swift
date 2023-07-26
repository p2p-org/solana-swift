import Foundation

public extension Data {
    var decodedLength: Int {
        var len: UInt8 = 0
        var size: UInt8 = 0
        var bytes = self
        while true {
            guard let elem = bytes.first else { break }
            bytes = bytes.dropFirst()
            len |= (elem & 0x7F) << (size * 7)
            size += 1
            if elem & 0x80 == 0 {
                break
            }
        }
        return Int(len)
    }

    mutating func decodeLength() -> Int {
        var len: UInt8 = 0
        var size: UInt8 = 0
        while true {
            guard let elem = bytes.first else { break }
            _ = popFirst()
            len |= (elem & 0x7F) << (size * 7)
            size += 1
            if elem & 0x80 == 0 {
                break
            }
        }
        return Int(len)
    }

    static func encodeLength(_ len: Int) -> Data {
        encodeLength(UInt(len))
    }

    private static func encodeLength(_ len: UInt) -> Data {
        var rem_len = len
        var bytes = Data()
        while true {
            var elem = rem_len & 0x7F
            rem_len = rem_len >> 7
            if rem_len == 0 {
                bytes.append(UInt8(elem))
                break
            } else {
                elem = elem | 0x80
                bytes.append(UInt8(elem))
            }
        }
        return bytes
    }
}

public extension Encodable {
    var jsonString: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
