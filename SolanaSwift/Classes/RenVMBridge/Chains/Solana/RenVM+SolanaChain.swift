//
//  RenVM+SolanaChain.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import RxSwift

extension RenVM {
    public struct SolanaChain: RenVMChainType {
        // MARK: - Constants
        static let gatewayRegistryStateKey  = "GatewayRegistryState"
        let gatewayStateKey                 = "GatewayStateV0.1.4"
        
        // MARK: - Properties
        let gatewayRegistryData: GatewayRegistryData
        let client: RenVMRpcClientType
        let solanaClient: RenVMSolanaAPIClientType
        
        // MARK: - Methods
        public static func load(
            client: RenVMRpcClientType,
            solanaClient: RenVMSolanaAPIClientType,
            network: Network
        ) -> Single<Self> {
            do {
                let pubkey = try SolanaSDK.PublicKey(string: network.gatewayRegistry)
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
        
        func resolveTokenGatewayContract() throws -> SolanaSDK.PublicKey {
            guard let sHash = try? SolanaSDK.PublicKey(string: Base58.encode(Hash.generateSHash().bytes)),
                let index = gatewayRegistryData.selectors.firstIndex(of: sHash),
                gatewayRegistryData.gateways.count > index
            else {throw Error("Could not resolve token gateway contract")}
            return gatewayRegistryData.gateways[index]
        }
        
        func getSPLTokenPubkey() throws -> SolanaSDK.PublicKey {
            let program = try resolveTokenGatewayContract()
            let sHash = Hash.generateSHash()
            return try .findProgramAddress(seeds: [sHash], programId: program).0
        }
        
        public func getAssociatedTokenAddress(
            address: Data
        ) throws -> Data {
            let tokenMint = try getSPLTokenPubkey()
            return try SolanaSDK.PublicKey.associatedTokenAddress(
                walletAddress: try SolanaSDK.PublicKey(data: address),
                tokenMintAddress: tokenMint
            ).data
        }
        
        public func dataToAddress(data: Data) throws -> String {
            Base58.encode(data.bytes)
        }
        
//        public String createAssociatedTokenAccount(PublicKey address, Account signer) throws Exception {
//            PublicKey tokenMint = getSPLTokenPubkey();
//            PublicKey associatedTokenAddress = getAssociatedTokenAddress(address);
//
//            TransactionInstruction createAccountInstruction = TokenProgram.createAssociatedTokenAccountInstruction(
//                    TokenProgram.ASSOCIATED_TOKEN_PROGRAM_ID, TokenProgram.PROGRAM_ID, tokenMint, associatedTokenAddress,
//                    address, signer.getPublicKey());
//
//            Transaction transaction = new Transaction();
//            transaction.addInstruction(createAccountInstruction);
//
//            return client.getApi().sendTransaction(transaction, signer);
//        }
//
        public func submitMint(
            address: Data,
            signer: Data,
            responceQueryMint: RenVM.ResponseQueryTxMint
        ) -> Single<String> {
            fatalError()
            guard let pHash = responceQueryMint.valueIn.phash.decodeBase64URL(),
                  let nHash = responceQueryMint.valueIn.nhash.decodeBase64URL()
            else {
                return .error(Error.paramsMissing)
            }
            
            let amount = responceQueryMint.valueOut.amount
            let sHash = Hash.generateSHash()
            
            let sig: Data
            let program: SolanaSDK.PublicKey
            let gatewayAccountId: SolanaSDK.PublicKey
            let tokenMint: SolanaSDK.PublicKey
            let mintAuthority: SolanaSDK.PublicKey
            let recipientTokenAccount: Data
            let renVMMessage: Data
            let mintLogAccount: SolanaSDK.PublicKey
            
            do {
                guard let sig = try responceQueryMint.valueOut.sig.decodeBase64URL()?.fixSignatureSimple()
                else {return .error(Error.paramsMissing)}
                program = try resolveTokenGatewayContract()
                gatewayAccountId = try .findProgramAddress(
                    seeds: [Data(gatewayStateKey.bytes)],
                    programId: program
                ).0
                tokenMint = try getSPLTokenPubkey()
                mintAuthority = try .findProgramAddress(
                    seeds: [tokenMint.data],
                    programId: program
                ).0
                recipientTokenAccount = try getAssociatedTokenAddress(address: address)
                renVMMessage = try Self.buildRenVMMessage(
                    pHash: pHash,
                    amount: amount,
                    token: sHash,
                    to: try SolanaSDK.PublicKey(data: recipientTokenAccount),
                    nHash: nHash
                )
                mintLogAccount = try .findProgramAddress(seeds: [renVMMessage.keccak256], programId: program).0
                
            } catch {
                return .error(error)
            }
            
            
        
            
        }
//        public String submitMint(PublicKey address, Account signer, ResponseQueryTxMint responceQueryMint)
//                throws Exception {
//            byte[] pHash = Utils.fromURLBase64(responceQueryMint.getValueIn().phash);
//            String amount = responceQueryMint.getValueOut().amount;
//            byte[] nHash = Utils.fromURLBase64(responceQueryMint.getValueIn().nhash);
//            byte[] sig = Utils.fixSignatureSimple(responceQueryMint.getValueOut().sig);
//
//            PublicKey program = resolveTokenGatewayContract();
//            PublicKey gatewayAccountId = PublicKey.findProgramAddress(Arrays.asList(GatewayStateKey.getBytes()), program)
//                    .getAddress();
//            byte[] sHash = Hash.generateSHash();
//            PublicKey tokenMint = getSPLTokenPubkey();
//            PublicKey mintAuthority = PublicKey.findProgramAddress(Arrays.asList(tokenMint.toByteArray()), program)
//                    .getAddress();
//            PublicKey recipientTokenAccount = getAssociatedTokenAddress(address);
//
//            byte[] renVMMessage = buildRenVMMessage(pHash, amount, sHash, recipientTokenAccount.toByteArray(), nHash);
//            PublicKey mintLogAccount = PublicKey.findProgramAddress(Arrays.asList(Hash.keccak256(renVMMessage)), program)
//                    .getAddress();
//
//            TransactionInstruction mintInstruction = RenProgram.mintInstruction(signer.getPublicKey(), gatewayAccountId,
//                    tokenMint, recipientTokenAccount, mintLogAccount, mintAuthority, program);
//
//            AccountInfo gatewayInfo = client.getApi().getAccountInfo(gatewayAccountId);
//            String base64Data = gatewayInfo.getValue().getData().get(0);
//            GatewayStateData gatewayState = GatewayStateData.decode(Base64.getDecoder().decode(base64Data));
//
//            TransactionInstruction secpInstruction = RenProgram.createInstructionWithEthAddress2(
//                    gatewayState.renVMAuthority, renVMMessage, Arrays.copyOfRange(sig, 0, 64), sig[64] - 27);
//
//            Transaction transaction = new Transaction();
//            transaction.addInstruction(mintInstruction);
//            transaction.addInstruction(secpInstruction);
//
//            String confirmedSignature = client.getApi().sendTransaction(transaction, signer);
//
//            return confirmedSignature;
//        }
        
        public func findMintByDepositDetail(
            nHash: Data,
            pHash: Data,
            to: SolanaSDK.PublicKey,
            amount: String
        ) throws -> Single<String> {
            let program = try resolveTokenGatewayContract()
            let sHash = Hash.generateSHash()
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
    public struct GatewayRegistryData: DecodableBufferLayout {
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
