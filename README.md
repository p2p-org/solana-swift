# SolanaSwift

Solana-blockchain client, written in pure swift.

[![Version](https://img.shields.io/cocoapods/v/SolanaSwift.svg?style=flat)](https://cocoapods.org/pods/SolanaSwift)
[![License](https://img.shields.io/cocoapods/l/SolanaSwift.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Platform](https://img.shields.io/cocoapods/p/SolanaSwift.svg?style=flat)](https://cocoapods.org/pods/SolanaSwift)

## Features
- [x] Key pairs generation
- [x] Networking with POST methods for comunicating with solana-based networking system
- [x] Create, sign transactions
- [x] Socket communication
- [x] Orca swap
- [x] Serum DEX Swap
- [x] RenVM (Support: Bitcoin)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Demo wallet: [p2p-wallet](https://github.com/p2p-org/p2p-wallet-ios)

## Requirements
- iOS 13 or later
- [Deprecated] RxSwift

## Dependencies
- [Deprecated] RxAlamofire
- TweetNacl
- CryptoSwift
- Starscream

## Installation

SolanaSwift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SolanaSwift', :git => 'https://github.com/p2p-org/solana-swift.git'
```

## How to use
* From v2.0.0 we officially ditch Rx library from dependencies and adopt swift concurrency to `solana-swift`
* For those who still use `SolanaSDK` class, see [How to use SolanaSDK (Deprecated) section](#how-to-use-solanasdk-deprecated)

### Import
```swift
import SolanaSwift
```

### AccountStorage
Create an `SolanaAccountStorage` for saving account's `keyPairs` (public and private key), for example: `KeychainAccountStorage` for saving into `Keychain` in production, or `InMemoryAccountStorage` for temporarily saving into memory for testing. The "`CustomAccountStorage`" must conform to protocol `SolanaAccountStorage`, which has 2 requirements: function for saving `save(_ account:) throws` and computed property `account: SolanaSDK.Account? { get thrrows }` for retrieving user's account.

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
        get throws {
            guard let data = keychain.getData(tokenKey) else {return nil}
            return try JSONDecoder().decode(SolanaSDK.Account.self, from: data)
        }
    }
}

struct InMemoryAccountStorage: SolanaAccountStorage {
    private var _account: SolanaSDK.Account?
    func save(_ account: Account) throws {
        _account = account
    }
    
    var account: Account? {
        get throws {
            _account
        }
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
Make an API call to Solana using JSONRPC Client

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
guard let account = try? accountStorage.account?.publicKey else { throw SolanaError.unauthorized }
let balance = try await apiClient.getBalance(account: try accountStorage.account, commitment: "recent")
```

// Observe signature status with `observeSignatureStatus` method
In stead of using socket to observe signature status, which is not really reliable (socket often returns signature status == `finalized` when it is not fully finalized), we observe its status by periodically sending `getSignatureStatuses` (with `observeSignatureStatus` method)
```swift
var statuses = [TransactionStatus]()
for try await status in apiClient.observeSignatureStatus(signature: "jaiojsdfoijvaij", timeout: 60, delay: 3) {
    print(status)
    statuses.append(status)
}
// statuses.last == .sending // the signature is not confirmed
// statuses.last?.numberOfConfirmations == x // the signature is confirmed by x nodes (partially confirmed)
// statuses.last == .finalized // the signature is confirmed by all nodes
```

The full list of supported methods available in `APIClient/APIClient.swift`

### Solana Blockchain Client
Prepare, send and simulate transactions

Example: 
```swift
import SolanaSwift

/// Prepare Sending SPL Tokens
let fee = try await api.getFees(commitment: nil)
let bc = BlockchainClient(apiClient: JSONRPCAPIClient(endpoint: endpoint))
try await bc.prepareSendingSPLTokens(account: account,
                                     mintAddress: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", 
                                     decimals: 6,
                                     from: "DjY1uZozQTPz9c6WsjpPC3jXWp7u98KzyuyQTRzcGHFk",
                                     to: destination,
                                     amount: Double(0.001).toLamport(decimals: 6),
                                     fee: fee,
                                     feePayer: "B4PdyoVU39hoCaiTLPtN9nJxy6rEpbciE3BNPvHkCeE2",
                                     recentBlockhash: "F8wk1XcFVcd5M3UDx8S2jy3mEhSVkeBgYw979Mp2fF4")

/// Prepare Sending SPL Tokens
feeCalculator = DefaultFeeCalculator(lamportsPerSignature: lamportsPerSignature, minRentExemption: minRentExemption)

let recentBlockhash = try await apiClient.getRecentBlockhash(commitment: nil)
try await blockchain.prepareSendingNativeSOL(account: account,
                                             to: toPublicKey,
                                             amount: 0,
                                             feePayer: feePayerPublicKey,
                                             recentBlockhash: "F8wk1XcFVcd5M3UDx8S2jy3mEhSVkeBgYw979Mp2fF4",
                                             feeCalculator: feeCalculator)
```


### Solana Tokens Repository
Tokens repository usefull when you need to get a list of tokens

Example:
```swift
let tokenRepository = TokensRepository(endpoint: endpoint)
let list = try await tokenRepository.getTokensList()
```
TokenRepository be default uses cache not to make extra calls, it can disabled manually `.getTokensList(useCache: false)`


## How to use SolanaSDK (Deprecated)
* [Deprecated] Every class or struct is defined within namespace `SolanaSDK`, for example: `SolanaSDK.Account`, `SolanaSDK.Error`.

* Import
```swift
import SolanaSwift
```

* Create an `SolanaAccountStorage` for saving account's `keyPairs` (public and private key), for example: `KeychainAccountStorage` for saving into `Keychain` in production, or `InMemoryAccountStorage` for temporarily saving into memory for testing. The "`CustomAccountStorage`" must conform to protocol `SolanaAccountStorage`, which has 2 requirements: function for saving `save(_ account:) throws` and computed property `account: SolanaSDK.Account? { get thrrows }` for retrieving user's account.

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
        get throws {
            guard let data = keychain.getData(tokenKey) else {return nil}
            return try JSONDecoder().decode(SolanaSDK.Account.self, from: data)
        }
    }
}

struct InMemoryAccountStorage: SolanaAccountStorage {
    private var _account: SolanaSDK.Account?
    func save(_ account: Account) throws {
        _account = account
    }
    
    var account: Account? {
        get throws {
            _account
        }
    }
}
```
* [Deprecated] Creating an instance of `SolanaSDK`:
```swift
let solanaSDK = SolanaSDK(endpoint: <YOUR_API_ENDPOINT>, accountStorage: KeychainAccountStorage.shared) // endpoint example: https://api.mainnet-beta.solana.com
```
* Creating an account:
```swift
let mnemonic = Mnemonic()
let account = try SolanaSDK.Account(phrase: mnemonic.phrase, network: .mainnetBeta, derivablePath: .default)
try solanaSDK.accountStorage.save(account)
```
* Send pre-defined POST methods, which return a `RxSwift.Single`. [List of predefined methods](https://github.com/p2p-org/solana-swift/blob/main/SolanaSwift/Classes/Generated/SolanaSDK%2BGeneratedMethods.swift):

Example:
```swift
solanaSDK.getBalance(account: account, commitment: "recent")
    .subscribe(onNext: {balance in
        print(balance)
    })
    .disposed(by: disposeBag)
```
* Send token:
```swift
solanaSDK.sendNativeSOL(
    to destination: String,
    amount: UInt64,
    isSimulation: Bool = false
)
    .subscribe(onNext: {result in
        print(result)
    })
    .disposed(by: disposeBag)
    
solanaSDK.sendSPLTokens(
    mintAddress: String,
    decimals: Decimals,
    from fromPublicKey: String,
    to destinationAddress: String,
    amount: UInt64,
    isSimulation: Bool = false
)
    .subscribe(onNext: {result in
        print(result)
    })
    .disposed(by: disposeBag)
```
* Send custom method, which was not defined by using method `request<T: Decodable>(method:, path:, bcMethod:, parameters:) -> Single<T>`

Example:
```swift
(solanaSDK.request(method: .post, bcMethod: "aNewMethodThatReturnsAString", parameters: []) as Single<String>)
```
* Subscribe and observe socket events:
```swift
// accountNotifications
solanaSDK.subscribeAccountNotification(account: <ACCOUNT_PUBLIC_KEY>, isNative: <BOOL>) // isNative = true if you want to observe native solana account
solanaSDK.observeAccountNotifications() // return an Observable<(pubkey: String, lamports: Lamports)>

// signatureNotifications
solanaSDK.observeSignatureNotification(signature: <SIGNATURE>) // return an Completable
```

## How to use OrcaSwap
OrcaSwap has been moved to new library [OrcaSwapSwift](https://github.com/p2p-org/OrcaSwapSwift) 

## How to use RenVM
RenVM has been moved to new library [RenVMSwift](https://github.com/p2p-org/RenVMSwift)

## How to use Serum swap (DEX) (NOT STABLE)
SerumSwap has been moved to new library [SerumSwapSwift](https://github.com/p2p-org/SerumSwapSwift)

## Contribution
- For supporting new methods, data types, edit `SolanaSDK+Methods` or `SolanaSDK+Models`
- For testing, run `Example` project and creating test using `RxBlocking`
- Welcome to contribute, feel free to change and open a PR.

## Author
Chung Tran, chung.t@p2p.org

## License

SolanaSwift is available under the MIT license. See the LICENSE file for more info.
