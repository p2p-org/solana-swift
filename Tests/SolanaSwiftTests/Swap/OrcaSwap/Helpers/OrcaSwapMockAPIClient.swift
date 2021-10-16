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
    
    struct MockSolanaClient: OrcaSwapSolanaClient {
        func getTokenAccountBalance(pubkey: String, commitment: SolanaSDK.Commitment?) -> Single<SolanaSDK.TokenAccountBalance> {
            // BTC/ETH
            if pubkey == "81w3VGbnszMKpUwh9EzAF9LpRzkKxc5XYCW64fuYk1jH" {
                return .just(.init(uiAmount: 0.001014, amount: "1014", decimals: 6, uiAmountString: "0.001014"))
            }
            if pubkey == "6r14WvGMaR1xGMnaU8JKeuDK38RvUNxJfoXtycUKtC7Z" {
                return .just(.init(uiAmount: 0.016914, amount: "16914", decimals: 6, uiAmountString: "0.016914"))
            }
            
            // BTC/SOL[aquafarm]
            if pubkey == "9G5TBPbEUg2iaFxJ29uVAT8ZzxY77esRshyHiLYZKRh8" {
                return .just(.init(uiAmount: 18.448748, amount: "18448748", decimals: 6, uiAmountString: "18.448748"))
            }
            if pubkey == "5eqcnUasgU2NRrEAeWxvFVRTTYWJWfAJhsdffvc6nJc2" {
                return .just(.init(uiAmount: 7218.011507888, amount: "7218011507888", decimals: 9, uiAmountString: "7218.011507888"))
            }
            
            // ETH/SOL
            if pubkey == "FidGus13X2HPzd3cuBEFSq32UcBQkF68niwvP6bM4fs2" {
                return .just(.init(uiAmount: 0.57422, amount: "574220", decimals: 6, uiAmountString: "0.57422"))
            }
            if pubkey == "5x1amFuGMfUVzy49Y4Pc3HyCVD2usjLaofnzB3d8h7rv" {
                return .just(.init(uiAmount: 13.997148152, amount: "13997148152", decimals: 9, uiAmountString: "13.997148152"))
            }
            
            // ETH/SOL[aquafarm]
            if pubkey == "7F2cLdio3i6CCJaypj9VfNDPW2DwT3vkDmZJDEfmxu6A" {
                return .just(.init(uiAmount: 4252.752761, amount: "4252752761", decimals: 6, uiAmountString: "4252.752761"))
            }
            if pubkey == "5pUTGvN2AA2BEzBDU4CNDh3LHER15WS6J8oJf5XeZFD8" {
                return .just(.init(uiAmount: 103486.885774058, amount: "103486885774058", decimals: 9, uiAmountString: "103486.885774058"))
            }
            
            // SOCN/SOL
            if pubkey == "C8DRXUqxXtUgvgBR7BPAmy6tnRJYgVjG27VU44wWDMNV" {
                return .just(.init(uiAmount: 20097.450122295, amount: "20097450122295", decimals: 9, uiAmountString: "20097.450122295"))
            }
            
            if pubkey == "DzdxH5qJ68PiM1p5o6PbPLPpDj8m1ZshcaMFATcxDZix" {
                return .just(.init(uiAmount: 27474.561069286, amount: "27474561069286", decimals: 9, uiAmountString: "27474.561069286"))
            }
            
            fatalError()
        }
    }
}

func getFileFrom(type: String, network: String) -> Data {
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("../../../Resources/Orca/\(type)/orca-\(type)-\(network).json")
    return try! Data(contentsOf: resourceURL)
}
