import CommonCrypto
import Foundation

public extension Data {
    /// Two octet checksum as defined in RFC-4880. Sum of all octets, mod 65536
    func checksum() -> UInt16 {
        let s = withUnsafeBytes { buf in
            buf.lazy.map(UInt32.init).reduce(UInt32(0), +)
        }
        return UInt16(s % 65535)
    }
}

public extension Data {
    init(hex: String) {
        self.init([UInt8](hex: hex))
    }

    var bytes: [UInt8] {
        Array(self)
    }

    func toHexString() -> String {
        bytes.toHexString()
    }

    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
}
