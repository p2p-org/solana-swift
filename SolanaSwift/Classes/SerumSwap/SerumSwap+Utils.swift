//
//  SerumSwap+Utils.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/08/2021.
//

import Foundation
import RxSwift

extension SerumSwap {
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
}
