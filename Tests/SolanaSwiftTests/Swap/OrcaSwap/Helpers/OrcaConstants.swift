//
//  File.swift
//  
//
//  Created by Chung Tran on 18/10/2021.
//

import Foundation
@testable import SolanaSwift

let btcMint = "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E"
let ethMint = "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk"
let socnMint = "5oVNBeEEQvYi1cX3ir8Dx5n1P7pdxydbGF2X4TxVusJm"
let solMint = "So11111111111111111111111111111111111111112"
let ninjaMint = "FgX1WD9WzMU3yLwXaFSarPfkgzjLb2DZCqmkx9ExpuvJ"
let usdcMint = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
let mngoMint = "MangoCzJ36AjZyKwVj3VnYU4GTonjfVEnJmvvWaxLac"

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
    tokenABalance: .init(
        uiAmount: 20548.358418788,
        amount: "20548358418788",
        decimals: 9,
        uiAmountString: "20548.358418788"
    ),
    tokenBBalance: .init(
        uiAmount: 26424.277517753,
        amount: "26424277517753",
        decimals: 9,
        uiAmountString: "26424.277517753"
    ),
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
