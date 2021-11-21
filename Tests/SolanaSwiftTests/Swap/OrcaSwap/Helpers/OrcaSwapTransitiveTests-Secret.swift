//
//  File.swift
//  
//
//  Created by Chung Tran on 19/10/2021.
//

import Foundation

extension OrcaSwapTransitiveTests {
    var kuroPubkey: String {
        ProcessInfo.processInfo.environment["KURO_PUB_KEY"] ?? ""
    }
    
    var secretPhrase: String {
        ProcessInfo.processInfo.environment["SECRET_PHRASE"] ?? ""
    }
    
    var slimPubkey: String {
        ProcessInfo.processInfo.environment["SLIM_PUB_KEY"] ?? ""
    }
}
