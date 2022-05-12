import Foundation

public enum BufferLayoutError: Error {
    case NotImplemented
}
public protocol BufferLayout: Codable, BorshCodable {
    static var BUFFER_LENGTH: UInt64 { get }
}

extension BufferLayout {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
//        // decode parsedJSON
//        if let parsedData = try? container.decode(Self.self) {
//            self = parsedData
//            return
//        }
        
        // Unable to get parsed data, fallback to decoding base64
        let stringData = (try? container.decode([String].self).first) ?? (try? container.decode(String.self))
        guard let string = stringData,
              let data = Data(base64Encoded: string)
        else {
            throw SolanaError.couldNotRetrieveAccountInfo
        }
        
        if string.isEmpty && !(Self.self == EmptyInfo.self) {
            throw SolanaError.couldNotRetrieveAccountInfo
        }
        
        do {
            var reader = BinaryReader(bytes: data.bytes)
            try self.init(from: &reader)
        } catch {
            throw SolanaError.couldNotRetrieveAccountInfo
        }
    }
}
