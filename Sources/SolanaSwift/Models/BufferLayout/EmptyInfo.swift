import Foundation

public struct EmptyInfo: BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 0

    public init() {}
}

extension EmptyInfo: BorshCodable {
    public init(from _: inout BinaryReader) throws {}
    public func serialize(to _: inout Data) throws {}
}
