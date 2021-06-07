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

public protocol SolanaSDKAccountStorage {
    func save(_ account: SolanaSDK.Account) throws
    var account: SolanaSDK.Account? {get}
    func clear()
}

public class SolanaSDK {
    // MARK: - Properties
    public let accountStorage: SolanaSDKAccountStorage
    var endpoint: APIEndPoint
    public private(set) var supportedTokens = [Token]()
    
    // MARK: - Initializer
    public init(endpoint: APIEndPoint, accountStorage: SolanaSDKAccountStorage) {
        self.endpoint = endpoint
        self.accountStorage = accountStorage
        
        // get supported tokens
        let parser = TokensListParser()
        supportedTokens = (try? parser.parse(network: endpoint.network.cluster)) ?? []
    }
     
    // MARK: - Helper
    public func request<T: Decodable>(
        method: HTTPMethod = .post,
        overridingEndpoint: String? = nil,
        path: String = "",
        bcMethod: String = #function,
        parameters: [Encodable?] = [],
        onMethodNotFoundReplaceWith replacingMethod: String? = nil
    ) -> Single<T>{
        guard let url = URL(string: (overridingEndpoint != nil ? overridingEndpoint!: endpoint.url) + path) else {
            return .error(Error.invalidRequest(reason: "Invalid URL"))
        }
        let params = parameters.compactMap {$0}
        
        let bcMethod = bcMethod.replacingOccurrences(of: "\\([\\w\\s:]*\\)", with: "", options: .regularExpression)
        
        let requestAPI = RequestAPI(method: bcMethod, params: params)
        
        Logger.log(message: "\(method.rawValue) \(bcMethod) [id=\(requestAPI.id)] \(params.map(EncodableWrapper.init(wrapped:)).jsonString ?? "")", event: .request, apiMethod: bcMethod)
        
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: [.contentType("application/json")])
            urlRequest.httpBody = try JSONEncoder().encode(requestAPI)
            
            return RxAlamofire.request(urlRequest)
                .responseData()
                .map {(response, data) -> T in
                    // Print
                    Logger.log(message: String(data: data, encoding: .utf8) ?? "", event: .response, apiMethod: bcMethod)
                    
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
                    
                    throw Error.invalidResponse(.init(code: statusCode, message: readableErrorMessage, data: nil))
                }
                .take(1)
                .asSingle()
                .catch { error in
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
