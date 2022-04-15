//
//  File.swift
//  
//
//  Created by Chung Tran on 13/04/2022.
//

import Foundation

@available(macOS, deprecated: 12.0, message: "Use the built-in API instead")
extension URLSession {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
    
    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
}

public enum CustomTaskError: Error {
    case timedOut
}

extension Task where Failure == Error {
    @discardableResult
    static func retrying(
        where condition: @escaping (Error) -> Bool,
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1,
        timeout: TimeInterval? = nil,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        let oneSecond = TimeInterval(1_000_000_000)
        let delay = UInt64(oneSecond * retryDelay)
        
        let startAt = Date()
        let deadline: Date?
        if let timeout = timeout {
            deadline = Date(timeInterval: oneSecond * timeout, since: startAt)
        } else {
            deadline = nil
        }
        return Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                do {
                    if let deadline = deadline, Date() >= deadline {
                        throw CustomTaskError.timedOut
                    }
                    return try await operation()
                } catch {
                    guard condition(error) else {throw error}
                    
                    try await Task<Never, Never>.sleep(nanoseconds: delay)
                    continue
                }
            }

            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}
