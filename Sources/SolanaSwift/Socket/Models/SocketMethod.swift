import Foundation

public enum SocketEntity: String {
    case account
    case signature
    case logs
    case program
    case slot
}

public enum SocketAction: String, CaseIterable {
    case subscribe
    case unsubscribe
    case notification
}

public struct SocketMethod: Equatable, RawRepresentable {
    public let entity: SocketEntity
    public let action: SocketAction

    public init(_ entity: SocketEntity, _ action: SocketAction) {
        self.entity = entity
        self.action = action
    }

    public var rawValue: String {
        entity.rawValue + action.rawValue.capitalizingFirstLetter()
    }

    public init?(rawValue: String) {
        for action in SocketAction.allCases {
            if rawValue.hasSuffix(action.rawValue.capitalizingFirstLetter()),
               let entity = SocketEntity(rawValue: rawValue
                   .replacingOccurrences(of: action.rawValue.capitalizingFirstLetter(), with: ""))
            {
                self.action = action
                self.entity = entity
                return
            }
        }
        return nil
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }
}
