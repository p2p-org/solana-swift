//
//  Transaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation
import TweetNacl

public extension SolanaSDK {
    struct Transaction: Decodable {
        public var signatures: [UInt8]
        public var message: Message
        public var signaturesLength: Int? = 0
        
        enum CodingKeys: String, CodingKey {
            case message, signatures
        }
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            message = try values.decode(Message.self, forKey: .message)
            let strings = try values.decode([String].self, forKey: .signatures)
            signatures = strings.compactMap {UInt8($0)}
        }
        
        public init() {
            message = Message()
            signatures = []
        }
        
        public mutating func sign(signers: [Account], accountsModifier: (([Account.Meta]) -> [Account.Meta])? = nil) throws {
            let serializedMessage = try message.serialize(accountsModifier: accountsModifier)
            for signer in signers {
                let data = try NaclSign.signDetached(message: Data(serializedMessage), secretKey: signer.secretKey).bytes
                signatures.append(contentsOf: data)
            }
            signaturesLength = signers.count
        }
        
        public mutating func serialize(accountsModifier: (([Account.Meta]) -> [Account.Meta])? = nil) throws -> [UInt8] {
            let serializedMessage = try message.serialize(accountsModifier: accountsModifier)
            
            let signaturesLength = Data.encodeLength(UInt(self.signaturesLength ?? 1))
            
            var data = Data(capacity: signaturesLength.count + signatures.count + serializedMessage.count)
            data.append(signaturesLength)
            data.append(contentsOf: signatures)
            data.append(contentsOf: serializedMessage)
            return data.bytes
        }
        
        mutating func createAndInitializeAccount(
            ownerPubkey: PublicKey,
            mint: PublicKey,
            balance: UInt64,
            inNetwork network: Network
        ) throws -> Account {
            let newAccount = try Account(network: network)
            let newAccountPubkey = newAccount.publicKey
            
            let createAccountInstruction = SystemProgram.createAccountInstruction(
                from: ownerPubkey,
                toNewPubkey: newAccountPubkey,
                lamports: balance,
                space: UInt64(AccountInfo.BUFFER_LENGTH),
                programPubkey: .tokenProgramId
            )
            
            let initializeAccountInstruction = TokenProgram.initializeAccountInstruction(
                programId: .tokenProgramId,
                account: newAccountPubkey,
                mint: mint,
                owner: ownerPubkey
            )
            
            message.add(instruction: createAccountInstruction)
            message.add(instruction: initializeAccountInstruction)
            
            return newAccount
        }
        
        mutating func approve(
            tokenProgramId: PublicKey,
            account: PublicKey,
            delegate: PublicKey,
            owner: PublicKey,
            amount: UInt64
        ) {
            let approveInstruction = TokenProgram.approveInstruction(
                tokenProgramId: .tokenProgramId,
                account: account,
                delegate: delegate,
                owner: owner,
                amount: amount
            )
            message.add(instruction: approveInstruction)
        }
        
        mutating func swap(
            swapProgramId: PublicKey,
            pool: Pool,
            userSource: PublicKey,
            userDestination: PublicKey,
            amount: UInt64,
            minAmountIn: UInt64
        ) throws {
            guard let poolAuthority = pool.authority else {throw SolanaSDK.Error.other("pool authority is not valid")}
            let instruction = TokenSwapProgram.swapInstruction(
                tokenSwapAccount: pool.address,
                authority: poolAuthority,
                userSource: userSource,
                poolSource: pool.swapData.tokenAccountA,
                poolDestination: pool.swapData.tokenAccountB,
                userDestination: userDestination,
                poolMint: pool.swapData.tokenPool,
                feeAccount: pool.swapData.feeAccount,
                hostFeeAccount: pool.swapData.feeAccount,
                tokenProgramId: .tokenProgramId,
                swapProgramId: swapProgramId,
                amountIn: amount,
                minimumAmountOut: minAmountIn
            )
            message.add(instruction: instruction)
        }
        
        mutating func closeAccount(_ account: PublicKey, destination: PublicKey, owner: PublicKey) {
            let closeInstruction = TokenProgram.closeAccountInstruction(tokenProgramId: .tokenProgramId, account: account, destination: destination, owner: owner)
            message.add(instruction: closeInstruction)
        }
    }
}

public extension SolanaSDK.Transaction {
    struct Instruction: Decodable {
        public let accounts: [UInt64]?
        public let programIdIndex: UInt32?
        public let data: String?
    }
    
    struct Error: Decodable, Hashable {
        
    }
    
    struct Meta: Decodable {
        public let err: Error?
        public let fee: UInt64
        public let preBalances: [UInt64]
        public let postBalances: [UInt64]
    }
    
    struct Info: Decodable {
        public let meta: Meta?
        public let transaction: SolanaSDK.Transaction
        public let slot: UInt64?
    }
    
    struct SignatureInfo: Decodable, Hashable {
        public let signature: String
        public let slot: UInt64?
        public let err: Error?
        public let memo: String?
        
        public init(signature: String) {
            self.signature = signature
            self.slot = nil
            self.err = nil
            self.memo = nil
        }
    }
    
    struct Status: Decodable {
        public let err: Error?
        public let logs: [String]
    }
}
