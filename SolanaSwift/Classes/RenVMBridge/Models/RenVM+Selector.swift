//
//  RenVM+Selector.swift
//  SolanaSwift
//
//  Created by Chung Tran on 14/09/2021.
//

import Foundation

extension RenVM {
    struct Selector {
        let mintTokenSymbol: String
        let chainName: String
        let direction: Direction
        
        func toString() -> String {
            "\(mintTokenSymbol)/\(direction.rawValue)\(chainName.capitalizingFirstLetter())"
        }
        
        enum Direction: String {
            case from, to
        }
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}
