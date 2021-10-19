//
//  OrcaSwapSwapTests.swift
//  
//
//  Created by Chung Tran on 19/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

class OrcaSwapSwapTests: XCTestCase {
    var solanaSDK: SolanaSDK!
    var orcaSwap: OrcaSwap!
    var endpoint: SolanaSDK.APIEndPoint! {
        .init(url: "https://p2p.rpcpool.com/", network: .mainnetBeta)
    }
    var phrase: String {
        "miracle pizza supply useful steak border same again youth silver access hundred"
    }
    
    var notificationHandler: OrcaSwapSignatureNotificationHandler {
        OrcaSwap.MockSocket()
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let accountStorage = InMemoryAccountStorage()
        
        solanaSDK = SolanaSDK(
            endpoint: endpoint,
            accountStorage: accountStorage
        )
        
        let account = try SolanaSDK.Account(
            phrase: phrase.components(separatedBy: " "),
            network: endpoint.network
        )
        try accountStorage.save(account)
        
        orcaSwap = OrcaSwap(
            apiClient: OrcaSwap.MockAPIClient(network: "mainnet"),
            solanaClient: solanaSDK,
            accountProvider: solanaSDK,
            notificationHandler: notificationHandler
        )
        
        _ = orcaSwap.load().toBlocking().materialize()
    }
    
    let btcMint = "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E"
    let ethMint = "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk"
    let socnMint = "5oVNBeEEQvYi1cX3ir8Dx5n1P7pdxydbGF2X4TxVusJm"
    let solMint = "So11111111111111111111111111111111111111112"
    let ninjaMint = "FgX1WD9WzMU3yLwXaFSarPfkgzjLb2DZCqmkx9ExpuvJ"
    let usdcMint = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
    let mngoMint = "MangoCzJ36AjZyKwVj3VnYU4GTonjfVEnJmvvWaxLac"
    let slimMint = "xxxxa1sKNGwFtw2kFn8XauW9xq8hBZ5kVtcSesTT9fW"
    let kuroMint = "2Kc38rfQ49DFaKHQaWbijkE7fcymUMLY5guUiUsDmFfn"

    let socnSOLStableAquafarmsPool = OrcaSwap.Pool(
        account: "2q6UMko5kTnv866W9MTeAFau94pLpsdeNjDdSYSgZUXr",
        authority: "Gyd77CwV23qq937x9UDa4TDkxEeQF9tp8ifotYxqW3Kd",
        nonce: 255,
        poolTokenMint: "APNpzQvR91v1THbsAyG3HHrUEwvexWYeNCFLQuVnxgMc",
        tokenAccountA: "C8DRXUqxXtUgvgBR7BPAmy6tnRJYgVjG27VU44wWDMNV",
        tokenAccountB: "DzdxH5qJ68PiM1p5o6PbPLPpDj8m1ZshcaMFATcxDZix",
        feeAccount: "42Xzazs9EvjtidvEDrj3JXbDtf6fpTq5XHh96mPctvBV",
        hostFeeAccount: nil,
        feeNumerator: 6,
        feeDenominator: 10000,
        ownerTradeFeeNumerator: 1,
        ownerTradeFeeDenominator: 10000,
        ownerWithdrawFeeNumerator: 0,
        ownerWithdrawFeeDenominator: 0,
        hostFeeNumerator: 0,
        hostFeeDenominator: 0,
        tokenAName: "SOCN",
        tokenBName: "SOL",
        curveType: "Stable",
        amp: 100,
        programVersion: 2,
        deprecated: nil,
        tokenABalance: .init(amount: "19645113670860", decimals: 9),
        tokenBBalance: .init(amount: "27266410382891", decimals: 9),
        isStable: true
    )

