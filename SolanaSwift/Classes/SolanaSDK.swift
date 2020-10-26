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
    #if DEBUG
    let endpoint = "https://testnet.solana.com"
    #else
    let endpoint = ""
    #endif
    let accountStorage: SolanaSDKAccountStorage
    
    // MARK: - Initializer
    public init(accountStorage: SolanaSDKAccountStorage) {
        self.accountStorage = accountStorage
    }
    
    // MARK: - Methods
    @discardableResult
    public func createAccount() throws -> Account {
        let account = try Account()
        try accountStorage.save(account)
        return account
    }
    
    public func getAccountInfo() -> Single<AccountInfo> {
        request(bcMethod: "getAccountInfo", parameters: [["encoding": "base58"]])
    }
    
    public func getBalance() -> Single<Balance> {
        request(bcMethod: "getBalance")
    }
    
    #if DEBUG
    public func requestAirdrop(value: UInt = 89588000) -> Single<String> {
        request(bcMethod: "requestAirdrop", parameters: [value])
    }
    #endif
    
    // MARK: - Helper
    func request<T: Decodable>(
        method: HTTPMethod = .post,
        path: String = "",
        bcMethod: String,
        parameters: [Encodable] = []
    ) -> Single<T>{
        guard let url = URL(string: endpoint + path) else {
            return .error(Error.invalidURL)
        }
        guard let account = accountStorage.account else {
            return .error(Error.accountNotFound)
        }
        var params = parameters
        params.insert(account.publicKey.base58EncodedString, at: 0)
        
        Logger.log(message: "\(method.rawValue) \(bcMethod) \(params.map(EncodableWrapper.init(wrapped:)).jsonString ?? "")", event: .request, apiMethod: bcMethod)
        
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: [.contentType("application/json")])
            
            let requestAPI = RequestAPI(method: bcMethod, jsonrpc: "2.0", params: params
            )
            urlRequest.httpBody = try JSONEncoder().encode(requestAPI)
            return RxAlamofire.request(urlRequest)
                .responseData()
                .map {(response, data) -> Response<T> in
                    // Print
                    Logger.log(message: String(data: data, encoding: .utf8) ?? "", event: .response, apiMethod: bcMethod)
                    
                    // Print
                    guard (200..<300).contains(response.statusCode) else {
                        // Decode errror
                        throw Error.invalidStatusCode(code: response.statusCode)
                    }
                    return try JSONDecoder().decode(Response<T>.self, from: data)
                }
                .take(1)
                .asSingle()
                .map {$0.result}
        } catch {
            return .error(error)
        }
    }
}
