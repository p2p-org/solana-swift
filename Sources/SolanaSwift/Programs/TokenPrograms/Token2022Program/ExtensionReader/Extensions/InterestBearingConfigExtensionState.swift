import Foundation

public struct InterestBearingConfigExtensionState: Token2022ExtensionState {
    public var length: UInt16

    public let rateAuthority: PublicKey
    public let initializationTimestamp: Int64
    public let preUpdateAverageRate: Int16
    public let lastUpdateTimestamp: Int64
    public let currentRate: Int16

    public init(from reader: inout BinaryReader) throws {
        length = try UInt16(from: &reader)
        rateAuthority = try PublicKey(from: &reader)
        initializationTimestamp = try Int64(from: &reader)
        preUpdateAverageRate = try Int16(from: &reader)
        lastUpdateTimestamp = try Int64(from: &reader)
        currentRate = try Int16(from: &reader)
    }

    public func serialize(to data: inout Data) throws {
        try length.serialize(to: &data)
        try rateAuthority.serialize(to: &data)
        try initializationTimestamp.serialize(to: &data)
        try preUpdateAverageRate.serialize(to: &data)
        try lastUpdateTimestamp.serialize(to: &data)
        try currentRate.serialize(to: &data)
    }

    init(
        length: UInt16,
        rateAuthority: PublicKey,
        initializationTimestamp: Int64,
        preUpdateAverageRate: Int16,
        lastUpdateTimestamp: Int64,
        currentRate: Int16
    ) {
        self.length = length
        self.rateAuthority = rateAuthority
        self.initializationTimestamp = initializationTimestamp
        self.preUpdateAverageRate = preUpdateAverageRate
        self.lastUpdateTimestamp = lastUpdateTimestamp
        self.currentRate = currentRate
    }
}
