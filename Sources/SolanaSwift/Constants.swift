import Foundation

public enum Constants {
    public static let packageDataSize: Int = 1280 - 40 - 8
    public static let versionPrefixMask: UInt8 = 0x7F

    public static let signatureLength = 64
    public static let defaultSignature = Data(repeating: 0, count: 64)
}
