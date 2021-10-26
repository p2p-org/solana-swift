//
//  SolanaSDK+Methods.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/27/20.
//
// NOTE: THIS FILE IS GENERATED FROM APIGEN PACKAGE, DO NOT MAKE CHANGES DIRECTLY INTO IT, PLEASE EDIT METHODS.JSON AND methodsGen.js TO MAKE CHANGES (IN ../APIGen FOLDER)

import Foundation
import RxSwift

public extension SolanaSDK {
    func getAccountInfo<T: DecodableBufferLayout>(account: String, decodedTo: T.Type) -> Single<BufferInfo<T>> {
        let configs = RequestConfiguration(encoding: "base64")
        return (request(parameters: [account, configs]) as Single<Rpc<BufferInfo<T>?>>)
            .map {
                guard let value = $0.value else {
                    throw Error.other("Could not retrieve account info")
                }
                return value
            }
    }
    func getBalance(account: String? = nil, commitment: Commitment? = nil) -> Single<UInt64> {
        guard let account = account ?? accountStorage.account?.publicKey.base58EncodedString
        else {return .error(Error.unauthorized)}
        
        return (request(parameters: [account, RequestConfiguration(commitment: commitment)]) as Single<Rpc<UInt64>>)
            .map {$0.value}
    }
    func getBlockCommitment(block: String) -> Single<BlockCommitment> {
        request(parameters: [block])
    }
    func getBlockTime(block: UInt64) -> Single<Date?> {
        (request(parameters: [block]) as Single<Int64?>)
            .map {timestamp in
                guard let timestamp = timestamp else {return nil}
                return Date(timeIntervalSince1970: TimeInterval(timestamp))
            }
    }
    func getClusterNodes() -> Single<ClusterNodes> {
        request()
    }
    func getConfirmedBlock(slot: UInt64, encoding: String = "json") -> Single<ConfirmedBlock?> {
        request(parameters: [slot, encoding])
    }
    func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64) -> Single<[UInt64]> {
        request(parameters: [startSlot, endSlot])
    }
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) -> Single<[UInt64]> {
        request(parameters: [startSlot, limit])
    }
    func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) -> Single<[String]> {
        request(parameters: [account, startSlot, endSlot])
    }
    @available(*, deprecated, renamed: "getSignaturesForAddress(address:configs:)", message: "use getSignaturesForAddress instead.This method is expected to be removed in solana-core v1.8.")
    func getConfirmedSignaturesForAddress2(account: String, configs: RequestConfiguration? = nil) -> Single<[SignatureInfo]> {
        request(
            overridingEndpoint: "https://api.mainnet-beta.solana.com",
            parameters: [account, configs]
        )
    }
    func getSignaturesForAddress(address: String, configs: RequestConfiguration? = nil) -> Single<[SignatureInfo]> {
        request(
            overridingEndpoint: "https://api.mainnet-beta.solana.com",
            parameters: [address, configs],
            onMethodNotFoundReplaceWith: "getConfirmedSignaturesForAddress2"
        )
    }
    @available(*, deprecated, renamed: "getTransaction(transactionSignature:)", message: "use getTransaction instead This method is expected to be removed in solana-core v1.8.")
    func getConfirmedTransaction(transactionSignature: String) -> Single<TransactionInfo> {
        request(
            overridingEndpoint: "https://api.mainnet-beta.solana.com",
            parameters: [transactionSignature, "jsonParsed"]
        )
    }
    func getTransaction(transactionSignature: String) -> Single<TransactionInfo> {
        request(
            overridingEndpoint: "https://api.mainnet-beta.solana.com",
            parameters: [transactionSignature, "jsonParsed"],
            onMethodNotFoundReplaceWith: "getConfirmedTransaction"
        )
    }
    func getEpochInfo(commitment: Commitment? = nil) -> Single<EpochInfo> {
        request(parameters: [RequestConfiguration(commitment: commitment)])
    }
    func getEpochSchedule() -> Single<EpochSchedule> {
        request()
    }
    func getFeeCalculatorForBlockhash(blockhash: String, commitment: Commitment? = nil) -> Single<Fee> {
        (request(parameters: [blockhash, RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
            .map {$0.value}
    }
    func getFeeRateGovernor() -> Single<Fee> {
        (request() as Single<Rpc<Fee>>)
            .map {$0.value}
    }
    func getFees(commitment: Commitment? = nil) -> Single<Fee> {
        (request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
            .map {$0.value}
    }
    func getFirstAvailableBlock() -> Single<UInt64> {
        request()
    }
    func getGenesisHash() -> Single<String> {
        request()
    }
    func getIdentity() -> Single<String> {
        request()
    }
    func getInflationGovernor(commitment: Commitment? = nil) -> Single<InflationGovernor> {
        request(parameters: [RequestConfiguration(commitment: commitment)])
    }
    func getInflationRate() -> Single<InflationRate> {
        request()
    }
    func getLargestAccounts() -> Single<[LargestAccount]> {
        (request() as Single<Rpc<[LargestAccount]>>)
            .map {$0.value}
    }
    func getLeaderSchedule(epoch: UInt64? = nil, commitment: Commitment? = nil) -> Single<[String: [Int]]?> {
        request(parameters: [epoch, RequestConfiguration(commitment: commitment)])
    }
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent") -> Single<UInt64> {
        request(parameters: [dataLength, RequestConfiguration(commitment: commitment)])
    }
    func getMultipleAccounts<T: DecodableBufferLayout>(pubkeys: [String], decodedTo: T.Type, log: Bool = true) -> Single<[BufferInfo<T>]?> {
        let configs = RequestConfiguration(encoding: "base64")
        guard !pubkeys.isEmpty else {return .just([])}
        return (request(parameters: [pubkeys, configs], log: log) as Single<Rpc<[BufferInfo<T>]?>>)
            .map {$0.value}
    }
    func getProgramAccounts<T: DecodableBufferLayout>(publicKey: String, configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"), decodedTo: T.Type, log: Bool = true) -> Single<ProgramAccounts<T>>
    {
        request(parameters: [publicKey, configs], log: log)
    }
    func getRecentBlockhash(commitment: Commitment? = nil) -> Single<String> {
        (request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
            .map {$0.value}
            .map {$0.blockhash}
            .map { recentBlockhash in
                if recentBlockhash == nil {
                    throw Error.other("Blockhash not found")
                }
                return recentBlockhash!
            }
    }
    func getRecentPerformanceSamples(limit: UInt64) -> Single<[PerformanceSample]> {
        request(parameters: [limit])
    }
    func getSignatureStatuses(signatures: [String], configs: RequestConfiguration? = nil) -> Single<[SignatureStatus?]> {
        (request(parameters: [signatures, configs]) as Single<Rpc<[SignatureStatus?]>>)
            .map {$0.value}
    }
    
    func getSignatureStatus(signature: String, configs: RequestConfiguration? = nil) -> Single<SignatureStatus> {
        getSignatureStatuses(signatures: [signature])
            .map { statuses in
                guard let status = statuses.compactMap({$0}).first else {throw Error.other("Invalid status")}
                return status
            }
    }
    func getSlot(commitment: Commitment? = nil) -> Single<UInt64> {
        request(parameters: [RequestConfiguration(commitment: commitment)])
    }
    func getSlotLeader(commitment: Commitment? = nil) -> Single<String> {
        request(parameters: [RequestConfiguration(commitment: commitment)])
    }
    func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil) -> Single<StakeActivation> {
        request(parameters: [stakeAccount, configs])
    }
    func getSupply(commitment: Commitment? = nil) -> Single<Supply> {
        (request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Supply>>)
            .map {$0.value}
    }
    func getTransactionCount(commitment: Commitment? = nil) -> Single<UInt64> {
        request(parameters: [RequestConfiguration(commitment: commitment)])
    }
    func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAccountBalance> {
        (request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<TokenAccountBalance>>)
            .map {
                if UInt64($0.value.amount) == nil {
                    throw Error.invalidResponse(ResponseError(code: nil, message: "Could not retrieve balance", data: nil))
                }
                return $0.value
            }
    }
    func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount<AccountInfo>]> {
        (request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount<AccountInfo>]>>)
            .map {$0.value}
    }
    func getTokenAccountsByOwner(pubkey: String, params: OwnerInfoParams? = nil, configs: RequestConfiguration? = nil, log: Bool = true) -> Single<[TokenAccount<AccountInfo>]> {
        (request(parameters: [pubkey, params, configs], log: log) as Single<Rpc<[TokenAccount<AccountInfo>]>>)
            .map {$0.value}
    }
    func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil) -> Single<[TokenAmount]> {
        (request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<[TokenAmount]>>)
            .map {$0.value}
    }
    func getTokenSupply(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAmount> {
        (request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<TokenAmount>>)
            .map {$0.value}
    }
    func getVersion() -> Single<Version> {
        request()
    }
    func getVoteAccounts(commitment: Commitment? = nil) -> Single<VoteAccounts> {
        request(parameters: [RequestConfiguration(commitment: commitment)])
    }
    func minimumLedgerSlot() -> Single<UInt64> {
        request()
    }
    func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) -> Single<String> {
        request(parameters: [account, lamports, RequestConfiguration(commitment: commitment)])
    }
    internal func sendTransaction(serializedTransaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<TransactionID> {
        request(parameters: [serializedTransaction, configs])
            .catch { error in
                // Modify error message
                if let error = error as? Error {
                    switch error {
                    case .invalidResponse(let response) where response.message != nil:
                        var message = response.message
                        if let readableMessage = response.data?.logs?
                            .first(where: {$0.contains("Error:")})?
                            .components(separatedBy: "Error: ")
                            .last
                        {
                            message = readableMessage
                        } else if let readableMessage = response.message?
                                    .components(separatedBy: "Transaction simulation failed: ")
                                    .last
                        {
                            message = readableMessage
                        }
                        
                        return .error(Error.invalidResponse(ResponseError(code: response.code, message: message, data: response.data)))
                    default:
                        break
                    }
                }
                return .error(error)
            }
    }
    
    func waitForConfirmation(signature: String) -> Completable {
        // Due to a bug (https://github.com/solana-labs/solana/issues/15461)
        // the `confirmationStatus` field could be unpopulated.
        // To handle this case, also check the `confirmations` field.
        // Note that a `null` value for `confirmations` signals that the
        // transaction was finalized.
        getSignatureStatus(signature: signature)
            .map { status -> Bool in
                (status.confirmations ?? 0) > 0 ||
                    status.confirmations == nil ||
                    status.confirmationStatus == "confirmed"
            }
            .flatMapCompletable { confirmed in
                if confirmed {return .empty()}
                throw Error.other("Status has not been confirmed")
            }
            .retry(maxAttempts: .max, delay: .seconds(1))
            .timeout(.seconds(60), scheduler: MainScheduler.instance)
    }
    
    func simulateTransaction(transaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<TransactionStatus> {
        (request(parameters: [transaction, configs]) as Single<Rpc<TransactionStatus>>)
            .map {$0.value}
            .map {status in
                if let err = status.err {
                    throw Error.transactionError(err, logs: status.logs)
                }
                return status
            }
    }
    func setLogFilter(filter: String) -> Single<String?> {
        request(parameters: [filter])
    }
    func validatorExit() -> Single<Bool> {
        request()
    }
    
    // MARK: - Additional methods
    func getMintData(
        mintAddress: String,
        programId: String = PublicKey.tokenProgramId.base58EncodedString
    ) -> Single<Mint> {
        getAccountInfo(account: mintAddress, decodedTo: Mint.self)
            .map {
                if $0.owner != programId {
                    throw Error.other("Invalid mint owner")
                }
                return $0.data
            }
    }
    
    func getMultipleMintDatas(
        mintAddresses: [String],
        programId: String = PublicKey.tokenProgramId.base58EncodedString,
        log: Bool = true
    ) -> Single<[String: Mint]> {
        getMultipleAccounts(pubkeys: mintAddresses, decodedTo: Mint.self, log: log)
            .map {
                if $0?.contains(where: {$0.owner != programId}) == true
                {
                    throw Error.other("Invalid mint owner")
                }
                
                guard let result = $0?.map({$0.data}), result.count == mintAddresses.count else {
                    throw Error.other("Some of mint data are missing")
                }
                
                var mintDict = [String: Mint]()
                for (index, address) in mintAddresses.enumerated() {
                    mintDict[address] = result[index]
                }
                
                return mintDict
            }
    }
}

private extension PrimitiveSequence{
    func retry(maxAttempts: Int, delay: RxTimeInterval) -> PrimitiveSequence<Trait, Element> {
        return self.retry { errors in
            return errors.enumerated().flatMap{ (index, error) -> Observable<Int64> in
                if index < maxAttempts {
                    return Observable<Int64>.timer(delay, scheduler: MainScheduler.instance)
                } else {
                    return Observable.error(error)
                }
            }
        }
    }
}

