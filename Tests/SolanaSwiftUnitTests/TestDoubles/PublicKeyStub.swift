//
//  PublicKeyStub.swift
//  
//
//  Created by Kamil Wyszomierski on 21/06/2022.
//

import Foundation
import SolanaSwift

extension PublicKey {

    enum StubFactory {

        static func make() -> PublicKey {
            try! .init(bytes: .StubFactory.make(length: 32, range: 0..<UInt8.max))
        }
    }
}
