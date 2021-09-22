//
//  RenVM+SolanaChain.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import RxSwift
import BufferLayoutSwift

public protocol RenVMSolanaAPIClientType {
    func getAccountInfo<T: DecodableBufferLayout>(account: String, decodedTo: T.Type) -> Single<SolanaSDK.BufferInfo<T>>
    func getMintData(
        mintAddress: String,
        programId: String
    ) -> Single<SolanaSDK.Mint>
    func getConfirmedSignaturesForAddress2(account: String, configs: SolanaSDK.RequestConfiguration?) -> Single<[SolanaSDK.SignatureInfo]>
    func serializeAndSend(
        instructions: [SolanaSDK.TransactionInstruction],
        recentBlockhash: String?,
        signers: [SolanaSDK.Account],
        isSimulation: Bool
    ) -> Single<String>
}

extension RenVM {
    public struct SolanaChain: RenVMChainType {
        // MARK: - Constants
        static let gatewayRegistryStateKey  = "GatewayRegistryState"
        let gatewayStateKey                 = "GatewayStateV0.1.4"
        public let chainName: String        = "Solana"
        
        // MARK: - Properties
        let gatewayRegistryData: GatewayRegistryData
        let client: RenVMRpcClientType
        let solanaClient: RenVMSolanaAPIClientType
        
        // MARK: - Methods
        public static func load(
            client: RenVMRpcClientType,
            solanaClient: RenVMSolanaAPIClientType
        ) -> Single<Self> {
            do {
                let pubkey = try SolanaSDK.PublicKey(string: client.network.gatewayRegistry)
                let stateKey = try SolanaSDK.PublicKey.findProgramAddress(
                    seeds: [Self.gatewayRegistryStateKey.data(using: .utf8)!],
                    programId: pubkey
                )
                return solanaClient.getAccountInfo(
                    account: stateKey.0.base58EncodedString,
                    decodedTo: GatewayRegistryData.self
                )
                .map {$0.data}
                .map {.init(gatewayRegistryData: $0, client: client, solanaClient: solanaClient)}
            } catch {
                return .error(error)
            }
        }
        
        func resolveTokenGatewayContract(mintTokenSymbol: String) throws -> SolanaSDK.PublicKey {
            guard let sHash = try? SolanaSDK.PublicKey(
                    string: Base58.encode(
                        Hash.generateSHash(
                            selector: selector(mintTokenSymbol: mintTokenSymbol, direction: .to)
                        ).bytes
                    )
                ),
                let index = gatewayRegistryData.selectors.firstIndex(of: sHash),
                gatewayRegistryData.gateways.count > index
            else {throw Error("Could not resolve token gateway contract")}
            return gatewayRegistryData.gateways[index]
        }
        
        func getSPLTokenPubkey(mintTokenSymbol: String) throws -> SolanaSDK.PublicKey {
            let program = try resolveTokenGatewayContract(mintTokenSymbol: mintTokenSymbol)
            let sHash = Hash.generateSHash(
                selector: selector(mintTokenSymbol: mintTokenSymbol, direction: .to)
            )
            return try .findProgramAddress(seeds: [sHash], programId: program).0
        }
        
        public func getAssociatedTokenAddress(
            address: Data,
            mintTokenSymbol: String
        ) throws -> Data {
            let tokenMint = try getSPLTokenPubkey(mintTokenSymbol: mintTokenSymbol)
            return try SolanaSDK.PublicKey.associatedTokenAddress(
                walletAddress: try SolanaSDK.PublicKey(data: address),
                tokenMintAddress: tokenMint
            ).data
        }
        
        public func dataToAddress(data: Data) throws -> String {
            Base58.encode(data.bytes)
        }
        
        public func signatureToData(signature: String) throws -> Data {
            Data(Base58.decode(signature))
        }
        
        public func createAssociatedTokenAccount(
            address: SolanaSDK.PublicKey,
            mintTokenSymbol: String,
            signer: SolanaSDK.Account
        ) -> Single<String> {
            do {
                let tokenMint = try getSPLTokenPubkey(mintTokenSymbol: mintTokenSymbol)
                let associatedTokenAddress = try getAssociatedTokenAddress(address: address.data, mintTokenSymbol: mintTokenSymbol)
                let createAccountInstruction = SolanaSDK.AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                    mint: tokenMint,
                    associatedAccount: try SolanaSDK.PublicKey(data: associatedTokenAddress),
                    owner: address,
                    payer: signer.publicKey
                )
                return solanaClient.serializeAndSend(
                    instructions: [createAccountInstruction],
                    recentBlockhash: nil,
                    signers: [signer],
                    isSimulation: false
                )
            } catch {
                return .error(error)
            }
        }
        
