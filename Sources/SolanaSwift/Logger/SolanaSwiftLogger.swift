import Foundation

public enum SolanaSwiftLoggerLogLevel: String {
    case info
    case error
    case warning
    case debug
}

public protocol SolanaSwiftLogger {
    func log(event: String, data: String?, logLevel: SolanaSwiftLoggerLogLevel)
}

public enum Logger {
    // MARK: -

    private static var loggers: [SolanaSwiftLogger] = []

    public static func setLoggers(_ loggers: [SolanaSwiftLogger]) {
        self.loggers = loggers
    }

    public static func log(event: String, message: String?, logLevel: SolanaSwiftLoggerLogLevel = .info) {
        loggers.forEach { $0.log(event: event, data: message, logLevel: logLevel) }
    }
}
