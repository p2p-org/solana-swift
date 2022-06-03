import Foundation

/// Set new logger
public func setLogger(_ logger: LoggerType) {
    Logger = logger
}

/// Default logger for library
var Logger: LoggerType = DefaultLogger()

/// Logger event
public enum LoggerEvent: String {
    case error      =   "[‼️]"
    case info       =   "[ℹ️]"          // for guard & alert & route
    case debug      =   "[💬]"          // tested values & local notifications
    case verbose    =   "[🔬]"          // current values
    case warning    =   "[⚠️]"
    case severe     =   "[🔥]"          // tokens & keys & init & deinit
    case request    =   "[⬆️]"
    case response   =   "[⬇️]"
    case event      =   "[🎇]"
}

/// Logger type
public protocol LoggerType {
    func log(
        domain: String,
        event: LoggerEvent,
        message: String,
        fileName: String,
        line: Int,
        column: Int,
        funcName: String
    )
}

extension LoggerType {
    func log(
        event: LoggerEvent = .info,
        message: String,
        fileName: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function
    ) {
        log(domain: "SolanaSwift", event: event, message: message, fileName: fileName, line: line, column: column, funcName: funcName)
    }
}

/// Basic logger
struct DefaultLogger: LoggerType {
    public func log(
        domain: String,
        event: LoggerEvent,
        message: String,
        fileName: String,
        line: Int,
        column: Int,
        funcName: String
    ) {
    #if DEBUG
    print("\(event.rawValue)[\(domain)][\(fileName)]:\(line) \(column) \(funcName) -> \(message)")
    #endif
    }
}


