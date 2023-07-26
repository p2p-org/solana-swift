import SolanaSwift
import XCTest

class BufferLayoutTests: XCTestCase {
    // MARK: - Mint

    func testDecodingMint() throws {
        XCTAssertEqual(SPLTokenMintState.BUFFER_LENGTH, 82)

        let string =
            "AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)
        let mintLayout = try SPLTokenMintState(from: &binaryReader)

        XCTAssertEqual(mintLayout.mintAuthorityOption, 1)
        XCTAssertEqual(mintLayout.mintAuthority?.base58EncodedString, "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        XCTAssertEqual(mintLayout.supply, 1_000_000_000_000)
        XCTAssertEqual(mintLayout.decimals, 6)
        XCTAssertEqual(mintLayout.isInitialized, true)
        XCTAssertEqual(mintLayout.freezeAuthorityOption, 0)
        XCTAssertNil(mintLayout.freezeAuthority)
    }

    // MARK: - Account info

    func testDecodingAccountInfo() throws {
        XCTAssertEqual(SPLTokenAccountState.BUFFER_LENGTH, 165)

        let string =
            "BhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQwCqmOzhzy1ve5l2AqL0ottCChJZ1XSIW3k3C7TaBQn7aCGAQAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWqAQAAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)
        let accountInfo = try SPLTokenAccountState(from: &binaryReader)

        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", accountInfo.mint.base58EncodedString)
        XCTAssertEqual("BQWWFhzBdw2vKKBUX17NHeFbCoFQHfRARpdztPE2tDJ", accountInfo.owner.base58EncodedString)
        XCTAssertEqual(accountInfo.lamports, 100_000)
        XCTAssertEqual(accountInfo.delegateOption, 1)
        XCTAssertEqual("GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", accountInfo.delegate?.base58EncodedString)
        XCTAssertEqual(accountInfo.isInitialized, true)
        XCTAssertEqual(accountInfo.isFrozen, false)
        XCTAssertEqual(accountInfo.state, 1)
        XCTAssertEqual(accountInfo.isNativeOption, 0)
        XCTAssertEqual(accountInfo.rentExemptReserve, nil)
        XCTAssertEqual(accountInfo.isNativeRaw, 0)
        XCTAssertEqual(accountInfo.isNative, false)
        XCTAssertEqual(accountInfo.delegatedAmount, 100)
        XCTAssertEqual(accountInfo.closeAuthorityOption, 0)
        XCTAssertEqual(accountInfo.closeAuthority?.base58EncodedString, nil)
    }

    func testDecodingAccountInfo2() throws {
        let string =
            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq"

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)
        let accountInfo = try SPLTokenAccountState(from: &binaryReader)

        XCTAssertEqual("11111111111111111111111111111111", accountInfo.mint.base58EncodedString)
        XCTAssertEqual("11111111111111111111111111111111", accountInfo.owner.base58EncodedString)
        XCTAssertEqual(accountInfo.lamports, 0)
        XCTAssertEqual(accountInfo.delegateOption, 0)
        XCTAssertNil(accountInfo.delegate)
        XCTAssertEqual(accountInfo.isInitialized, false)
        XCTAssertEqual(accountInfo.isFrozen, false)
        XCTAssertEqual(accountInfo.state, 0)
        XCTAssertEqual(accountInfo.isNativeOption, 0)
        XCTAssertNil(accountInfo.rentExemptReserve)
        XCTAssertEqual(accountInfo.isNativeRaw, 0)
        XCTAssertEqual(accountInfo.isNative, false)
        XCTAssertEqual(accountInfo.delegatedAmount, 0)
        XCTAssertEqual(accountInfo.closeAuthorityOption, 1)
        XCTAssertEqual(accountInfo.closeAuthority?.base58EncodedString, "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")

        let string2 =
            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq"
        let data2 = Data(base64Encoded: string2)!

        var binaryReader2 = BinaryReader(bytes: data2.bytes)
        let accountInfo2 = try SPLTokenAccountState(from: &binaryReader2)

        XCTAssertEqual("11111111111111111111111111111111", accountInfo2.mint.base58EncodedString)
        XCTAssertEqual("11111111111111111111111111111111", accountInfo2.owner.base58EncodedString)
        XCTAssertEqual(accountInfo2.lamports, 0)
        XCTAssertEqual(accountInfo2.delegateOption, 0)
        XCTAssertNil(accountInfo2.delegate)
        XCTAssertEqual(accountInfo2.isInitialized, true)
        XCTAssertEqual(accountInfo2.isFrozen, true)
        XCTAssertEqual(accountInfo2.state, 2)
        XCTAssertEqual(accountInfo2.isNativeOption, 0)
        XCTAssertNil(accountInfo2.rentExemptReserve)
        XCTAssertEqual(accountInfo2.isNativeRaw, 0)
        XCTAssertEqual(accountInfo2.isNative, false)
        XCTAssertEqual(accountInfo2.delegatedAmount, 0)
        XCTAssertEqual(accountInfo2.closeAuthorityOption, 1)
        XCTAssertEqual(accountInfo2.closeAuthority?.base58EncodedString, "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
    }

    // MARK: - TokenSwapInfo

    func testDecodingTokenSwapInfo() throws {
        XCTAssertEqual(TokenSwapInfo.BUFFER_LENGTH, 324)

        let string =
            "AQH/Bt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKkg7XoTWySqouc9rBPiFviH2xU9/fRb+6P90QcOMKupqewjVdppkaFaD9TmikzQc7KAtp/LEF9bATPPnDdGT+7Kj7KrmDRVoZN9WTu3h9wgrrN83pVvcqGHLhOtWWeWCUjG+nrzvtutOj1l82qryXQxsbvkwtL24OR8pgIDRS9dYZqhgojuhD2D9j0JH/1UU78OyY17yIzxSctOkEdQqtVncXgwwKhJB+PCDsVtlUWWQbPgBu+MNnFskXx8qDFMwSAeAAAAAAAAABAnAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        let data = Data(base64Encoded: string)!
        var binaryReader = BinaryReader(bytes: data.bytes)
        let swapInfo = try TokenSwapInfo(from: &binaryReader)

        XCTAssertEqual(swapInfo.version, 1)
        XCTAssertEqual(swapInfo.isInitialized, true)
        XCTAssertEqual(swapInfo.nonce, 255)
        XCTAssertEqual(swapInfo.tokenProgramId.base58EncodedString, "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        XCTAssertEqual(swapInfo.tokenAccountA.base58EncodedString, "3DY5BRoi2dsBW8XsBep5GXAipbDqUJwLwGxJVTcZ3Xfe")
        XCTAssertEqual(swapInfo.tokenAccountB.base58EncodedString, "GtnU7VTM5bn2Z8LSfAa1Jz3YedeffxzkExkieFQsAjTP")
        XCTAssertEqual(swapInfo.tokenPool.base58EncodedString, "AfwKRiMcANbPdELxAisQY3hCJg9M86fDGQMGPYGswvYX")
        XCTAssertEqual(swapInfo.mintA.base58EncodedString, "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
        XCTAssertEqual(swapInfo.mintB.base58EncodedString, "BQcdHdAQW1hczDbBi9hiegXAR7A98Q9jx3X3iBBBDiq4")
        XCTAssertEqual(swapInfo.feeAccount.base58EncodedString, "8dwNHBvcqG7eXWhDucKXTcS57k9cweopc55Mm648N8B9")
        XCTAssertEqual(swapInfo.tradeFeeNumerator, 30)
        XCTAssertEqual(swapInfo.tradeFeeDenominator, 10000)
        XCTAssertEqual(swapInfo.ownerTradeFeeNumerator, 0)
        XCTAssertEqual(swapInfo.ownerTradeFeeDenominator, 0)
        XCTAssertEqual(swapInfo.ownerWithdrawFeeNumerator, 0)
        XCTAssertEqual(swapInfo.ownerWithdrawFeeDenominator, 0)
        XCTAssertEqual(swapInfo.hostFeeNumerator, 0)
        XCTAssertEqual(swapInfo.hostFeeDenominator, 0)
        XCTAssertEqual(swapInfo.curveType, 0)
        XCTAssertEqual(swapInfo.payer.base58EncodedString, "11111111111111111111111111111111")
    }

    // MARK: - EmptyInfo

    func testDecodingEmptyInfo() throws {
        let string =
            "AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
        let data = Data(base64Encoded: string)!
        var binaryReader = BinaryReader(bytes: data.bytes)
        let _ = try EmptyInfo(from: &binaryReader)
    }
}
