import Foundation

public struct AnyToken2022ExtensionState: BorshCodable, Codable, Equatable, Hashable {
    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        type.hash(into: &hasher)
        state.hash(into: &hasher)
    }

    // MARK: - Equatable

    public static func == (lhs: AnyToken2022ExtensionState, rhs: AnyToken2022ExtensionState) -> Bool {
        lhs.type == rhs.type &&
            lhs.state.jsonString == rhs.state.jsonString
    }

    // MARK: - Properties

    public let type: Token2022ExtensionType
    public let state: any Token2022ExtensionState

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case state
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(Token2022ExtensionType.self, forKey: .type)

        switch type {
        case .transferFeeConfig:
            state = try container.decode(TransferFeeConfigExtensionState.self, forKey: .state)
        default:
            state = try container.decode(VecU8.self, forKey: .state)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(state, forKey: .state)
    }

    // MARK: - BorshCodable

    public init(from reader: inout BinaryReader) throws {
        guard let type = try Token2022ExtensionType(rawValue: UInt16(from: &reader)) else {
            throw BinaryReaderError.dataMismatch
        }
        self.type = type
        switch type {
        case .transferFeeConfig:
            state = try TransferFeeConfigExtensionState(from: &reader)
        case .interestBearingConfig:
            state = try InterestBearingConfigExtensionState(from: &reader)
        default:
            state = try VecU8(from: &reader)
        }
    }

    init(
        type: Token2022ExtensionType,
        state: any Token2022ExtensionState
    ) {
        self.type = type
        self.state = state
    }

    public func serialize(to data: inout Data) throws {
        try type.rawValue.serialize(to: &data)
        try state.serialize(to: &data)
    }
}
