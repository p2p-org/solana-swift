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
}

public class SolanaSDK {
    // MARK: - Properties
//    let endpoint: String
    public let network: Network
    public let accountStorage: SolanaSDKAccountStorage
    var endpoint: String {network.endpoint}
    
    // MARK: - Initializer
    public init(network: Network, accountStorage: SolanaSDKAccountStorage) {
        self.network = network
        self.accountStorage = accountStorage
    }
     
    // MARK: - Helper
    public func request<T: Decodable>(
        method: HTTPMethod = .post,
        path: String = "",
        bcMethod: String = #function,
        parameters: [Encodable?] = []
    ) -> Single<T>{
        guard let url = URL(string: endpoint + path) else {
            return .error(Error.invalidURL)
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
                    
                    // Print
                    guard (200..<300).contains(response.statusCode) else {
                        // Decode errror
                        throw Error.invalidStatusCode(code: response.statusCode)
                    }
                    let response = try JSONDecoder().decode(Response<T>.self, from: data)
                    if let result = response.result {
                        return result
                    }
                    if let error = response.error {
                        throw Error.responseError(error)
                    }
                    throw Error.unknown
                }
                .take(1)
                .asSingle()
        } catch {
            return .error(error)
        }
    }
}
