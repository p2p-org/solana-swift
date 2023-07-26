import Foundation

public typealias BorshCodable = BorshSerializable & BorshDeserializable

public enum BorshCodableError: Error {
    case invalidData
}
