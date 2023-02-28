//
//  AccountStub.swift
//  
//
//  Created by Kamil Wyszomierski on 21/06/2022.
//

import Foundation
import SolanaSwift

extension KeyPair {

    enum StubFactory {

        static func make() -> KeyPair {
            try! .init(secretKey: .init([UInt8].StubFactory.make(length: 64)))
        }
    }
}
