import XCTest
@testable import SolanaSwift

class APIClientExtensionsTests: XCTestCase {
    let endpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )

    func testCheckAccountValidation() async throws {
        let mock = NetworkManagerMock1()

        mock.prepare(name: "checkAccountValidation1")
        let apiClient = BaseAPIClientMock(endpoint: endpoint, networkManager: mock)
        // TODO:
        // funding SOL address
        let isValid1 = try await apiClient
            .checkAccountValidation(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(isValid1, true)

        mock.prepare(name: "checkAccountValidation2")
        // no funding SOL address
        let isValid2 = try await apiClient
            .checkAccountValidation(account: "HnXJX1Bvps8piQwDYEYC6oea9GEkvQvahvRj3c97X9xr")
        XCTAssertEqual(isValid2, false)

        mock.prepare(name: "checkAccountValidation3")
        // token address
        let isValid3 = try await apiClient
            .checkAccountValidation(account: "8J5wZ4Lo7QSwFWwBfWsWUgsbH4Jr44RFsEYj6qFdXYhM")
        XCTAssertEqual(isValid3, true)
    }

    func testFindSPLTokenDestinationAddress() async throws {
        // TODO:
        // USDC
        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        let destination = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let apiClient = BaseAPIClientMock(endpoint: endpoint)
        let result = try await apiClient.findSPLTokenDestinationAddress(
            mintAddress: mintAddress,
            destinationAddress: destination,
            tokenProgramId: TokenProgram.id
        )
        XCTAssertEqual(result.destination, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
        XCTAssertEqual(result.isUnregisteredAsocciatedToken, false)
    }

    func testCheckIfAssociatedTokenAccountExists() async throws {
        let apiClient = BaseAPIClientMock(endpoint: endpoint)
        let exist = try await apiClient.checkIfAssociatedTokenAccountExists(
            owner: "9sdwzJWooFrjNGVX6GkkWUG9GyeBnhgJYqh27AsPqwbM",
            mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            tokenProgramId: TokenProgram.id
        )
        XCTAssertTrue(exist)

        let exist2 = try await apiClient.checkIfAssociatedTokenAccountExists(
            owner: "9sdwzJWooFrjNGVX6GkkWUG9GyeBnhgJYqh27AsPqwbM",
            mint: "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk",
            tokenProgramId: TokenProgram.id
        )
        XCTAssertFalse(exist2)
    }

    func testGetAccountInfoThrowable() async throws {
        let mock = NetworkManagerMock1()
        mock.prepare(name: "checkAccountValidation2")
        let apiClient = BaseAPIClientMock(endpoint: endpoint, networkManager: mock)

        do {
            let _: BufferInfo<TokenAccountState> = try await apiClient
                .getAccountInfoThrowable(account: "djfijijasdf")
        } catch {
            XCTAssertTrue(error.isEqualTo(.couldNotRetrieveAccountInfo))
        }
    }
}

class NetworkManagerMock1: NetworkManager {
    private let json = [
        "checkAccountValidation1": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":134252104},\"value\":{\"data\":[\"\",\"base64\"],\"executable\":false,\"lamports\":9984180,\"owner\":\"11111111111111111111111111111111\",\"rentEpoch\":310}},\"id\":\"943C6E03-2B44-4BDB-95EB-DEE2002D4475\"}\n",
        "checkAccountValidation2": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":134252142},\"value\":null},\"id\":\"0F5D1C45-2438-4891-BCEF-3E1D0589DAD8\"}\n",
        "checkAccountValidation3": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":134252168},\"value\":{\"data\":[\"\",\"base64\"],\"executable\":false,\"lamports\":368294,\"owner\":\"11111111111111111111111111111111\",\"rentEpoch\":310}},\"id\":\"1F0F4225-3577-4741-A4EA-13E55AB4A976\"}\n",
    ]

    func prepare(name: String) {
        data = json[name]!
    }

    private var data: String!

    func requestData(request _: URLRequest) async throws -> Data {
        data.data(using: .utf8)!
    }
}

class BaseAPIClientMock: JSONRPCAPIClient {
    override init(endpoint: APIEndPoint, networkManager: NetworkManager = URLSession(configuration: .default)) {
        super.init(endpoint: endpoint, networkManager: networkManager)
    }

    func getTokenAccountsByOwner(
        pubkey _: String,
        params _: OwnerInfoParams? = nil,
        configs _: RequestConfiguration? = nil
    ) async throws -> [TokenAccount<TokenAccountState>] {
        let json =
            "[{\"account\":{\"data\":[\"ppdSk884LShYnHoHm7XiDlZ28iJVm9BHPgrAEfxU44AJ7HiGa7fztefqNjU2MSBOZ3HPlRmb0eAXj0bEanmyfAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\"base64\"],\"executable\":false,\"lamports\":2039280,\"owner\":\"So11111111111111111111111111111111111111112\",\"rentEpoch\":309},\"pubkey\":\"9bNJ7AF8w1Ms4BsqpqbUPZ16vCSePYJpgSBUTRqd8ph4\"}]"
        let decoder = try JSONDecoder().decode(
            [TokenAccount<TokenAccountState>].self,
            from: json.data(using: .utf8)!
        )
        return decoder
    }

    override func getMultipleAccounts<T: BufferLayout>(
        pubkeys _: [String],
        commitment _: Commitment
    ) async throws -> [BufferInfo<T>?] {
        let json =
            "{\"context\":{\"slot\":132420615},\"value\":[{\"data\":[\"APoAh5MDAAAAAAKLjuya35R64GfrOPbupmMcxJ1pmaH2fciYq9DxSQ88FioLlNul6FnDNF06/RKhMFBVI8fFQKRYcqukjYZitosKxZBjjg9hLR2AsDm2e/itloPtlrPeVDPIVdnO4+dmM2JiSZHdhsj7+Fn94OTNte9elt1ek0p487C2fLrFA9CvUPerjZvfP97EqlF9OXbPSzaGJzdmfWhk4jRnThsg5scAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAObFpMVhxY3CRrzEcywhYTa4a4SsovPp4wKPRTbTJVtzAfQBZAAAAABDU47UFrGnHMTsb0EaE1TBoVQGvCIHKJ4/EvpK3zvIfwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACsWQY44PYS0dgLA5tnv4rZaD7Zaz3lQzyFXZzuPnZjMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\",\"base64\"],\"executable\":false,\"lamports\":1345194,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":306}]}"
        let decoder = try JSONDecoder()
            .decode(Rpc<[BufferInfo<TokenMintState>]>.self, from: json.data(using: .utf8)!) as! Rpc<[BufferInfo<T>]>
        return decoder.value
    }

    // MARK: - Get account Info

    private var getAccountInfoResponses = [
        "1": "{\"context\":{\"slot\":134254318},\"value\":{\"data\":[\"\",\"base64\"],\"executable\":false,\"lamports\":9984180,\"owner\":\"11111111111111111111111111111111\",\"rentEpoch\":310}}",
        "2": #"{"context":{"slot":134254375},"value":{"data":["xvp6877brTo9ZfNqq8l0MbG75MLS9uDkfKYCA0UvXWEn97kEVYkyppO43UtuZxDeKV73hCs+rPNfzL6PmRAKxebSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"],"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":310}}"#,
        "3": #"{"context":{"slot":135918577},"value":null}"#,
    ]
    override func getAccountInfo<T: BufferLayout>(account: String) async throws -> BufferInfo<T>? {
        var accountInfoResponseJSON: String = getAccountInfoResponses["2"]!
        if account == "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG" {
            accountInfoResponseJSON = getAccountInfoResponses["1"]!
        } else if account == "HnXJX1Bvps8piQwDYEYC6oea9GEkvQvahvRj3c97X9xr" {
            accountInfoResponseJSON = getAccountInfoResponses["3"]!
        }
        do {
            return try JSONDecoder()
                .decode(Rpc<BufferInfo<T>?>.self, from: accountInfoResponseJSON.data(using: .utf8)!)
                .value
        } catch is BinaryReaderError {
            throw APIClientError.couldNotRetrieveAccountInfo
        }
    }
}
