import Foundation

public protocol Token2022ExtensionState: BorshCodable, Codable, Equatable, Hashable {
    var length: UInt16 { get }
}
