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
        dexProgramId: PublicKey
    ) -> Single<(vaultOwner: PublicKey, nonce: UInt8)> {
        Single.create { observer in
            do {
                let address = try PublicKey.findProgramAddress(
                    seeds: [marketPublicKey.data],
                    programId: dexProgramId
                )
                observer(.success(address))
            } catch {
                observer(.failure(error))
            }
            
            return Disposables.create()
        }
    }
}
