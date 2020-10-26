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
    private var id = 1
    
    // MARK: - Initializer
    public init(accountStorage: SolanaSDKAccountStorage) {
        self.accountStorage = accountStorage
    }
    
    // MARK: - Methods
    public func createAccount() throws -> Account {
        let account = try Account()
        try accountStorage.save(account)
        return account
    }
    
    public func getBalance() -> Single<Balance> {
        request(bcMethod: "getBalance", decodedTo: Balance.self)
    }
    
    // MARK: - Helper
    func request<T: Decodable>(
        method: HTTPMethod = .post,
        path: String = "",
        bcMethod: String,
        parameters: [Any] = [],
        decodedTo: T.Type
    ) -> Single<T>{
        guard let url = URL(string: endpoint + path) else {
            return .error(Error.invalidURL)
        }
        guard let account = accountStorage.account else {
            return .error(Error.accountNotFound)
        }
        var parameters = parameters
        parameters.append([account.publicKey.base58EncodedString])
        id += 1
        if id > 1000 {id=1}
        
        Logger.log(message: "\(method.rawValue) \(String(describing: (parameters as? Encodable)?.jsonString))", event: .request, apiMethod: bcMethod)
        
        return RxAlamofire.request(method, url, parameters: [
            "jsonrpc": "2.0",
            "id": id,
            "method": bcMethod,
            "params": parameters
        ])
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
    }
}
