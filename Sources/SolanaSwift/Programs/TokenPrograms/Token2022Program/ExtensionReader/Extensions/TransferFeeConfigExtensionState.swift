import Foundation

public struct TransferFeeConfigExtensionState: Token2022ExtensionState {
    public struct TransferFee: BorshCodable, Codable, Equatable, Hashable {
        public let epoch: UInt64
        public let maximumFee: UInt64
        public let transferFeeBasisPoints: UInt16

        public init(from reader: inout BinaryReader) throws {
            epoch = try UInt64(from: &reader)
            maximumFee = try UInt64(from: &reader)
            transferFeeBasisPoints = try UInt16(from: &reader)
        }

        public func serialize(to data: inout Data) throws {
            try epoch.serialize(to: &data)
            try maximumFee.serialize(to: &data)
            try transferFeeBasisPoints.serialize(to: &data)
        }
    }

    public let length: UInt16
    /// Optional authority to set the fee
    public let transferFeeConfigAuthority: PublicKey
    /// Withdraw from mint instructions must be signed by this key
    public let withdrawWithHeldAuthority: PublicKey
    /// Withheld transfer fee tokens that have been moved to the mint for
    /// withdrawal
    public let withheldAmount: UInt64
    /// Older transfer fee, used if the current epoch < new_transfer_fee.epoch
    public let olderTransferFee: TransferFee
    /// Newer transfer fee, used if the current epoch >= new_transfer_fee.epoch
    public let newerTransferFee: TransferFee

    public init(from reader: inout BinaryReader) throws {
        length = try UInt16(from: &reader)
        transferFeeConfigAuthority = try PublicKey(from: &reader)
        withdrawWithHeldAuthority = try PublicKey(from: &reader)
        withheldAmount = try UInt64(from: &reader)
        olderTransferFee = try TransferFee(from: &reader)
        newerTransferFee = try TransferFee(from: &reader)
    }

    public func serialize(to data: inout Data) throws {
        try length.serialize(to: &data)
        try transferFeeConfigAuthority.serialize(to: &data)
        try withdrawWithHeldAuthority.serialize(to: &data)
        try withheldAmount.serialize(to: &data)
        try olderTransferFee.serialize(to: &data)
        try newerTransferFee.serialize(to: &data)
    }
}