        public func submitMint(
            address: Data,
            mintTokenSymbol: String,
            signer secretKey: Data,
            responceQueryMint: RenVM.ResponseQueryTxMint
        ) -> Single<String> {
            guard let pHash = responceQueryMint.valueIn.phash.decodeBase64URL(),
                  let nHash = responceQueryMint.valueIn.nhash.decodeBase64URL(),
                  let amount = responceQueryMint.valueOut.amount
            else {
                return .error(Error.paramsMissing)
            }
            
            let sHash = Hash.generateSHash(
                selector: selector(mintTokenSymbol: mintTokenSymbol, direction: .to)
            )
            
            let sig: Data
            let program: SolanaSDK.PublicKey
            let gatewayAccountId: SolanaSDK.PublicKey
            let tokenMint: SolanaSDK.PublicKey
            let mintAuthority: SolanaSDK.PublicKey
            let recipientTokenAccount: SolanaSDK.PublicKey
            let renVMMessage: Data
            let mintLogAccount: SolanaSDK.PublicKey
            let signer: SolanaSDK.Account
            
            do {
                guard let fixedSig = try responceQueryMint.valueOut.sig?.decodeBase64URL()?.fixSignatureSimple()
                else {return .error(Error.paramsMissing)}
                sig = fixedSig
                program = try resolveTokenGatewayContract(mintTokenSymbol: mintTokenSymbol)
                gatewayAccountId = try .findProgramAddress(
                    seeds: [Data(gatewayStateKey.bytes)],
                    programId: program
                ).0
                tokenMint = try getSPLTokenPubkey(mintTokenSymbol: mintTokenSymbol)
                mintAuthority = try .findProgramAddress(
                    seeds: [tokenMint.data],
                    programId: program
                ).0
                recipientTokenAccount = try SolanaSDK.PublicKey(data: try getAssociatedTokenAddress(address: address, mintTokenSymbol: mintTokenSymbol))
                renVMMessage = try Self.buildRenVMMessage(
                    pHash: pHash,
                    amount: amount,
                    token: sHash,
                    to: recipientTokenAccount,
                    nHash: nHash
                )
                mintLogAccount = try .findProgramAddress(seeds: [renVMMessage.keccak256], programId: program).0
                signer = try SolanaSDK.Account(secretKey: secretKey)
            } catch {
                return .error(error)
            }
            
            let mintInstruction = RenProgram.mintInstruction(
                account: signer.publicKey,
                gatewayAccount: gatewayAccountId,
                tokenMint: tokenMint,
                recipientTokenAccount: recipientTokenAccount,
                mintLogAccount: mintLogAccount,
                mintAuthority: mintAuthority,
                programId: program
            )
            
            let requestGatewayInfo = solanaClient.getAccountInfo(
                account: gatewayAccountId.base58EncodedString,
                decodedTo: GatewayStateData.self
            ).map {$0.data}
            
            return requestGatewayInfo
                .flatMap {gatewayState in
                    let secpInstruction = RenProgram.createInstructionWithEthAddress2(
                        ethAddress: Data(gatewayState.renVMAuthority.bytes),
                        message: renVMMessage,
                        signature: sig[0..<64],
                        recoveryId: sig[64] - 27
                    )
                    return self.solanaClient.serializeAndSend(
                        instructions: [
                            mintInstruction,
                            secpInstruction
                        ],
                        recentBlockhash: nil,
                        signers: [signer],
                        isSimulation: false
                    )
                }
        }
        
        public func submitBurn(
            mintTokenSymbol: String,
            account: Data,
            amount amountString: String,
            recipient: String,
            signer: Data
        ) -> Single<BurnDetails> {
            guard let amount = UInt64(amountString) else {
                return .error(Error("Amount is not valid"))
            }
            do {
                let signer = try SolanaSDK.Account(secretKey: signer)
                let account = try SolanaSDK.PublicKey(data: account)
                let program = try resolveTokenGatewayContract(mintTokenSymbol: mintTokenSymbol)
                let tokenMint = try getSPLTokenPubkey(mintTokenSymbol: mintTokenSymbol)
                let source = try SolanaSDK.PublicKey(data: try getAssociatedTokenAddress(address: account.data, mintTokenSymbol: mintTokenSymbol))
                let gatewayAccountId = try SolanaSDK.PublicKey.findProgramAddress(seeds: [Data(gatewayStateKey.bytes)], programId: program).0
                
                return solanaClient.getAccountInfo(
                    account: gatewayAccountId.base58EncodedString,
                    decodedTo: GatewayStateData.self
                )
                    .map {$0.data}
                    .flatMap {gatewayState -> Single<BurnDetails> in
                        let nonce = gatewayState.burnCount + 1
                        let burnLogAccountId = try SolanaSDK.PublicKey.findProgramAddress(
                            seeds: [Data(nonce.bytes)],
                            programId: program
                        ).0
                        
                        let burnCheckedInstruction = SolanaSDK.TokenProgram.burnCheckedInstruction(
                            tokenProgramId: .tokenProgramId,
                            mint: tokenMint,
                            account: source,
                            owner: account,
                            amount: amount,
                            decimals: 8
                        )
                        
                        let burnInstruction = RenProgram.burnInstruction(
                            account: account,
                            source: source,
                            gatewayAccount: gatewayAccountId,
                            tokenMint: tokenMint,
                            burnLogAccountId: burnLogAccountId,
                            recipient: Data(recipient.bytes),
                            programId: program
                        )
                        
                        return self.solanaClient.serializeAndSend(
                            instructions: [
                                burnCheckedInstruction,
                                burnInstruction
                            ],
                            recentBlockhash: nil,
                            signers: [signer],
                            isSimulation: false
                        )
                        .map {signature in
                            .init(confirmedSignature: signature, nonce: nonce, recipient: recipient, amount: amountString)
                        }
                    }
                
            } catch {
                return .error(error)
            }
        }
        
