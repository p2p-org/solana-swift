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
            let url = Bundle(for: MockClass.self).url(forResource: "orca-\(type)-\(network)", withExtension: "json")!
            let data = try! Data(contentsOf: url)
            return .just(try! JSONDecoder().decode(T.self, from: data))
        }
    }
}

private class MockClass {}
