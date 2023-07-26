import Foundation

public protocol IMessage {
    var version: TransactionVersion { get }
    var header: MessageHeader { get }
    var recentBlockhash: String { get }

    func serialize() throws -> Data

    var staticAccountKeys: [PublicKey] { get }
}
