//
//  RenVM+Session.swift
//  SolanaSwift
//
//  Created by Chung Tran on 16/09/2021.
//

import Foundation

extension RenVM {
    public struct Session: Codable {
        /// New session, default expiring time is 3 days
        public init(
            nonce: String? = nil,
            createdAt: Date = Date(),
            endAt: Date? = nil
        ) throws {
            if let endAt = endAt, endAt > createdAt {
                throw Error("Invalid session")
            }
            
            self.nonce = nonce ?? generateNonce(sessionDay: Long(createdAt.timeIntervalSince1970 / 60 / 60 / 24) )
            self.createdAt = createdAt
            
            guard let endAt = endAt ?? Calendar.current.date(byAdding: .hour, value: 36, to: createdAt)
            else {
                throw Error("Invalid session")
            }
            self.endAt = endAt
        }
        
        public var nonce: String
        public var createdAt: Date
        public var endAt: Date
    }
}

private extension String {
    func getBytes() -> Data? {
        data(using: .utf8)
    }
}

private func generateNonce(sessionDay: Long) -> String {
    let string = String(repeating: " ", count: 28) + sessionDay.hexString
    let data = string.getBytes() ?? Data()
    return data.hexString
}
