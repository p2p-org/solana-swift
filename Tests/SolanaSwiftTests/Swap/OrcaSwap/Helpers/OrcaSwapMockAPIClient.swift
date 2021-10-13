//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift
@testable import SolanaSwift

extension OrcaSwap {
    struct MockAPIClient: OrcaSwapAPIClient {
        let network: String
        
        func get<T: Decodable>(type: String) -> Single<T> {
            let data = getFileFrom(type: type, network: network)
            return .just(try! JSONDecoder().decode(T.self, from: data))
        }
    }
}

func getFileFrom(type: String, network: String) -> Data {
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("../../../Resources/Orca/\(type)/orca-\(type)-\(network).json")
    return try! Data(contentsOf: resourceURL)
}