        public func findMintByDepositDetail(
            nHash: Data,
            pHash: Data,
            to: SolanaSDK.PublicKey,
            mintTokenSymbol: String,
            amount: String
        ) throws -> Single<String> {
            let program = try resolveTokenGatewayContract(mintTokenSymbol: mintTokenSymbol)
            let sHash = Hash.generateSHash(
                selector: selector(mintTokenSymbol: mintTokenSymbol, direction: .to)
            )
            let renVMMessage = try Self.buildRenVMMessage(pHash: pHash, amount: amount, token: sHash, to: to, nHash: nHash)
            
            let mintLogAccount = try SolanaSDK.PublicKey.findProgramAddress(seeds: [renVMMessage.keccak256], programId: program).0
            return solanaClient.getMintData(mintAddress: mintLogAccount.base58EncodedString, programId: program.base58EncodedString)
                .flatMap {mint -> Single<String> in
                    if !mint.isInitialized {return .just("")}
                    return solanaClient.getConfirmedSignaturesForAddress2(
                        account: mintLogAccount.base58EncodedString,
                        configs: nil
                    )
                        .map {$0.first?.signature ?? ""}
                }
        }
        
        // MARK: - Static methods
        public static func buildRenVMMessage(
            pHash: Data,
            amount: String,
            token: Data,
            to: SolanaSDK.PublicKey,
            nHash: Data
        ) throws -> Data {
            // serialize amount
            let amount = BInt(amount)
            let amountBytes = amount.data.bytes
            guard amountBytes.count <= 32 else {
                throw Error("The amount is not valid")
            }
            var amountData = Data(repeating: 0, count: 32 - amountBytes.count)
            amountData += amountBytes
            
            // form data
            var data = Data()
            data += pHash
            data += amountData
            data += token
            data += to.data
            data += nHash
            return data
        }
    }
}

extension RenVM.SolanaChain {
    struct GatewayStateData: DecodableBufferLayout {
        let isInitialized: Bool
        let renVMAuthority: RenVM.SolanaChain.GatewayStateData.RenVMAuthority
        let selectors: RenVM.SolanaChain.GatewayStateData.Selectors
        let burnCount: UInt64
        let underlyingDecimals: UInt8
        
        
        struct RenVMAuthority: BufferLayoutProperty {
            let bytes: [UInt8]
            
            init(buffer: Data, pointer: inout Int) throws {
                guard buffer.bytes.count > pointer else {throw BufferLayoutSwift.Error.bytesLengthIsNotValid}
                bytes = Array(buffer[pointer..<pointer+20])
                pointer += 20
            }
            
            func serialize() throws -> Data {
                Data(bytes)
            }
        }
        
        struct Selectors: BufferLayoutProperty {
            let bytes: [UInt8]
            
            init(buffer: Data, pointer: inout Int) throws {
                guard buffer.bytes.count > pointer else {throw BufferLayoutSwift.Error.bytesLengthIsNotValid}
                bytes = Array(buffer[pointer..<pointer+32])
                pointer += 32
            }
            
            func serialize() throws -> Data {
                Data(bytes)
            }
        }
    }
    
    struct GatewayRegistryData: DecodableBufferLayout {
        let isInitialized: Bool
        let owner: SolanaSDK.PublicKey
        let count: UInt64
        let selectors: [SolanaSDK.PublicKey]
        let gateways: [SolanaSDK.PublicKey]
        
        public init(buffer: Data, pointer: inout Int) throws {
            self.isInitialized = try Bool(buffer: buffer, pointer: &pointer)
            self.owner = try .init(buffer: buffer, pointer: &pointer)
            self.count = try UInt64(buffer: buffer, pointer: &pointer)
            
            // selectors
            let selectorsSize = try UInt32(buffer: buffer, pointer: &pointer)
            var selectors = [SolanaSDK.PublicKey]()
            for _ in 0..<selectorsSize {
                selectors.append(try .init(buffer: buffer, pointer: &pointer))
            }
            self.selectors = selectors
            
            // gateways:
            let gatewaysSize = try UInt32(buffer: buffer, pointer: &pointer)
            var gateways = [SolanaSDK.PublicKey]()
            for _ in 0..<gatewaysSize {
                gateways.append(try .init(buffer: buffer, pointer: &pointer))
            }
            self.gateways = gateways
        }
        
        public func serialize() throws -> Data {
            var data = Data()
            data += try isInitialized.serialize()
            data += try owner.serialize()
            data += try count.serialize()
            data += try (UInt32(selectors.count)).serialize()
            data += try selectors.reduce(Data(), {$0 + (try $1.serialize())})
            data += try (UInt32(gateways.count)).serialize()
            data += try gateways.reduce(Data(), {$0 + (try $1.serialize())})
            return data
        }
    }
}
