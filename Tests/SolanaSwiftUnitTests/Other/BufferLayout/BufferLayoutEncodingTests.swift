import XCTest
@testable import SolanaSwift

final class BufferLayoutEncodingTests: XCTestCase {
    // MARK: - Mint

    func testEncodingMint() throws {
        let mintLayout = TokenMintState(
            mintAuthorityOption: 1,
            mintAuthority: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo",
            supply: 1_000_000_000_000,
            decimals: 6,
            isInitialized: true,
            freezeAuthorityOption: 0,
            freezeAuthority: nil
        )

        var data = Data()
        try mintLayout.serialize(to: &data)

        XCTAssertEqual(
            data.base64EncodedString(),
            "AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
        )
    }

    // MARK: - VecU8

    func testEncodingVecU8() throws {
        let length: UInt16 = 25
        let data = Data([
            167, 237, 210, 172, 25, 197,
            64, 38, 27, 69, 68, 48, 193,
            113, 24, 3, 242, 45, 200, 253,
            96, 228, 225, 157, 178,
        ])

        var result = Data()
        try VecU8(length: length, data: data).serialize(to: &result)

        XCTAssertEqual(result.base64EncodedString(), "GQCn7dKsGcVAJhtFRDDBcRgD8i3I/WDk4Z2y")
    }

    // MARK: - Account info

