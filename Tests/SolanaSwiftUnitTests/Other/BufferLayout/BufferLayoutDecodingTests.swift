import SolanaSwift
import XCTest

class BufferLayoutDecodingTests: XCTestCase {
    // MARK: - Raw data

    func testDecodingRawData() throws {
        let string =
            "AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)

        let expectedBytes: [UInt8] = [
            1, 0, 0, 0, 6, 26, 217, 208, 83, 135, 21,
            72, 83, 126, 222, 62, 38, 24, 73, 163, 223, 183,
            253, 2, 250, 188, 117, 178, 35, 200, 228,
            106, 219, 133, 61, 12, 0, 16, 165, 212, 232,
            0, 0, 0, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ]

        XCTAssertEqual(try Data(from: &binaryReader).bytes, expectedBytes)
    }

    // MARK: - VecU8

    func testDecodingVecU8() throws {
        let string = "GQCn7dKsGcVAJhtFRDDBcRgD8i3I/WDk4Z2y"
        let data = Data(base64Encoded: string)!
        var binaryReader = BinaryReader(bytes: data.bytes)
        let vecU8 = try VecU8<UInt16>(from: &binaryReader)

        XCTAssertEqual(vecU8.length, 25)
        XCTAssertEqual(vecU8.data.bytes, [
            167, 237, 210, 172, 25, 197,
            64, 38, 27, 69, 68, 48, 193,
            113, 24, 3, 242, 45, 200, 253,
            96, 228, 225, 157, 178,
        ])
    }

    // MARK: - Mint

