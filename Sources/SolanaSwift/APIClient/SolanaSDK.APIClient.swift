//
//  File.swift
//  
//
//  Created by Chung Tran on 13/04/2022.
//

import Foundation

extension SolanaSDK {
    public actor APIClient {
        // MARK: - Nested type
        public enum HTTPMethod: String {
            case get, post
        }
        public enum Error: Swift.Error, Equatable {
            case invalidRequest(reason: String? = nil)
            case invalidResponse(ResponseError)
            case couldNotRetrieveAccountInfo
            case blockhashNotFound
            case invalidSignatureStatus
            case transactionError(TransactionError, logs: [String])
            case transactionHasNotBeenConfirmed
            case unknown
        }
        
        // MARK: - Properties
        public internal(set) var endpoint: APIEndPoint
        
        // MARK: - Initializer
        init(endpoint: APIEndPoint) {
            self.endpoint = endpoint
        }
        
        // MARK: - Methods
        /// Generic method for sending multiple types of requests
        /// - Parameters:
        ///   - method: HTTP method
        ///   - overridingEndpoint: (Optional) the endpoint that hardcoded
        ///   - path: path, for example "/users"
        ///   - bcMethod: blockchain method, ex: getBalance
        ///   - parameters: parameter for request
        ///   - replacingMethod: (Optional) replacing method in case the original method is deprecated, deleted
        ///   - log: boolean that indicates if logging is enabled
        ///   - retried: mark if retried
        /// - Returns: Decoded data
        public func request<T: Decodable>(
            method: HTTPMethod = .post,
            overridingEndpoint: String? = nil,
            path: String = "",
            bcMethod: String = #function,
            parameters: [Encodable?] = [],
            onMethodNotFoundReplaceWith replacingMethod: String? = nil,
            log: Bool = true,
            retried: Bool = false
        ) async throws -> T {
            // Prepare url
            guard let url = URL(string: (overridingEndpoint != nil ? overridingEndpoint!: endpoint.getURL()) + path) else {
                throw Error.invalidRequest(reason: "Invalid URL")
            }
            let params = parameters.compactMap {$0}
            
            let bcMethod = bcMethod.replacingOccurrences(of: "\\([\\w\\s:]*\\)", with: "", options: .regularExpression)
            
            let requestAPI = RequestAPI(method: bcMethod, params: params)
            
            if log {
                Logger.log(message: "\(method.rawValue) \(bcMethod) [id=\(requestAPI.id)] \(params.map(EncodableWrapper.init(wrapped:)).jsonString ?? "")", event: .request, apiMethod: bcMethod)
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue.uppercased()
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(requestAPI)
            
            let session = URLSession.shared
            let (data, response) = try await session.data(for: urlRequest)
            
            if log {
                Logger.log(message: String(data: data, encoding: .utf8) ?? "", event: .response, apiMethod: bcMethod)
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 404
            let isValidStatusCode = (200..<300).contains(statusCode)
            
            let res = try JSONDecoder().decode(Response<T>.self, from: data)
            
            if isValidStatusCode, let result = res.result {
                return result
            }
            
            var readableErrorMessage: String?
            if let error = res.error {
                readableErrorMessage = error.message?
                    .replacingOccurrences(of: ", contact your app developer or support@rpcpool.com.", with: "")
            }

            let responseError = res.error ?? .init(code: statusCode, message: readableErrorMessage, data: nil)
            
            if responseError.message == "Method not found",
               !retried,
               let replacingMethod = replacingMethod
            {
                return try await request(
                    method: method,
                    overridingEndpoint: overridingEndpoint,
                    path: path,
                    bcMethod: replacingMethod,
                    parameters: parameters,
                    retried: true
                )
            }
            
            throw Error.invalidResponse(responseError)
        }
    }
}