    let solNinjaAquafarmsPool = OrcaSwap.Pool(
        account: "3ECUtPokme1nimJfuAkMtcm7QYjDEfXRQzmGC16LuYnz",
        authority: "H8f9n2PfehUc73gRWSRTPXvqUhUHVywdAxcfEtYmmyAo",
        nonce: 255,
        poolTokenMint: "4X1oYoFWYtLebk51zuh889r1WFLe8Z9qWApj87hQMfML",
        tokenAccountA: "9SxzphwrrDVDkwkyvmtag9NLgpjSkTw35cRwg9rLMYWk",
        tokenAccountB: "6Y9VyEYHgxVahiixzphNh4HAywpab9zVoD4S8q1sfuL8",
        feeAccount: "43ViAbUVujnYtJyzGP4AhabMYCbLsExenT3WKsZjqJ7N",
        hostFeeAccount: nil,
        feeNumerator: 25,
        feeDenominator: 10000,
        ownerTradeFeeNumerator: 5,
        ownerTradeFeeDenominator: 10000,
        ownerWithdrawFeeNumerator: 0,
        ownerWithdrawFeeDenominator: 0,
        hostFeeNumerator: 0,
        hostFeeDenominator: 0,
        tokenAName: "SOL",
        tokenBName: "NINJA",
        curveType: "ConstantProduct",
        amp: nil,
        programVersion: 2,
        deprecated: nil,
        tokenABalance: .init(
            uiAmount: 19449.398641374,
            amount: "19449398641374",
            decimals: 9,
            uiAmountString: "19449.398641374"
        ),
        tokenBBalance: .init(
            uiAmount: 1796762.444462,
            amount: "1796762444462",
            decimals: 6,
            uiAmountString: "1796762.444462"
        ),
        isStable: nil
    )

    let socnUSDCAquafarmsPool = OrcaSwap.Pool(
        account: "6Gh36sNXrGWYiWr999d9iZtqgnipJbWuBohyHBN1cJpS",
        authority: "GXWEpRURaQZ9E62Q23EreTUfBy4hfemXgWFUWcg7YFgv",
        nonce: 255,
        poolTokenMint: "Dkr8B675PGnNwEr9vTKXznjjHke5454EQdz3iaSbparB",
        tokenAccountA: "7xs9QsrxQDVoWQ8LQ8VsVjfPKBrPGjvg8ZhaLnU1i2VR",
        tokenAccountB: "FZFJK64Fk1t619zmVPqCx8Uy29zJ3WuvjWitCQuxXRo3",
        feeAccount: "HsC1Jo38jK3EpoNAkxfoUJhQVPa28anewZpLfeouUNk7",
        hostFeeAccount: nil,
        feeNumerator: 25,
        feeDenominator: 10000,
        ownerTradeFeeNumerator: 5,
        ownerTradeFeeDenominator: 10000,
        ownerWithdrawFeeNumerator: 0,
        ownerWithdrawFeeDenominator: 0,
        hostFeeNumerator: 0,
        hostFeeDenominator: 0,
        tokenAName: "SOCN",
        tokenBName: "USDC",
        curveType: "ConstantProduct",
        amp: nil,
        programVersion: 2,
        deprecated: nil,
        tokenABalance: .init(
            uiAmount: 3477.492966425,
            amount: "3477492966425",
            decimals: 9,
            uiAmountString: "3477.492966425"
        ),
        tokenBBalance: .init(
            uiAmount: 554749.837968,
            amount: "554749837968",
            decimals: 6,
            uiAmountString: "554749.837968"
        ),
        isStable: nil
    )

