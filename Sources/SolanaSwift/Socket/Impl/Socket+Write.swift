//
//  File.swift
//  
//
//  Created by Chung Tran on 13/05/2022.
//

import Foundation

extension Socket {
    /// Write message to socket
    /// - Parameters:
    ///   - method: method to write
    ///   - params: additional params
    /// - Returns: id of the subscription
    @discardableResult func write(method: SocketMethod, params: [Encodable]) -> String {
        let requestAPI = RequestAPI(
            method: method.rawValue,
            params: params
        )
        write(requestAPI: requestAPI)
        return requestAPI.id
    }
}
