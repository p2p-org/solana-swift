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
        private var signatures = [Signature]()
        let feePayer: PublicKey
        var instructions = [TransactionInstruction]()
        let recentBlockhash: String
//        TODO: nonceInfo
        
        init(signatures: [SolanaSDK.Transaction2.Signature] = [Signature](), feePayer: SolanaSDK.PublicKey, instructions: [SolanaSDK.TransactionInstruction] = [TransactionInstruction](), recentBlockhash: String) {
            self.signatures = signatures
            self.feePayer = feePayer
            self.instructions = instructions
            self.recentBlockhash = recentBlockhash
        }
        
        // MARK: - Methods
        mutating func sign(signers: [Account]) throws {
            guard signers.count > 0 else {throw Error.invalidRequest(reason: "No signers")}
            
            // unique signers
            let signers = signers.reduce([Account](), {signers, signer in
                var uniqueSigners = signers
                if !uniqueSigners.contains(where: {$0.publicKey == signer.publicKey})
                {
                    uniqueSigners.append(signer)
                }
                return uniqueSigners
            })
            
            // map signatures
            signatures = signers.map {Signature(signature: nil, publicKey: $0.publicKey)}
            
            // construct message
            let message = try compile()
            
            try partialSign(message: message, signers: signers)
        }
        
        mutating func serialize(
//            requiredAllSignatures: Bool = true,
//            verifySignatures: Bool = true
        ) throws -> Data {
            // message
            let serializedMessage = try serializeMessage()
            
            // verification
//            if verifySignatures && _verifySignatures(serializedMessage: serializedMessage, requiredAllSignatures: requiredAllSignatures)
//            {
//                throw Error.invalidRequest(reason: "Signature verification failed")
//            }
            
            return _serialize(serializedMessage: serializedMessage)
        }
        
        
        // MARK: - Helpers
        mutating func addSignature(_ signature: Signature) throws {
            let _ = try compile() // Ensure signatures array is populated
            
            try _addSignature(signature)
        }
        
        mutating func serializeMessage() throws -> Data {
            try compile().serialize()
        }
        
        mutating func verifySignatures() throws -> Bool {
            _verifySignatures(serializedMessage: try serializeMessage(), requiredAllSignatures: true)
        }
        
        // MARK: - Signing
        private mutating func partialSign(message: Message2, signers: [Account]) throws {
            let signData = try message.serialize()
            
            for signer in signers {
                let data = try NaclSign.signDetached(message: signData, secretKey: signer.secretKey)
                try _addSignature(Signature(signature: data, publicKey: signer.publicKey))
            }
        }
        
        private mutating func _addSignature(_ signature: Signature) throws {
            guard let data = signature.signature,
                  data.count == 64,
                  let index = signatures.firstIndex(where: {$0.publicKey == signature.publicKey})
            else {
                throw Error.other("Signer not valid: \(signature.publicKey.base58EncodedString)")
            }
            
            signatures[index] = signature
        }
        
        // MARK: - Compiling
        private mutating func compile() throws -> Message2 {
            let message = try compileMessage()
            let signedKeys = message.accountKeys.filter {$0.isSigner}
            
            if signatures.count == signedKeys.count {
                var isValid = true
                for (index, signature) in signatures.enumerated() {
                    if signedKeys[index].publicKey != signature.publicKey {
                        isValid = false
                        break
                    }
                }
                if isValid {
                    return message
                }
            }
            
            signatures = signedKeys.map {Signature(signature: nil, publicKey: $0.publicKey)}
            return message
        }
        
        private func compileMessage() throws -> Message2 {
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
            accountMetas.removeAll(where: {$0.publicKey == feePayer})
            accountMetas.insert(
                Account.Meta(publicKey: feePayer, isSigner: true, isWritable: true),
                at: 0
            )
            
            // verify signers
            for signature in signatures {
                if let index = try? accountMetas.index(ofElementWithPublicKey: signature.publicKey)
                {
                    if !accountMetas[index].isSigner {
//                        accountMetas[index].isSigner = true
//                        Logger.log(message: "Transaction references a signature that is unnecessary, only the fee payer and instruction signer accounts should sign a transaction. This behavior is deprecated and will throw an error in the next major version release.", event: .warning)
                        throw Error.invalidRequest(reason: "Transaction references a signature that is unnecessary")
                    }
                } else {
                    throw Error.invalidRequest(reason: "Unknown signer: \(signature.publicKey.base58EncodedString)")
                }
            }
            
            // header
            var header = Message2.Header()
            
            var signedKeys = [Account.Meta]()
            var unsignedKeys = [Account.Meta]()
            
            for accountMeta in accountMetas {
                // signed keys
                if accountMeta.isSigner {
                    signedKeys.append(accountMeta)
                    header.numRequiredSignatures += 1
                    
                    if !accountMeta.isWritable {
                        header.numReadonlySignedAccounts += 1
                    }
                }
                
                // unsigned keys
                else {
                    unsignedKeys.append(accountMeta)
                    
                    if !accountMeta.isWritable {
                        header.numReadonlyUnsignedAccounts += 1
                    }
                }
            }
            
            accountMetas = signedKeys + unsignedKeys
            
            return Message2(
                accountKeys: accountMetas,
                recentBlockhash: recentBlockhash,
                programInstructions: instructions
            )
        }
        
        // MARK: - Verifying
        private mutating func _verifySignatures(
            serializedMessage: Data,
            requiredAllSignatures: Bool
        ) -> Bool {
            for signature in signatures {
                if signature.signature == nil {
                    if requiredAllSignatures {
                        return false
                    }
                } else {
                    if (try? NaclSign.signDetachedVerify(message: serializedMessage, sig: signature.signature!, publicKey: signature.publicKey.data)) != true
                    {
                        return false
                    }
                }
            }
            return true
        }
        
        // MARK: - Serializing
        private mutating func _serialize(serializedMessage: Data) -> Data {
            // signature length
            let encodedSignatureLength = Data.encodeLength(signatures.count)
            
            // signature data
            let signaturesData = signatures.reduce(Data(), {result, signature in
                var data = result
                data.append(signature.signature!)
                return data
            })
            
            // transaction length
            var data = Data(capacity: encodedSignatureLength.count + signaturesData.count + serializedMessage.count)
            data.append(encodedSignatureLength)
            data.append(signaturesData)
            data.append(serializedMessage)
            return data
        }
    }
}

extension SolanaSDK.Transaction2 {
    struct Signature {
        var signature: Data?
        var publicKey: SolanaSDK.PublicKey
    }
}
