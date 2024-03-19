## 5.0.0

- Fix TokenMetadata encoding, tags.
- Remove deprecated PublicKey.tokenProgramId, use TokenProgram.id instead.
- Remove deprecated PublicKey.programId, use SystemProgram.id instead.
- Remove deprecated PublicKey.ownerValidationProgramId, use OwnerValidationProgram.id instead.
- Remove deprecated PublicKey.splAssociatedTokenAccountProgramId, use AssociatedTokenProgram.id instead.
- Remove deprecated typealias AccountInfo, use TokenAccountState or Token2022AccountState instead.
- Remove deprecated typealias Mint, use TokenMintState or Token2022MintState instead.
- Remove deprecated typealias Wallet, use AccountBalance instead.
- Support token 2022 via method getAccountBalances (See GetAccountBalancesTests).
- Support token 2022 and Token2022Program.

## 4.0.0

- Rename Wallet to AccountBalance.
- Remove comment headers
- Do swiftformat entire codebase
- Change target to iOS 15, tvOS 11, watchOS 4
- Rename TransactionStatus to PendingTransactionStatus
- Rename Mint to SPLTokenMintState
- Rename AccountInfo to SPLTokenAccountState
- Remove SolanaError and split it into separated error types like PublicKeyError, TransactionConfirmationError, BlockchainClientError, BinaryReaderError, BorshCodableError, KeyPairError, VersionedMessageError, VersionedTransactionError.
- Remove DeserializationError and migrate them to BorshCodableError.
- Add transactionSimulationError, couldNotRetrieveAccountInfo & blockhashNotFound cases into APIClientError.
- Rename Mnemomic.Error into MnemonicError.
- Rename Ed25519HDKey.Error to Ed25519HDKeyError.
- Remove getTokenWallets method (should be done in client)
- Remove some methods in Error+Extensions.
- Rename Token to TokenMetadata.
- Rename Token.address to Token.mintAddress.
...

## 3.0.0

- Change iconUrl of some tokens
- Fix decoding for ConfirmedTransaction
- Add support additional params for socket
- Conform PreparedTransaction to Equatable
- Rename Account to KeyPair and deprecated Account
- Public some structs
- Fix decimal for USDC from 8 to 6
- Add empty init for KeyPair
- Add test for SendTransaction
- Add support Commitment in getTokenWallets
- Add support for VersionedTransaction

## 2.5.3

- Add rpc method getRecentPerformanceSamples
- Change tokens repository endpoint

## 2.5.2

- Add convenience variables for common tokens (ETH, USDT)
- Make signing in method prepare transaction optional if signers is not provided

## 2.5.1

- Add supply property for struct Wallet

## 2.5.0

- Add usdc to TokenList
- Add slot info to TransactionStatus
- Add option skipPreflight to RequestModels

## 2.4.0

- Replacing LoggerSwift with abstraction

## 2.3.0

- Added support for socket encoding response

## 2.2.2

- Update coingeko id for SOL and renBTC

## 2.2.1

- Publish init SendingTransaction with Signature
- Fix batch loading with zero and one element

## 2.2.0

- Improve batch loading with same request type

## 2.1.3

- Fix message deserialization
- Add partial sign

## 2.1.0

- Fix `prepareForSendingNativeSOL`
- Enable testnet only on debug

## 2.0.1

- Update documentation
- Update `Task_retrying`

## 2.0.0

- Migrate to swift concurrency

## 1.0.0

- Release library
