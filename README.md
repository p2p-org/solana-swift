# SolanaSwift

Solana-blockchain client, written in pure swift.

[![Version](https://img.shields.io/cocoapods/v/SolanaSwift.svg?style=flat)](https://cocoapods.org/pods/SolanaSwift)
[![License](https://img.shields.io/cocoapods/l/SolanaSwift.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Platform](https://img.shields.io/cocoapods/p/SolanaSwift.svg?style=flat)](https://cocoapods.org/pods/SolanaSwift)
[![Documentation Status](https://readthedocs.org/projects/ansicolortags/badge/?version=latest)](https://p2p-org.github.io/solana-swift/documentation/solanaswift)

## Features
- [x] Supported swift concurrency (from 2.0.0)
- [x] Key pairs generation
- [x] Solana JSON RPC API
- [x] Create, sign transactions
- [x] Send, simulate transactions
- [x] Solana token list
- [x] Socket communication
- [x] OrcaSwapSwift
- [x] RenVMSwift

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Demo wallet: [p2p-wallet](https://github.com/p2p-org/p2p-wallet-ios)

## Requirements
- iOS 13 or later

## Dependencies
- TweetNacl
- secp256k1.swift

## Installation

### Cocoapods
SolanaSwift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SolanaSwift', '~> 4.0.0'
```

### Swift package manager
```swift
...
dependencies: [
    ...
    .package(url: "https://github.com/p2p-org/solana-swift", from: "4.0.0")
],
...
```

## How to use
### Version 2.0 update anouncement
* From v2.0.0 we officially omited Rx library and a lot of dependencies, thus we also adopt swift concurrency to `solana-swift`. [What have been changed?](https://github.com/p2p-org/solana-swift/issues/42)
* For those who still use `SolanaSDK` class, follow [this link](https://github.com/p2p-org/solana-swift/blob/deprecated/1.3.8/README.md)

### Import
```swift
import SolanaSwift
```

### Logger
Create a logger that confirm to SolanaSwiftLogger
```swift
import SolanaSwift

class MyCustomLogger: SolanaSwiftLogger {
    func log(event: String, data: String?, logLevel: SolanaSwiftLoggerLogLevel) {
        // Custom log goes here
    }
}

// AppDelegate or somewhere eles

let customLogger: SolanaSwiftLogger = MyCustomLogger()
SolanaSwift.Logger.setLoggers([customLogger])
```

### AccountStorage
Create an `SolanaAccountStorage` for saving account's `keyPairs` (public and private key), for example: `KeychainAccountStorage` for saving into `Keychain` in production, or `InMemoryAccountStorage` for temporarily saving into memory for testing. The "`CustomAccountStorage`" must conform to protocol `SolanaAccountStorage`, which has 2 requirements: function for saving `save(_ account:) throws` and computed property `account: Account? { get thrrows }` for retrieving user's account.

Example:
```swift
import SolanaSwift
import KeychainSwift
struct KeychainAccountStorage: SolanaAccountStorage {
    let tokenKey = <YOUR_KEY_TO_STORE_IN_KEYCHAIN>
    func save(_ account: Account) throws {
        let data = try JSONEncoder().encode(account)
        keychain.set(data, forKey: tokenKey)
    }
    
    var account: Account? {
        guard let data = keychain.getData(tokenKey) else {return nil}
        return try JSONDecoder().decode(Account.self, from: data)
    }
}

struct InMemoryAccountStorage: SolanaAccountStorage {
    private var _account: Account?
    func save(_ account: Account) throws {
        _account = account
    }
    
    var account: Account? {
        _account
    }
}
```

### Create an account (keypair)
```swift
let account = try await Account(network: .mainnetBeta)
// optional
accountStorage.save(account)
```

### Restore an account from a seed phrase (keypair)
```swift
let account = try await Account(phrases: ["miracle", "hundred", ...], network: .mainnetBeta, derivablePath: ...)
// optional
accountStorage.save(account)
```

### Solana RPC Client
APIClient for [Solana JSON RPC API](https://docs.solana.com/developing/clients/jsonrpc-api). See [Documentation](https://p2p-org.github.io/solana-swift/documentation/solanaswift/solanaapiclient)

Example: 
```swift
import SolanaSwift

let endpoint = APIEndPoint(
    address: "https://api.mainnet-beta.solana.com",
    network: .mainnetBeta
)

// To get block height
let apiClient = JSONRPCAPIClient(endpoint: endpoint)
let result = try await apiClient.getBlockHeight()

// To get balance of the current account
guard let account = try? accountStorage.account?.publicKey.base58EncodedString else { throw UnauthorizedError }
let balance = try await apiClient.getBalance(account: account, commitment: "recent")
```

Wait for confirmation method.

```swift
// Wait for confirmation
let signature = try await blockChainClient.sendTransaction(...)
try await apiClient.waitForConfirmation(signature: signature, ignoreStatus: true) // transaction will be mark as confirmed after timeout no matter what status is when ignoreStatus = true
let signature2 = try await blockchainClient.sendTransaction(/* another transaction that requires first transaction to be completed */)
```

Observe signature status. In stead of using socket to observe signature status, which is not really reliable (socket often returns signature status == `finalized` when it is not fully finalized), we observe its status by periodically sending `getSignatureStatuses` (with `observeSignatureStatus` method)
```swift
// Observe signature status with `observeSignatureStatus` method
var statuses = [TransactionStatus]()
for try await status in apiClient.observeSignatureStatus(signature: "jaiojsdfoijvaij", timeout: 60, delay: 3) {
    print(status)
    statuses.append(status)
}
// statuses.last == .sending // the signature is not confirmed
// statuses.last?.numberOfConfirmations == x // the signature is confirmed by x nodes (partially confirmed)
// statuses.last == .finalized // the signature is confirmed by all nodes
```

Batch support

```swift
// Batch request with different types
let req1: JSONRPCAPIClientRequest<AnyDecodable> = JSONRPCAPIClientRequest(method: "getAccountInfo", params: ["63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1"])
let req2: JSONRPCAPIClientRequest<AnyDecodable> = JSONRPCAPIClientRequest(method: "getBalance", params: ["63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1"])
let response = try await apiClient.batchRequest(with: [req1, req2])

// Batch request with same type
let balances: [Rpc<UInt64>?] = try await apiClient.batchRequest(method: "getBalance", params: [["63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1"], ["63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1"], ["63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1"]])
```

For the method that is not listed, use generic method `request(method:params:)` or `request(method:)` without params.

```swift
let result: String = try await apiClient.request(method: "getHealth")
XCTAssertEqual(result, "ok")
```

### Solana Blockchain Client
Prepare, send and simulate transactions. See [Documentation](https://p2p-org.github.io/solana-swift/documentation/solanaswift/solanablockchainclient)

Example: 
```swift
import SolanaSwift

let blockchainClient = BlockchainClient(apiClient: JSONRPCAPIClient(endpoint: endpoint))

/// Prepare any transaction, use any Solana program to create instructions, see section Solana program. 
let preparedTransaction = try await blockchainClient.prepareTransaction(
    instructions: [...],
    signers: [...],
    feePayer: ...
)

/// SPECIAL CASE: Prepare Sending Native SOL
let preparedTransaction = try await blockchainClient.prepareSendingNativeSOL(
    account: account,
    to: toPublicKey,
    amount: 0
)

/// SPECIAL CASE: Sending SPL Tokens
let preparedTransactions = try await blockchainClient.prepareSendingSPLTokens(
    account: account,
    mintAddress: <SPL TOKEN MINT ADDRESS>,  // USDC mint
    decimals: 6,
    from: <YOUR SPL TOKEN ADDRESS>, // Your usdc address
    to: destination,
    amount: <AMOUNT IN LAMPORTS>
)

/// Simulate or send

blockchainClient.simulateTransaction(
    preparedTransaction: preparedTransaction
)

blockchainClient.sendTransaction(
    preparedTransaction: preparedTransaction
)
```

### Solana Program
List of default programs and pre-defined method that live on Solana network:
1. SystemProgram. See [Documentation](https://p2p-org.github.io/solana-swift/documentation/solanaswift/systemprogram)
2. TokenProgram. See [Documentation](https://p2p-org.github.io/solana-swift/documentation/solanaswift/tokenprogram)
3. AssociatedTokenProgram. See [Documentation](https://p2p-org.github.io/solana-swift/documentation/solanaswift/associatedtokenprogram)
4. OwnerValidationProgram. See [Documentation](https://p2p-org.github.io/solana-swift/documentation/solanaswift/ownervalidationprogram)
5. TokenSwapProgram. See [Documentation](https://p2p-org.github.io/solana-swift/documentation/solanaswift/tokenswapprogram)

### Solana Tokens Repository
Tokens repository usefull when you need to get a list of tokens. See [Documentation](https://p2p-org.github.io/solana-swift/documentation/solanaswift/tokensrepository)

Example:
```swift
let tokenRepository = TokensRepository(endpoint: endpoint)
let list = try await tokenRepository.getTokensList()
```
TokenRepository be default uses cache not to make extra calls, it can disabled manually `.getTokensList(useCache: false)`

## How to use OrcaSwap
OrcaSwap has been moved to new library [OrcaSwapSwift](https://github.com/p2p-org/OrcaSwapSwift) 

## How to use RenVM
RenVM has been moved to new library [RenVMSwift](https://github.com/p2p-org/RenVMSwift)

## How to use Serum swap (DEX) (NOT STABLE)
SerumSwap has been moved to new library [SerumSwapSwift](https://github.com/p2p-org/SerumSwapSwift)

## Contribution
- Welcome to contribute, feel free to change and open a PR.

## Author
Chung Tran, chung.t@p2p.org

## License

SolanaSwift is available under the MIT license. See the LICENSE file for more info.
