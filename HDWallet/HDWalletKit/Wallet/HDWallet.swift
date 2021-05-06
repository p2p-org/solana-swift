//
//  Wallet.swift
//  WalletKit
//
//  Created by yuzushioh on 2018/01/01.
//  Copyright © 2018 yuzushioh. All rights reserved.
//
import Foundation

public final class HDWallet {
    
    public let privateKey: HDPrivateKey
    public let coin: Coin
    
    public init(seed: Data, coin: Coin) {
        self.coin = coin
        privateKey = HDPrivateKey(seed: seed, coin: coin)
    }
    
    //MARK: - Public
    public func generateAddress(at index: UInt32)  -> String {
        let derivedKey = bip44PrivateKey.derived(at: .notHardened(index))
        return derivedKey.publicKey.address
    }
    
    public func generateAccount(at derivationPath: [DerivationNode]) -> HDAccount {
        let privateKey = generatePrivateKey(at: derivationPath)
        return HDAccount(privateKey: privateKey)
    }
    
    public func generateAccount(at index: UInt32 = 0) -> HDAccount {
        let address = bip44PrivateKey.derived(at: .notHardened(index))
        return HDAccount(privateKey: address)
    }
    
    public func generateAccounts(count: UInt32) -> [HDAccount]  {
        var accounts:[HDAccount] = []
        for index in 0..<count {
            accounts.append(generateAccount(at: index))
        }
        return accounts
    }
    
    public func sign(rawTransaction: EthereumRawTransaction) throws -> String {
        let signer = EIP155Signer(chainId: 1)
        let rawData = try signer.sign(rawTransaction, privateKey: privateKey)
        let hash = rawData.toHexString().addHexPrefix()
        return hash
    }
    
    //MARK: - Private
    //https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    private var bip44PrivateKey:HDPrivateKey {
        let bip44Purpose:UInt32 = 44
        let purpose = privateKey.derived(at: .hardened(bip44Purpose))
        let coinType = purpose.derived(at: .hardened(coin.coinType))
        let account = coinType.derived(at: .hardened(0))
        let receive = account.derived(at: .notHardened(0))
        return receive
    }
    
    private func generatePrivateKey(at nodes:[DerivationNode]) -> HDPrivateKey {
        return privateKey(at: nodes)
    }
    
    private func privateKey(at nodes: [DerivationNode]) -> HDPrivateKey {
        var key: HDPrivateKey = privateKey
        for node in nodes {
            key = key.derived(at:node)
        }
        return key
    }
}
