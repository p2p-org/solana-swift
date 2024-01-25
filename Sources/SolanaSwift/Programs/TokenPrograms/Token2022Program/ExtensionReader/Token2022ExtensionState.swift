import Foundation

public protocol Token2022ExtensionState: BorshCodable, Codable, Equatable, Hashable {
    var length: UInt16 { get }
}

extension VecU8<UInt16>: Token2022ExtensionState {}
