//
//  SerumSwap+Version.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/08/2021.
//

import Foundation

extension SerumSwap {
    private static var PROGRAM_LAYOUT_VERSIONS: [String: Int] { [
        "4ckmDgGdxQoPDLUkDT3vHgSAkzA3QRdNq5ywwY4sUSJn": 1,
        "BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg": 1,
        "EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o": 2,
        "9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin": 3
    ] }

    static func getVersion(programId: String) -> Int {
        PROGRAM_LAYOUT_VERSIONS[programId] ?? 3
    }
}