    func testEncodingAccountInfo() throws {
        XCTAssertEqual(TokenAccountState.BUFFER_LENGTH, 165)

        let accountInfo = TokenAccountState(
            mint: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo",
            owner: "BQWWFhzBdw2vKKBUX17NHeFbCoFQHfRARpdztPE2tDJ",
            lamports: 100_000,
            delegateOption: 1,
            delegate: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5",
            isInitialized: true,
            isFrozen: false,
            state: 1,
            isNativeOption: 0,
            rentExemptReserve: nil,
            isNativeRaw: 0,
            isNative: false,
            delegatedAmount: 100,
            closeAuthorityOption: 0,
            closeAuthority: nil
        )

        var data = Data()
        try accountInfo.serialize(to: &data)

        XCTAssertEqual(
            data.base64EncodedString(),
            "BhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQwCqmOzhzy1ve5l2AqL0ottCChJZ1XSIW3k3C7TaBQn7aCGAQAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWqAQAAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        )
    }

    func testEncodingAccountInfo2() throws {
        let accountInfo = TokenAccountState(
            mint: "11111111111111111111111111111111",
            owner: "11111111111111111111111111111111",
            lamports: 0,
            delegateOption: 0,
            delegate: nil,
            isInitialized: false,
            isFrozen: false,
            state: 0,
            isNativeOption: 0,
            rentExemptReserve: nil,
            isNativeRaw: 0,
            isNative: false,
            delegatedAmount: 0,
            closeAuthorityOption: 1,
            closeAuthority: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5"
        )

        var data = Data()
        try accountInfo.serialize(to: &data)

        XCTAssertEqual(
            data.base64EncodedString(),
            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq"
        )
    }

    // MARK: - TokenSwapInfo

    func testEncodingTokenSwapInfo() throws {
        let swapInfo = TokenSwapInfo(
            version: 1,
            isInitialized: true,
            nonce: 255,
            tokenProgramId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            tokenAccountA: "3DY5BRoi2dsBW8XsBep5GXAipbDqUJwLwGxJVTcZ3Xfe",
            tokenAccountB: "GtnU7VTM5bn2Z8LSfAa1Jz3YedeffxzkExkieFQsAjTP",
            tokenPool: "AfwKRiMcANbPdELxAisQY3hCJg9M86fDGQMGPYGswvYX",
            mintA: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            mintB: "BQcdHdAQW1hczDbBi9hiegXAR7A98Q9jx3X3iBBBDiq4",
            feeAccount: "8dwNHBvcqG7eXWhDucKXTcS57k9cweopc55Mm648N8B9",
            tradeFeeNumerator: 30,
            tradeFeeDenominator: 10000,
            ownerTradeFeeNumerator: 0,
            ownerTradeFeeDenominator: 0,
            ownerWithdrawFeeNumerator: 0,
            ownerWithdrawFeeDenominator: 0,
            hostFeeNumerator: 0,
            hostFeeDenominator: 0,
            curveType: 0,
            payer: "11111111111111111111111111111111"
        )

        var data = Data()
        try swapInfo.serialize(to: &data)

        XCTAssertEqual(
            data.base64EncodedString(),
            "AQH/Bt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKkg7XoTWySqouc9rBPiFviH2xU9/fRb+6P90QcOMKupqewjVdppkaFaD9TmikzQc7KAtp/LEF9bATPPnDdGT+7Kj7KrmDRVoZN9WTu3h9wgrrN83pVvcqGHLhOtWWeWCUjG+nrzvtutOj1l82qryXQxsbvkwtL24OR8pgIDRS9dYZqhgojuhD2D9j0JH/1UU78OyY17yIzxSctOkEdQqtVncXgwwKhJB+PCDsVtlUWWQbPgBu+MNnFskXx8qDFMwSAeAAAAAAAAABAnAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        )
    }

    // MARK: - EmptyInfo

    func testEncodingEmptyInfo() throws {
        let emptyInfo = EmptyInfo()

        var data = Data()
        try emptyInfo.serialize(to: &data)

        XCTAssertEqual(
            data.base64EncodedString(),
            ""
        )
    }

    // MARK: - Token2022

    func testEncodingToken2022MintState() throws {
        // Create an instance of Token2022MintState with the same values as in the decoding test
        var state = Token2022MintState(
            mintAuthorityOption: 0,
            mintAuthority: "LPF354oHyPWL7BoMRySPQLwfvUyqPBWpwC4R7atptrD",
            supply: 49_999_926_084_701,
            decimals: 5,
            isInitialized: true,
            freezeAuthorityOption: 0,
            freezeAuthority: nil,
            extensions: []
        )

        // Add an extension to the state
        let extensionState = TransferFeeConfigExtensionState(
            length: 108,
            transferFeeConfigAuthority: "11111111111111111111111111111111",
            withdrawWithHeldAuthority: "LPF354oHyPWL7BoMRySPQLwfvUyqPBWpwC4R7atptrD",
            withheldAmount: 2_531_431_991,
            olderTransferFee: .init(
                epoch: 530,
                maximumFee: 50_000_000_000_000,
                transferFeeBasisPoints: 300
            ),
            newerTransferFee: .init(
                epoch: 530,
                maximumFee: 50_000_000_000_000,
                transferFeeBasisPoints: 300
            )
        )
        state.extensions = [
            .init(
                type: .transferFeeConfig,
                state: extensionState
            ),
        ]

        // Serialize the state
        var data = Data()
        try state.serialize(to: &data)

        // Check if the serialized data matches the expected base64-encoded string
        XCTAssertEqual(
            data.base64EncodedString(),
            "AAAAAAT3LznRbp1toHmr0Mjv1bBjc6oSrtihgQu/PG0Sunz6XUTVg3ktAAAFAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAT3LznRbp1toHmr0Mjv1bBjc6oSrtihgQu/PG0Sunz6N5bilgAAAAASAgAAAAAAAAAgPYh5LQAALAESAgAAAAAAAAAgPYh5LQAALAE="
        )
    }

    func testEncodingToken2022MintState2() throws {
        // Mint FZYEgCWzzedxcmxYvGXSkMrj7TaA3bXoaEv6XMnwtLKh
        var state = Token2022MintState(
            mintAuthorityOption: 0,
            mintAuthority: "2a9H7uNfUxt7YdS5yH3ZEijdPqpeBtyq7JPtVyi6XKtk",
            supply: 8_151_890_602_662_552_490,
            decimals: 2,
            isInitialized: true,
            freezeAuthorityOption: 0,
            freezeAuthority: "2a9H7uNfUxt7YdS5yH3ZEijdPqpeBtyq7JPtVyi6XKtk",
            extensions: []
        )

        // Add TransferFeeConfigExtensionState
        let transferConfig = TransferFeeConfigExtensionState(
            length: 108,
            transferFeeConfigAuthority: "11111111111111111111111111111111",
            withdrawWithHeldAuthority: "11111111111111111111111111111111",
            withheldAmount: 1_299_782_865_324_245_038,
            olderTransferFee: .init(
                epoch: 489,
                maximumFee: 8_888_888_888_888_889_344,
                transferFeeBasisPoints: 300
            ),
            newerTransferFee: .init(
                epoch: 489,
                maximumFee: 8_888_888_888_888_889_344,
                transferFeeBasisPoints: 300
            )
        )

        // Add InterestBearingConfigExtensionState
        let interestBearingConfig = InterestBearingConfigExtensionState(
            length: 52,
            rateAuthority: "2a9H7uNfUxt7YdS5yH3ZEijdPqpeBtyq7JPtVyi6XKtk",
            initializationTimestamp: 1_692_005_389,
            preUpdateAverageRate: 0,
            lastUpdateTimestamp: 1_692_005_389,
            currentRate: 0
        )

        state.extensions = [
            .init(type: .transferFeeConfig, state: transferConfig),
            .init(type: .interestBearingConfig, state: interestBearingConfig),
            .init(type: .defaultAccountState, state: VecU8(length: UInt16(1), data: Data([1]))),
        ]

        // Serialize the state
        var data = Data()
        try state.serialize(to: &data)

        // Base64 encode the serialized data and compare with the expected value
        XCTAssertEqual(
            data.base64EncodedString(),
            "AAAAABdZNqd8UPqRoeBHXdhoEwzZNLf6UnDQ1UDsr4oXimfhquOLA1BVIXECAQAAAAAXWTanfFD6kaHgR13YaBMM2TS3+lJw0NVA7K+KF4pn4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALoDKJKHBCRLpAQAAAAAAAACQI15ZrVt7LAHpAQAAAAAAAACQI15ZrVt7LAEKADQAF1k2p3xQ+pGh4Edd2GgTDNk0t/pScNDVQOyviheKZ+EN9NlkAAAAAAAADfTZZAAAAAAAAAYAAQAB"
        )
    }

    func testEncodingTokenAccountState() throws {
        let accountState = Token2022AccountState(
            mint: "8nxJnGJDyvehdEHw4PgRc7ccJ1Zi134PhM2USK3WE8mS",
            owner: "E8E6GvyCpbGu7YSFxfhTXGx6SW4VhzVmxWh3gbrgXZNd",
            lamports: 0,
            delegateOption: 0,
            delegate: nil,
            isInitialized: true,
            isFrozen: false,
            state: 1,
            isNativeOption: 0,
            rentExemptReserve: nil,
            isNativeRaw: 0,
            isNative: false,
            delegatedAmount: 0,
            closeAuthorityOption: 0,
            extensions: [
                .init(
                    type: .immutableOwner,
                    state: VecU8<UInt16>(length: 0, data: Data())
                ),
            ]
        )

        // Serialize the state
        var data = Data()
        try accountState.serialize(to: &data)

        // Base64 encode the serialized data and compare with the expected value
        XCTAssertEqual(
            data.base64EncodedString(),
            "c8d675Tc8/enuGEbVogbaWoW6iY9JFkJIswLnf/gvCXDAcw04n4gWtOj5P12Rb7RAxY9RRwFQOwFWCWPS3OnJgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgcAAAA="
        )
    }
}
