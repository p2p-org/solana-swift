//
//  AssociatedTokenProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 27/04/2021.
//

import Foundation
import TweetNacl

extension SolanaSDK.PublicKey {
    private static var maxSeedLength = 32
    
    public static func findProgramAddress(
        seeds: [Data],
        programId: SolanaSDK.PublicKey = .splAssociatedTokenAccountProgramId
    ) throws -> (SolanaSDK.PublicKey, UInt8) {
        for nonce in stride(from: UInt8(255), to: 0, by: -1) {
            let seedsWithNonce = seeds + [Data([nonce])]
            do {
                let address = try createProgramAddress(
                    seeds: seedsWithNonce,
                    programId: programId
                )
                return (address, nonce)
            } catch {
                continue
            }
        }
        throw SolanaSDK.Error.notFound
    }
    
    private static func createProgramAddress(
        seeds: [Data],
        programId: SolanaSDK.PublicKey
    ) throws -> SolanaSDK.PublicKey {
        // construct data
        var data = Data()
        for seed in seeds {
            if seed.bytes.count > maxSeedLength {
                throw SolanaSDK.Error.other("Max seed length exceeded")
            }
            data.append(seed)
        }
        data.append(programId.data)
        data.append("ProgramDerivedAddress".data(using: .utf8)!)
        
        // hash it
        let hash = data.sha256()
        let publicKeyBytes = Bignum(number: hash.hexString, withBase: 16).data
        
    }
    
    private static func isOnCurve() {
        
    }
}
