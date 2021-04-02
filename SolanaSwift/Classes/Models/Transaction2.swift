//
//  Transaction2.swift
//  SolanaSwift
//
//  Created by Chung Tran on 02/04/2021.
//

import Foundation
import TweetNacl

public extension SolanaSDK {
    struct Transaction2 {
        var signatures = [UInt8]()
        let feePayer: Account
        var instructions = [TransactionInstruction]()
        let recentBlockhash: String
//        TODO: nonceInfo
        
        mutating func add(instruction: TransactionInstruction) {
            instructions.append(instruction)
        }
        
        mutating func add(instructions: [TransactionInstruction]) {
            instructions.forEach {self.instructions.append($0)}
        }
        
        // MARK: - Helper
        private func compileMessage() throws {
            // verify instructions
            guard instructions.count > 0 else {
                throw Error.other("No instructions provided")
            }
            
            // programIds & accountMetas
            var programIds = [PublicKey]()
            var accountMetas = [Account.Meta]()
            
            for instruction in instructions {
                accountMetas.append(contentsOf: instruction.keys)
                if !programIds.contains(instruction.programId) {
                    programIds.append(instruction.programId)
                }
            }
            
            for programId in programIds {
                accountMetas.append(
                    .init(publicKey: programId, isSigner: false, isWritable: false)
                )
            }
            
            // sort accountMetas, first by signer, then by writable
            accountMetas.sort { (x, y) -> Bool in
                if x.isSigner != y.isSigner {return x.isSigner}
                if x.isWritable != y.isWritable {return x.isWritable}
                return false
            }
            
            // filterOut duplicate account metas, keeps writable one
            accountMetas = accountMetas.reduce([Account.Meta](), {result, accountMeta in
                var uniqueMetas = result
                if let index = uniqueMetas.firstIndex(where: {$0.publicKey == accountMeta.publicKey}) {
                    // if accountMeta exists
                    uniqueMetas[index].isWritable = uniqueMetas[index].isWritable || accountMeta.isWritable
                } else {
                    uniqueMetas.append(accountMeta)
                }
                return uniqueMetas
            })
            
            // move fee payer to front
            accountMetas.removeAll(where: {$0.publicKey == feePayer.publicKey})
            accountMetas.insert(
                Account.Meta(publicKey: feePayer.publicKey, isSigner: true, isWritable: true),
                at: 0
            )
            
            // disallow unknown signers
            
        }
    }
}
