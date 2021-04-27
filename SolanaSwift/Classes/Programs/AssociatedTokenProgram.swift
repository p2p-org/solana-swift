//
//  AssociatedTokenProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 27/04/2021.
//

import Foundation
import TweetNacl

extension SolanaSDK.PublicKey {
    // MARK: - Constants
    private static var maxSeedLength = 32
    private static let gf1 = NaclLowLevel.gf([1])
    
    // MARK: - Interface
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
    
    // MARK: - Helpers
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
        var r = [[Float64]](repeating: NaclLowLevel.gf(), count: 4)
        
        var t = NaclLowLevel.gf(),
            chk = NaclLowLevel.gf(),
            num = NaclLowLevel.gf(),
            den = NaclLowLevel.gf(),
            den2 = NaclLowLevel.gf(),
            den4 = NaclLowLevel.gf(),
            den6 = NaclLowLevel.gf()
        
        NaclLowLevel.set25519(r: &r[2], a: gf1)
    }
}
