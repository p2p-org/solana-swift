//
//  SerumSwap+Utils.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/08/2021.
//

import Foundation
import RxSwift

extension SerumSwap {
    static let SIGHASH_GLOBAL_NAMESPACE = "global"
    
    /// Return the program derived address used by the serum DEX to control token vaults.
    static func getVaultOwnerAndNonce(
        marketPublicKey: PublicKey,
        dexProgramId: PublicKey = .dexPID
    ) -> Single<(vaultOwner: PublicKey, nonce: UInt8)> {
        Single.create { observer in
            var nonce: UInt64 = 0
            while nonce < 255 {
                do {
                    let vaultOwner = try PublicKey.createProgramAddress(
                        seeds: [marketPublicKey.data, Data(nonce.bytes)],
                        programId: dexProgramId
                    )
                    observer(.success((vaultOwner: vaultOwner, nonce: UInt8(nonce))))
                    break
                } catch {
                    nonce += 1
                }
            }
            if nonce >= 255 {
                observer(.failure(SerumSwapError("Could not find vault owner")))
            }
            return Disposables.create()
        }
    }
    
    static func sighash(
        namespace: String = SIGHASH_GLOBAL_NAMESPACE,
        ixName: String
    ) throws -> Data {
        guard let name = ixName.snakeCased() else {
            throw SerumSwapError("ixName is not valid")
        }
        let preimage = "\(namespace):\(name)"
        let hexString = preimage.sha256()
        return Data(hex: hexString)[..<8]
    }
}

private extension String {
    func snakeCased() -> String? {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
    }
}