    let usdcMNGOAquafarmsPool = OrcaSwap.Pool(
        account: "Hk9ZCvmqVT1FHNkWJMrtMkkVnH1WqssWPAvmio5Vs3se",
        authority: "5RyiYaHFDVupwnwxzKCRk7JY1CKhsczZXefMs3UUmx4Z",
        nonce: 254,
        poolTokenMint: "H9yC7jDng974WwcU4kTGs7BKf7nBNswpdsP5bzbdXjib",
        tokenAccountA: "5yMoAhjfFaCPwEwKM2VeFFh2iBs5mHWLTJ4LuqZifsgN",
        tokenAccountB: "J8bQnhcNyixFGBskQoJ2aSPXPWjvSzaaxF4YPs96XHDJ",
        feeAccount: "FWKcKaMfaVezLRFr946MdgmpTZHG4A2GgqehAxjTyDAB",
        hostFeeAccount: nil,
        feeNumerator: 25,
        feeDenominator: 10000,
        ownerTradeFeeNumerator: 5,
        ownerTradeFeeDenominator: 10000,
        ownerWithdrawFeeNumerator: 0,
        ownerWithdrawFeeDenominator: 0,
        hostFeeNumerator: 0,
        hostFeeDenominator: 0,
        tokenAName: "USDC",
        tokenBName: "MNGO",
        curveType: "ConstantProduct",
        amp: nil,
        programVersion: 2,
        deprecated: nil,
        tokenABalance: .init(uiAmount: 455018.515099, amount: "455018515099", decimals: 6, uiAmountString: "455018.515099"),
        tokenBBalance: .init(uiAmount: 1772765.337297, amount: "1772765337297", decimals: 6, uiAmountString: "1772765.337297"),
        isStable: nil
    )
    
    let solUSDCAquafarmsPool = OrcaSwap.Pool(
        account: "EGZ7tiLeH62TPV1gL8WwbXGzEPa9zmcpVnnkPKKnrE2U",
        authority: "JU8kmKzDHF9sXWsnoznaFDFezLsE5uomX2JkRMbmsQP",
        nonce: 252,
        poolTokenMint: "APDFRM3HMr8CAGXwKHiu2f5ePSpaiEJhaURwhsRrUUt9",
        tokenAccountA: "ANP74VNsHwSrq9uUSjiSNyNWvf6ZPrKTmE4gHoNd13Lg",
        tokenAccountB: "75HgnSvXbWKZBpZHveX68ZzAhDqMzNDS29X6BGLtxMo1",
        feeAccount: "8JnSiuvQq3BVuCU3n4DrSTw9chBSPvEMswrhtifVkr1o",
        hostFeeAccount: nil,
        feeNumerator: 25,
        feeDenominator: 10000,
        ownerTradeFeeNumerator: 5,
        ownerTradeFeeDenominator: 10000,
        ownerWithdrawFeeNumerator: 0,
        ownerWithdrawFeeDenominator: 0,
        hostFeeNumerator: 0,
        hostFeeDenominator: 0,
        tokenAName: "SOL",
        tokenBName: "USDC",
        curveType: "ConstantProduct",
        amp: nil,
        programVersion: 2,
        deprecated: nil,
        tokenABalance: .init(uiAmount: 229589.261208922, amount: "229589261208922", decimals: 9, uiAmountString: "229589.261208922"),
        tokenBBalance: .init(uiAmount: 36310284.213312, amount: "36310284213312", decimals: 6, uiAmountString: "36310284.213312"),
        isStable: nil
    )
    
    let usdcSLIMAquafarmsPool = OrcaSwap.Pool(
        account: "8JPid6GtND2tU3A7x7GDfPPEWwS36rMtzF7YoHU44UoA",
        authority: "749y4fXb9SzqmrLEetQdui5iDucnNiMgCJ2uzc3y7cou",
        nonce: 255,
        poolTokenMint: "BVWwyiHVHZQMPHsiW7dZH7bnBVKmbxdeEjWqVRciHCyo",
        tokenAccountA: "EFYW6YEiCGpavuMPS1zoXhgfNkPisWkQ3bQz1b4UfKek",
        tokenAccountB: "ErcxwkPgLdyoVL6j2SsekZ5iysPZEDRGfAggh282kQb8",
        feeAccount: "E6aTzkZKdCECgpDtBZtVpqiGjxRDSAFh1SC9CdSoVK7a",
        hostFeeAccount: nil,
        feeNumerator: 25,
        feeDenominator: 10000,
        ownerTradeFeeNumerator: 5,
        ownerTradeFeeDenominator: 10000,
        ownerWithdrawFeeNumerator: 0,
        ownerWithdrawFeeDenominator: 0,
        hostFeeNumerator: 0,
        hostFeeDenominator: 0,
        tokenAName: "USDC",
        tokenBName: "SLIM",
        curveType: "ConstantProduct",
        amp: nil,
        programVersion: 2,
        deprecated: nil,
        tokenABalance: .init(uiAmount: 423867.437266, amount: "423867437266", decimals: 6, uiAmountString: "423867.437266"),
        tokenBBalance: .init(uiAmount: 200571.837175, amount: "200571837175", decimals: 6, uiAmountString: "200571.837175"),
        isStable: nil
    )
    