    func testDecodingMint() throws {
        XCTAssertEqual(TokenMintState.BUFFER_LENGTH, 82)

        let string =
            "AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)
        let mintLayout = try TokenMintState(from: &binaryReader)

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
        XCTAssertEqual(TokenAccountState.BUFFER_LENGTH, 165)

        let string =
            "BhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQwCqmOzhzy1ve5l2AqL0ottCChJZ1XSIW3k3C7TaBQn7aCGAQAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWqAQAAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

        let data = Data(base64Encoded: string)!

        var binaryReader = BinaryReader(bytes: data.bytes)
        let accountInfo = try TokenAccountState(from: &binaryReader)

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
        let accountInfo = try TokenAccountState(from: &binaryReader)

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
        let accountInfo2 = try TokenAccountState(from: &binaryReader2)

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

    // MARK: - Token2022

    func testDecodingToken2022MintState() throws {
        let string =
            "AAAAAAT3LznRbp1toHmr0Mjv1bBjc6oSrtihgQu/PG0Sunz6XUTVg3ktAAAFAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAT3LznRbp1toHmr0Mjv1bBjc6oSrtihgQu/PG0Sunz6N5bilgAAAAASAgAAAAAAAAAgPYh5LQAALAESAgAAAAAAAAAgPYh5LQAALAE="
        let data = Data(base64Encoded: string)!
        var binaryReader = BinaryReader(bytes: data.bytes)
        let state = try Token2022MintState(from: &binaryReader)

        XCTAssertEqual(state.mintAuthorityOption, 0)
        XCTAssertEqual(state.mintAuthority?.base58EncodedString, "LPF354oHyPWL7BoMRySPQLwfvUyqPBWpwC4R7atptrD")
        XCTAssertEqual(state.isInitialized, true)
        XCTAssertEqual(state.freezeAuthorityOption, 0)
        XCTAssertEqual(state.decimals, 5)
        XCTAssertEqual(state.supply, 49_999_926_084_701)
        XCTAssertEqual(state.extensions.count, 1)

        // Assertions for the extension state
        let extensionState = state.getParsedExtension(ofType: TransferFeeConfigExtensionState.self)!
        XCTAssertEqual(extensionState.withheldAmount, 2_531_431_991)
        XCTAssertEqual(
            extensionState.transferFeeConfigAuthority.base58EncodedString,
            "11111111111111111111111111111111"
        )
        XCTAssertEqual(
            extensionState.withdrawWithHeldAuthority.base58EncodedString,
            "LPF354oHyPWL7BoMRySPQLwfvUyqPBWpwC4R7atptrD"
        )
        XCTAssertEqual(extensionState.olderTransferFee.maximumFee, 50_000_000_000_000)
        XCTAssertEqual(extensionState.olderTransferFee.epoch, 530)
        XCTAssertEqual(extensionState.olderTransferFee.transferFeeBasisPoints, 300)
        XCTAssertEqual(extensionState.newerTransferFee.transferFeeBasisPoints, 300)
        XCTAssertEqual(extensionState.newerTransferFee.maximumFee, 50_000_000_000_000)
        XCTAssertEqual(extensionState.newerTransferFee.epoch, 530)
    }

    func testDecodingToken2022MintState2() throws {
        // Mint FZYEgCWzzedxcmxYvGXSkMrj7TaA3bXoaEv6XMnwtLKh
        let string =
            "AAAAABdZNqd8UPqRoeBHXdhoEwzZNLf6UnDQ1UDsr4oXimfhquOLA1BVIXECAQAAAAAXWTanfFD6kaHgR13YaBMM2TS3+lJw0NVA7K+KF4pn4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALoDKJKHBCRLpAQAAAAAAAACQI15ZrVt7LAHpAQAAAAAAAACQI15ZrVt7LAEKADQAF1k2p3xQ+pGh4Edd2GgTDNk0t/pScNDVQOyviheKZ+EN9NlkAAAAAAAADfTZZAAAAAAAAAYAAQAB"
        let data = Data(base64Encoded: string)!
        var binaryReader = BinaryReader(bytes: data.bytes)
        let state = try Token2022MintState(from: &binaryReader)

        XCTAssertEqual(state.extensions.count, 3)

        let transferConfig = state.getParsedExtension(
            ofType: TransferFeeConfigExtensionState.self
        )

        XCTAssertEqual(transferConfig?.length, 108)
        XCTAssertEqual(transferConfig?.transferFeeConfigAuthority, "11111111111111111111111111111111")
        XCTAssertEqual(transferConfig?.withdrawWithHeldAuthority, "11111111111111111111111111111111")
        XCTAssertEqual(transferConfig?.withheldAmount, 1_299_782_865_324_245_038)
        XCTAssertEqual(transferConfig?.olderTransferFee.epoch, 489)
        XCTAssertEqual(transferConfig?.olderTransferFee.maximumFee, 8_888_888_888_888_889_344)
        XCTAssertEqual(transferConfig?.olderTransferFee.transferFeeBasisPoints, 300)
        XCTAssertEqual(transferConfig?.newerTransferFee.epoch, 489)
        XCTAssertEqual(transferConfig?.newerTransferFee.maximumFee, 8_888_888_888_888_889_344)
        XCTAssertEqual(transferConfig?.newerTransferFee.transferFeeBasisPoints, 300)

        let interestBearingConfig = state.getParsedExtension(
            ofType: InterestBearingConfigExtensionState.self
        )

        XCTAssertEqual(interestBearingConfig?.length, 52)
        XCTAssertEqual(interestBearingConfig?.rateAuthority, "2a9H7uNfUxt7YdS5yH3ZEijdPqpeBtyq7JPtVyi6XKtk")
        XCTAssertEqual(interestBearingConfig?.initializationTimestamp, 1_692_005_389)
        XCTAssertEqual(interestBearingConfig?.preUpdateAverageRate, 0)
        XCTAssertEqual(interestBearingConfig?.lastUpdateTimestamp, 1_692_005_389)
        XCTAssertEqual(interestBearingConfig?.currentRate, 0)
    }

    func testDecodingToken2022AccountState() throws {
        let string =
            "c8d675Tc8/enuGEbVogbaWoW6iY9JFkJIswLnf/gvCXDAcw04n4gWtOj5P12Rb7RAxY9RRwFQOwFWCWPS3OnJgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgcAAAA="
        let data = Data(base64Encoded: string)!
        var binaryReader = BinaryReader(bytes: data.bytes)
        let state = try Token2022AccountState(from: &binaryReader)

        XCTAssertEqual(state.isNativeRaw, 0)
        XCTAssertEqual(state.delegatedAmount, 0)
        XCTAssertEqual(state.mint.base58EncodedString, "8nxJnGJDyvehdEHw4PgRc7ccJ1Zi134PhM2USK3WE8mS")
        XCTAssertEqual(state.delegateOption, 0)
        XCTAssertNil(state.delegate)
        XCTAssertEqual(state.isFrozen, false)
        XCTAssertEqual(state.closeAuthorityOption, 0)
        XCTAssertEqual(state.isNativeOption, 0)
        XCTAssertEqual(state.owner.base58EncodedString, "E8E6GvyCpbGu7YSFxfhTXGx6SW4VhzVmxWh3gbrgXZNd")
        XCTAssertEqual(state.lamports, 0)
        XCTAssertEqual(state.isInitialized, true)
        XCTAssertEqual(state.isNative, false)
        XCTAssertEqual(state.state, 1)

        XCTAssertEqual(state.extensions.count, 1)

        // Assertions for the extension state
        let firstExtension = state.extensions[0]
        XCTAssertEqual(firstExtension.type, .immutableOwner)

        let extensionState = firstExtension.state as! VecU8<UInt16>
        XCTAssertEqual(extensionState.length, 0)
        XCTAssertEqual(extensionState.data, Data())
    }
}
