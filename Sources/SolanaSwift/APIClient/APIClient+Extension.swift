import Foundation

// MARK: - TokenRepository

public extension SolanaAPIClient {
    // MARK: - Convenience methods
    func getMinimumBalanceForRentExemption(span: UInt64) async throws -> UInt64 {
        try await self.getMinimumBalanceForRentExemption(dataLength: span, commitment: "recent")
    }
    
    func getRecentBlockhash() async throws -> String {
        try await self.getRecentBlockhash(commitment: nil)
    }
    
    func observeSignatureStatus(signature: String) -> AsyncStream<TransactionStatus> {
        self.observeSignatureStatus(signature: signature, timeout: 60, delay: 2)
    }
    
    // MARK: - Additional methods
    func getMultipleMintDatas(mintAddresses: [String], programId: String = TokenProgram.id.base58EncodedString) async throws -> [String: Mint] {
        let accounts: [BufferInfo<Mint>] = try await getMultipleAccounts(pubkeys: mintAddresses)
        var mintDict = [String: Mint]()
        if accounts.contains(where: { $0.owner != programId }) == true {
            throw SolanaError.other("Invalid mint owner")
        }
        let result = accounts.map({ $0.data })
        guard result.count == mintAddresses.count else {
            throw SolanaError.other("Some of mint data are missing")
        }

        for (index, address) in mintAddresses.enumerated() {
            mintDict[address] = result[index]
        }
        return mintDict
    }
    
    func checkIfAssociatedTokenAccountExists(
        owner: PublicKey,
        mint: String
    ) async throws -> Bool {
        
        let mintAddress = try mint.toPublicKey()
        
        let associatedTokenAccount = try PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: mintAddress
        )
        
        do {
            let bufferInfo: BufferInfo<AccountInfo>? = try await getAccountInfo(account: associatedTokenAccount.base58EncodedString)
            return bufferInfo?.data.mint == mintAddress
        } catch {
            if error.isEqualTo(.couldNotRetrieveAccountInfo) {
                return false
            }
            throw error
        }
    }
    
    func checkAccountValidation(account: String) async throws -> Bool {
        do {
            let _ : BufferInfo<EmptyInfo>? = try await getAccountInfo(account: account)
            return true
        } catch {
            if error.isEqualTo(SolanaError.couldNotRetrieveAccountInfo) {
                return false
            }
            throw error
        }
    }
    
    func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String
    ) async throws -> SPLTokenDestinationAddress {
        var address: String
        var accountInfo: BufferInfo<AccountInfo>?
        do {
            accountInfo = try await getAccountInfo(account: destinationAddress)
            let toTokenMint = accountInfo?.data.mint.base58EncodedString
            // detect if destination address is already a SPLToken address
            if mintAddress == toTokenMint {
                address = destinationAddress
            // detect if destination address is a SOL address
            } else if accountInfo?.owner == SystemProgram.id.base58EncodedString {
               let owner = try PublicKey(string: destinationAddress)
               let tokenMint = try PublicKey(string: mintAddress)
                // create associated token address
                address = try PublicKey.associatedTokenAddress(
                   walletAddress: owner,
                   tokenMintAddress: tokenMint
                ).base58EncodedString
            } else {
                throw SolanaError.invalidRequest(reason: "Wallet address is not valid")
            }
        } catch let error as SolanaError where error == .couldNotRetrieveAccountInfo {
            let owner = try PublicKey(string: destinationAddress)
            let tokenMint = try PublicKey(string: mintAddress)
            // create associated token address
            address = try PublicKey.associatedTokenAddress(
               walletAddress: owner,
               tokenMintAddress: tokenMint
            ).base58EncodedString
        } catch let error {
            throw error
        }
        
        //address needs here
        let toPublicKey = try PublicKey(string: address)
        // if destination address is an SOL account address
        var isUnregisteredAsocciatedToken = false
        if destinationAddress != toPublicKey.base58EncodedString {
            // check if associated address is already registered
            let info: BufferInfo<AccountInfo>?
            do {
                info = try await getAccountInfo(account: toPublicKey.base58EncodedString)
            } catch {
                info = nil
            }
            isUnregisteredAsocciatedToken = true

            // if associated token account has been registered
            if info?.owner == TokenProgram.id.base58EncodedString && info?.data != nil {
                isUnregisteredAsocciatedToken = false
            }
        }
        return (destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken)
    }
}