    let solUSDCPool = OrcaSwap.Pool(
        account: "6fTRDD7sYxCN7oyoSQaN1AWC3P2m8A6gVZzGrpej9DvL",
        authority: "B52XRdfTsh8iUGbGEBJLHyDMjhaTW8cAFCmpASGJtnNK",
        nonce: 253,
        poolTokenMint: "ECFcUGwHHMaZynAQpqRHkYeTBnS5GnPWZywM8aggcs3A",
        tokenAccountA: "FdiTt7XQ94fGkgorywN1GuXqQzmURHCDgYtUutWRcy4q",
        tokenAccountB: "7VcwKUtdKnvcgNhZt5BQHsbPrXLxhdVomsgrr7k2N5P5",
        feeAccount: "4pdzKqAGd1WbXn1L4UpY4r58irTfjFYMYNudBrqbQaYJ",
        hostFeeAccount: nil,
        feeNumerator: 30,
        feeDenominator: 10000,
        ownerTradeFeeNumerator: 0,
        ownerTradeFeeDenominator: 0,
        ownerWithdrawFeeNumerator: 0,
        ownerWithdrawFeeDenominator: 0,
        hostFeeNumerator: 0,
        hostFeeDenominator: 0,
        tokenAName: "SOL",
        tokenBName: "USDC",
        curveType: "ConstantProduct",
        amp: nil,
        programVersion: nil,
        deprecated: true,
        tokenABalance: .init(uiAmount: 367.286039883, amount: "367286039883", decimals: 9, uiAmountString: "367.286039883"),
        tokenBBalance: .init(uiAmount: 57698.20799, amount: "57698207990", decimals: 6, uiAmountString: "57698.20799"),
        isStable: nil
    )
    
    let usdcKUROAquafarmsPool = OrcaSwap.Pool(
        account: "HdeYs4bpJKN2oTb7PHxbqq4kzKiLr772A5N2gWjY57ZT",
        authority: "2KRcBDQJWEPygxcMMFMvR6dMTVtMkJV6kbxr5e9Kdj5Q",
        nonce: 250,
        poolTokenMint: "DRknxb4ZFxXUTG6UJ5HupNHG1SmvBSCPzsZ1o9gAhyBi",
        tokenAccountA: "B252w7ZkUX4WyLUJKLEymEpRkYMqJhgv2PSj2Z2LWH34",
        tokenAccountB: "DBckbD9CoRBFE8WdbbnFLDz6WdDDSZ7ReEeqdjL62fpG",
        feeAccount: "5XuLrZqpX9gW3pJw7274EYwAft1ciTXndU4on96ERi9J",
        hostFeeAccount: nil,
        feeNumerator: 25,
        feeDenominator: 10000,
        ownerTradeFeeNumerator: 5,
        ownerTradeFeeDenominator: 10000,
        ownerWithdrawFeeNumerator: 0,
        ownerWithdrawFeeDenominator: 0,
        hostFeeNumerator: 0,
        hostFeeDenominator: 0,
        tokenAName: "USDC",
        tokenBName: "KURO",
        curveType: "ConstantProduct",
        amp: nil,
        programVersion: 2,
        deprecated: nil,
        tokenABalance: .init(uiAmount: 437928.692012, amount: "437928692012", decimals: 6, uiAmountString: "437928.692012"),
        tokenBBalance: .init(uiAmount: 3184945.666107, amount: "3184945666107", decimals: 6, uiAmountString: "3184945.666107"),
        isStable: nil
    )
}
