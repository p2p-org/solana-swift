import Foundation

public extension String {
    @inlinable
    var bytes: [UInt8] {
        data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }
}
