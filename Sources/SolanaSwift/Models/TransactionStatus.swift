import Foundation

public enum TransactionStatus: Equatable, Hashable {
    case requesting
    case processing(percent: Double)
    case confirmed
    case error(String?)
    
    public func getError() -> Error? {
        switch self {
        case .error(let err) where err != nil:
            return SolanaError.other(err!)
        default:
            break
        }
        return nil
    }
    
    public var rawValue: String {
        switch self {
        case .requesting:
            return "requesting"
        case .processing:
            return "processing"
        case .confirmed:
            return "confirmed"
        case .error:
            return "error"
        }
    }
}
