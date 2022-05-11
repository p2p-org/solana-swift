import Foundation

// MARK: - TokenRepository

public extension SolanaAPIClient {
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
}
