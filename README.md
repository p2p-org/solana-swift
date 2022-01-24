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
- iOS 11 or later
- RxSwift

## Dependencies
- RxAlamofire
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
* Every class or struct is defined within namespace `SolanaSDK`, for example: `SolanaSDK.Account`, `SolanaSDK.Error`.

* Import
```swift
import SolanaSwift
```

* Create an `AccountStorage` for saving account's `keyPairs` (public and private key), for example: `KeychainAccountStorage` for saving into `Keychain` in production, or `InMemoryAccountStorage` for temporarily saving into memory for testing. The `AccountStorage` must conform to protocol `SolanaSDKAccountStorage`, which has 2 requirements: function for saving `save(_ account:) throws` and computed property `account: SolanaSDK.Account?` for retrieving user's account.

Example:
```swift
import KeychainSwift
struct KeychainAccountStorage: SolanaSDKAccountStorage {
    let tokenKey = <YOUR_KEY_TO_STORE_IN_KEYCHAIN>
    func save(_ account: SolanaSDK.Account) throws {
        let data = try JSONEncoder().encode(account)
        keychain.set(data, forKey: tokenKey)
    }
    
    var account: SolanaSDK.Account? {
        guard let data = keychain.getData(tokenKey) else {return nil}
        return try? JSONDecoder().decode(SolanaSDK.Account.self, from: data)
    }
}

struct InMemoryAccountStorage: SolanaSDKAccountStorage {
    private var _account: SolanaSDK.Account?
    func save(_ account: SolanaSDK.Account) throws {
        _account = account
    }
    var account: SolanaSDK.Account? {
        _account
    }
}
```
* Creating an instance of `SolanaSDK`:
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


## How to use Serum swap (DEX) (NOT STABLE)
* Create an instance of SerumSwap
```swift
let serumSwap = SerumSwap(client: solanaSDK, accountProvider: solanaSDK)
```
* swap
```swift
serumSwap.swap(
    fromMint: <PublicKey>,
    toMint: <PublicKey>,
    amount: <Lamports>,
    minExpectedSwapAmount: <Lamports?>,
    referral: <PublicKey?>,
    quoteWallet: <PublicKey?>,
    fromWallet: <PublicKey>,
    toWallet: <PublicKey?>,
    feePayer: <PublicKey?>,
    configs: <SolanaSDK.RequestConfiguration? = nil>
)
```

## Contribution
- For supporting new methods, data types, edit `SolanaSDK+Methods` or `SolanaSDK+Models`
- For testing, run `Example` project and creating test using `RxBlocking`
- Welcome to contribute, feel free to change and open a PR.

## Author
Chung Tran, chung.t@p2p.org

## License

SolanaSwift is available under the MIT license. See the LICENSE file for more info.
