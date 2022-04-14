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

extension Task where Failure == Error {
    @discardableResult
    static func retrying(
        where condition: @escaping (Error) -> Bool,
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                do {
                    return try await operation()
                } catch {
                    if condition(error) {
                        let oneSecond = TimeInterval(1_000_000_000)
    let delay = UInt64(oneSecond * retryDelay)
    try await Task<Never, Never>.sleep(nanoseconds: delay)

                        continue
                    } else {
                        throw error
                    }
                }
            }

            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}
