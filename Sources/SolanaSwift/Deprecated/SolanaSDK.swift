//
//  SolanaSDK.swift
//  p2p wallet
//
//  Created by Chung Tran on 10/22/20.
//

import Foundation
import RxAlamofire
import Alamofire
import RxSwift
import LoggerSwift

@available(*, deprecated, renamed: "AccountStorageType", message: "This protocol is outdated")
public protocol SolanaSDKAccountStorage {
    var account: Account? {get}
    func save(_ account: Account) throws
}

@available(*, deprecated, message: "This class is no longer supported")
public class SolanaSDK {
    // MARK: - Properties
    public let accountStorage: SolanaSDKAccountStorage
    public private(set) var endpoint: APIEndPoint
    var supportedTokensCache: [Token]?
    
    // MARK: - Initializer
    public init(endpoint: APIEndPoint, accountStorage: SolanaSDKAccountStorage) {
        self.endpoint = endpoint
        self.accountStorage = accountStorage
    }
     
    // MARK: - Helper
    public func request<T: Decodable>(
        method: HTTPMethod = .post,
        overridingEndpoint: String? = nil,
        path: String = "",
        bcMethod: String = #function,
        parameters: [Encodable?] = [],
        onMethodNotFoundReplaceWith replacingMethod: String? = nil,
        log: Bool = true
    ) -> Single<T>{
        guard let url = URL(string: (overridingEndpoint != nil ? overridingEndpoint!: endpoint.getURL()) + path) else {
            return .error(SolanaError.invalidRequest(reason: "Invalid URL"))
        }
        let params = parameters.compactMap {$0}
        
        let bcMethod = bcMethod.replacingOccurrences(of: "\\([\\w\\s:]*\\)", with: "", options: .regularExpression)
        
        let requestAPI = RequestAPI(method: bcMethod, params: params)
        
        if log {
            Logger.log(event: .request, message: "\(method.rawValue) \(bcMethod) [id=\(requestAPI.id)] \(params.map(EncodableWrapper.init(wrapped:)).jsonString ?? "")")
        }
        
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: [.contentType("application/json")])
            urlRequest.httpBody = try JSONEncoder().encode(requestAPI)
            
            return RxAlamofire.request(urlRequest)
                .responseData()
                .map {(response, data) -> T in
                    // Print
                    
                    if log {
                        Logger.log(event: .response, message: String(data: data, encoding: .utf8) ?? "")
                    }
                    
                    let statusCode = response.statusCode
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
                    
                    throw SolanaError.invalidResponse(res.error ?? .init(code: statusCode, message: readableErrorMessage, data: nil))
                }
                .take(1)
                .asSingle()
                .catch {[weak self] error in
                    guard let self = self else {throw SolanaError.unknown}
                    if let error = error as? Error, let replacingMethod = replacingMethod
                    {
                        switch error {
                        case .invalidResponse(let response):
                            if response.message == "Method not found" {
                                return self.request(
                                    method: method,
                                    overridingEndpoint: overridingEndpoint,
                                    path: path,
                                    bcMethod: replacingMethod,
                                    parameters: parameters
                                )
                            }
                        default:
                            break
                        }
                    }
                    throw error
                }
        } catch {
            return .error(error)
        }
    }
}
