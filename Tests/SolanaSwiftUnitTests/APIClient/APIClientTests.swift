import XCTest
@testable import SolanaSwift

class APIClientTests: XCTestCase {
    let endpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )

    func testGetBlock() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBlockHeight"]!)
        let apiClient = SolanaSwift.JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getBlockHeight()
        XCTAssertEqual(result, 119_396_901)
    }

    func testGetAccountInfo() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getAccountInfo"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: BufferInfo<TokenAccountState>? = try! await apiClient
            .getAccountInfo(account: "HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk")
        XCTAssert(result?.owner == "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        XCTAssert(result?.lamports == 2_039_280)
        XCTAssert(result?.rentEpoch == 304)
    }

    func testGetAccountInfoError() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getAccountInfo_2"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        do {
            let _: BufferInfo<TokenAccountState>? = try await apiClient
                .getAccountInfo(account: "HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk")
        } catch let error as APIClientError {
            XCTAssertTrue(error == .couldNotRetrieveAccountInfo)
        } catch {
            XCTAssertTrue(false)
        }
    }

    func testGetConfirmedBlocksWithLimit() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getConfirmedBlocksWithLimit"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: [UInt64] = try! await apiClient.getConfirmedBlocksWithLimit(startSlot: 131_421_172, limit: 10)
        XCTAssert(result.count == 10)
        XCTAssert(result[0] == 131_421_172)
        XCTAssert(result[1] == 131_421_173)
        XCTAssert(result[9] == 131_421_181)
    }

    func testBatchRequest() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["batch1"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let req1: JSONRPCAPIClientRequest<AnyDecodable> = JSONRPCAPIClientRequest(method: "getBlockHeight", params: [])
        let req2: JSONRPCAPIClientRequest<AnyDecodable> = JSONRPCAPIClientRequest(method: "getConfirmedBlocksWithLimit",
                                                                                  params: [10])
        let response = try await apiClient.batchRequest(with: [req1, req2])
        XCTAssert(response.count == 2)
        XCTAssert(response[0].result != nil)
        XCTAssert(response[1].result != nil)
    }

    func testBatch2Request() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["batch2"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let req1: JSONRPCAPIClientRequest<AnyDecodable> = JSONRPCAPIClientRequest(method: "getAccountInfo", params: [])
        let req2: JSONRPCAPIClientRequest<AnyDecodable> = JSONRPCAPIClientRequest(method: "getBalance", params: [])
        let response = try await apiClient.batchRequest(with: [req1, req2])
        XCTAssert(response.count == 2)
        XCTAssert(response[0].result != nil)
        XCTAssert(response[1].result != nil)
    }

    func testBatch3Request() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["batch3"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let response: [Rpc<UInt64>?] = try await apiClient.batchRequest(method: "getBalance", params: [[], [], []])
        XCTAssert(response.count == 3)
        XCTAssertEqual(response[0]?.value, 1)
        XCTAssertEqual(response[1]?.value, 2)
        XCTAssertEqual(response[2]?.value, 3)
    }

    func testBatch4Request() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["batch4"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let response: [Rpc<UInt64>?] = try await apiClient.batchRequest(method: "getBalance", params: [[], [], []])
        XCTAssert(response.count == 3)
        XCTAssertEqual(response[0]?.value, 1)
        XCTAssertEqual(response[1]?.value, nil)
        XCTAssertEqual(response[2]?.value, nil)
    }

    func testSingleBatchRequest() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["singleBatch"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let response: [Rpc<UInt64>?] = try await apiClient.batchRequest(method: "getBalance", params: [[]])
        XCTAssert(response.count == 1)
        XCTAssertEqual(response[0]?.value, 1)
    }

    func testEmptyBatchRequest() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["emptySingleBatch"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let response: [Rpc<UInt64>?] = try await apiClient.batchRequest(method: "getBalance", params: [])
        XCTAssert(response.isEmpty)
    }

    func testGetBalance() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBalance"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: UInt64 = try! await apiClient.getBalance(account: "", commitment: "recent")
        XCTAssert(result == 123_456)
    }

    func testGetBalanceSingle() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBalance_1"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: UInt64 = try! await apiClient.getBalance(account: "", commitment: "recent")
        XCTAssert(result == 123_456)
    }

    func testGetBlockCommitment() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBlockCommitment"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: BlockCommitment = try! await apiClient.getBlockCommitment(block: 119_396_901)
        XCTAssert(result.totalStake == 394_545_529_101_613_343)
    }

    func testGetBlockTime() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBlockTime"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: Date = try! await apiClient.getBlockTime(block: 119_396_901)
        XCTAssert(result == Date(timeIntervalSince1970: TimeInterval(1_644_034_719)))
    }

    func testGetClusterNodes() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getClusterNodes"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: [ClusterNodes] = try! await apiClient.getClusterNodes()
        XCTAssert(result.count == 1)
        XCTAssert(result[0].pubkey == "57UtuDwoCurTTWySMeV5MiopvDWvK2QeLWu47biQjjLJ")
    }

    func testGetConfirmedBlock() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getConfirmedBlock"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
//        let result: ConfirmedBlock = try! await apiClient.getConfirmedBlock(slot: 131647712, encoding: "json")
//        XCTAssert(result.count == 1)
//        XCTAssert(result[0].pubkey == "57UtuDwoCurTTWySMeV5MiopvDWvK2QeLWu47biQjjLJ")
    }

    func testGetConfirmedSignaturesForAddress() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getConfirmedSignaturesForAddress"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: [String] = try! await apiClient.getConfirmedSignaturesForAddress(
            account: "",
            startSlot: 131_647_712,
            endSlot: 131_647_713
        )
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], "1")
        XCTAssertEqual(result[1], "2")
        XCTAssertEqual(result[2], "3")
    }

    func testGetTransaction() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getTransaction"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: TransactionInfo = try! await apiClient
            .getTransaction(
                transactionSignature: "3kNdBJeLhLQX8FsyHjAKrtfnq5L6NwjQ3Nm96Wyx1pk5GFicbE47mpu2CtiU8krZDVDk7Di5ELAoKtw91Yj89bQ"
            )
        XCTAssertNotNil(result)
    }

    func testGetEpochInfo() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getEpochInfo"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getEpochInfo()
        XCTAssertNotNil(result)
        XCTAssertEqual(result.absoluteSlot, 131_686_768)
        XCTAssertEqual(result.epoch, 304)
    }

    func testGetFees() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getFees"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getFees(commitment: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result.lastValidSlot, 131_770_381)
        XCTAssertEqual(result.feeCalculator?.lamportsPerSignature, 5000)
        XCTAssertEqual(result.blockhash, "7jvToPQ4ASj3xohjM117tMqmtppQDaWVADZyaLFnytFr")
    }
    
    func testGetFeeForMessage() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getFeeForMessage"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getFeeForMessage(
            message: Data([0x01]).base64EncodedString(),
            commitment: nil
        )
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 1337)
    }

    func testGetMinimumBalanceForRentExemption() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getMinimumBalanceForRentExemption"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getMinimumBalanceForRentExemption(span: 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 890_880)
    }

    func testGetRecentBlockhash() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getRecentBlockhash"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getRecentBlockhash(commitment: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1")
    }
    
    func testGetLatestBlockhash() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getLatestBlockhash"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getLatestBlockhash(commitment: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1")
    }

    func testGetSignatureStatusses() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getSignatureStatuses"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getSignatureStatuses(signatures: [])
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0]?.confirmations, 10)
        XCTAssertTrue(result[1] == nil)
    }

    func testGetMultipleAccounts() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getMultipleAccounts"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: [BufferInfo<TokenMintState>?] = try await apiClient
            .getMultipleAccounts(pubkeys: ["DkZzno16JLXYda4eHZzM9J8Vxet9StJJ5mimrtjbK5V3"], commitment: "confirm")
        XCTAssertNotNil(result)
    }

    func testGetMultipleMintDatas() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getMultipleMintDatas"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try await apiClient
            .getMultipleMintDatas(
                mintAddresses: [
                    "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                    "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
                ],
                commitment: "confirm",
                mintType: TokenMintState.self
            )
        XCTAssertNotNil(result)

        // usdc
        let usdc = result["EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"]!
        XCTAssertEqual(usdc.mintAuthority?.base58EncodedString, "2wmVCSfPxGPjrnMMn7rchp4uaeoTqN39mXFC2zhPdri9")
        XCTAssertEqual(usdc.decimals, 6)
        XCTAssertEqual(usdc.freezeAuthority?.base58EncodedString, "3sNBr7kMccME5D55xNgsmYpZnzPgP2g12CixAajXypn6")

        // usdt
        let usdt = result["Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"]!
        XCTAssertEqual(usdt.mintAuthority?.base58EncodedString, "Q6XprfkF8RQQKoQVG33xT88H7wi8Uk1B1CC7YAs69Gi")
        XCTAssertEqual(usdt.decimals, 6)
        XCTAssertEqual(usdt.freezeAuthority?.base58EncodedString, "Q6XprfkF8RQQKoQVG33xT88H7wi8Uk1B1CC7YAs69Gi")
    }

    func testGetSignaturesForAddress() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getSignatureForAddress"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try await apiClient
            .getSignaturesForAddress(address: "HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(
            result.first?.signature,
            "31vx5MqPX1cxzfwGEWjaHuHnmSo9vwrtwBNXyTJjxtfbzkzqWr4sY8JE5Mq5ZZK7aokps9UjhHcNuJTF82FP2ekM"
        )
    }

    func testSimulateTx() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["simulateTransaction"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        do {
            let _ = try await apiClient.simulateTransaction(transaction: "")
        } catch {
            XCTAssertEqual(error as? APIClientError, APIClientError.transactionSimulationError(logs: []))
        }
    }

    func testGetTokenAccountsByOwner() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getTokenAccountsByOwner"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try await apiClient.getTokenAccountsByOwner(
            pubkey: "fjohsw9j8aBJaEE5ddzHk3AgMjdbQSXrMoPGrepNHrB",
            params: .init(mint: nil, programId: TokenProgram.id.base58EncodedString),
            configs: .init(encoding: "base64"),
            decodingTo: Token2022AccountState.self
        )
        XCTAssertEqual(result.first?.account.owner, TokenProgram.id.base58EncodedString)
    }

    func testGetToken2022AccountsByOwner() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getToken2022AccountsByOwner"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try await apiClient.getTokenAccountsByOwner(
            pubkey: "fjohsw9j8aBJaEE5ddzHk3AgMjdbQSXrMoPGrepNHrB",
            params: .init(mint: nil, programId: TokenProgram.id.base58EncodedString),
            configs: .init(encoding: "base64"),
            decodingTo: Token2022AccountState.self
        )
        XCTAssertEqual(result.first?.account.owner, Token2022Program.id.base58EncodedString)
        XCTAssertEqual(result.first?.pubkey, "43W7QvyKr5hJhFRhvteb7VbsLdwGQG3VZ2fRYVcw5yFN")
    }
    
    func testGetTokenLargestAccounts() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getTokenLargestAccounts"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try await apiClient.getTokenLargestAccounts(
            pubkey: "3wyAj7Rt1TWVPZVteFJPLa26JmLvdb1CAKEFZm3NY75E"
        )
        XCTAssertEqual(result.first?.address, "FYjHNoFtSQ5uijKrZFyYAxvEr87hsKXkXcxkcmkBAf4r")
        XCTAssertEqual(result.first?.amount, "771")
        XCTAssertEqual(result.first?.decimals, 2)
        XCTAssertEqual(result.first?.uiAmount, 7.71)

    }

    func testSendTransactionError1() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["sendTransactionError1"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        do {
            _ = try await apiClient.sendTransaction(transaction: "ijaisjdfi")
        } catch let APIClientError.responseError(errorDetail) {
            XCTAssertEqual(
                errorDetail,
                .init(code: -32003, message: "Transaction precompile verification failure InvalidAccountIndex",
                      data: nil)
            )
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testGetTokenAccountBalance() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getTokenAccountBalance"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try await apiClient.getTokenAccountBalance(
            pubkey: "FdiTt7XQ94fGkgorywN1GuXqQzmURHCDgYtUutWRcy4q",
            commitment: nil
        )
        XCTAssertEqual(result.amount, "491717631607")
        XCTAssertEqual(result.decimals, 9)
        XCTAssertEqual(result.uiAmount, 491.717631607)
        XCTAssertEqual(result.uiAmountString, "491.717631607")
    }

    func testGenericRequest1() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getHealth"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: String = try await apiClient.request(method: "getHealth")
        XCTAssertEqual(result, "ok")
    }

    func testGenericRequest2() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getHealthError"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        do {
            let _: String = try await apiClient.request(method: "getHealth")
        } catch {
            XCTAssertEqual(
                error as! APIClientError,
                .responseError(.init(code: -32005, message: "Node is unhealthy",
                                     data: .init(logs: nil, numSlotsBehind: nil)))
            )
        }
    }
}

// MARK: - Mocks

private var NetworkManagerMockJSON = [
    "getBlockHeight": "{\"jsonrpc\":\"2.0\",\"result\":119396901,\"id\":\"45ECD42F-D53C-4A02-8621-52D88840FFC1\"}\n",
    "getAccountInfo": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131421172},\"value\":{\"data\":[\"xvp6877brTo9ZfNqq8l0MbG75MLS9uDkfKYCA0UvXWF9P8kKbTPTsQZqMMzOan8jwyOl0jQaxrCPh8bU1ysTa96DDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\"base64\"],\"executable\":false,\"lamports\":2039280,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":304}},\"id\":\"6B1C0860-44BE-4FA9-9F57-CB14BC7636BB\"}\n",
    "getAccountInfo_2": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":132713905},\"value\":{\"data\":[\"\",\"base64\"],\"executable\":false,\"lamports\":14092740,\"owner\":\"11111111111111111111111111111111\",\"rentEpoch\":307}},\"id\":\"49220446-E30F-4EEA-9D90-7CFA2A620D9A\"}\n",
    "getConfirmedBlocksWithLimit": "{\"jsonrpc\":\"2.0\",\"result\":[131421172,131421173,131421174,131421175,131421176,131421177,131421178,131421179,131421180,131421181],\"id\":\"A5A1EB9D-CC05-496F-8582-2B8D610859DB\"}\n",
    "batch1": "[{\"jsonrpc\":\"2.0\",\"result\":119396901,\"id\":\"45ECD42F-D53C-4A02-8621-52D88840FFC1\"},{\"jsonrpc\":\"2.0\",\"result\":[131421172,131421173,131421174,131421175,131421176,131421177,131421178,131421179,131421180,131421181],\"id\":\"A5A1EB9D-CC05-496F-8582-2B8D610859DB\"}]",
    "batch2": "[{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131421172},\"value\":{\"data\":[\"xvp6877brTo9ZfNqq8l0MbG75MLS9uDkfKYCA0UvXWF9P8kKbTPTsQZqMMzOan8jwyOl0jQaxrCPh8bU1ysTa96DDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\"base64\"],\"executable\":false,\"lamports\":2039280,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":304}},\"id\":\"6B1C0860-44BE-4FA9-9F57-CB14BC7636BB\"},{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":123456},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"}]",
    "batch3": "[{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":1},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"},{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":2},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"}, {\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":3},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"}]",
    "batch4": "[{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":1},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"},{\"jsonrpc\":\"2.0\",\"result\":119396901,\"id\":\"45ECD42F-D53C-4A02-8621-52D88840FFC1\"}, {\"jsonrpc\":\"2.0\",\"error\":{\"code\":-32005,\"message\":\"Node is unhealthy\",\"data\":{}},\"id\":1}]",
    "singleBatch": "[{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":1},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"}]",
    "emptySingleBatch": "",
    "getBalance": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":123456},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"}\n",
    "getBalance_1": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":123456},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"}\n",
    "getBlockCommitment": "{\"jsonrpc\":\"2.0\",\"result\":{\"commitment\":null,\"totalStake\":394545529101613343},\"id\":\"BB79B171-937B-4EB1-9D13-EC961F186D75\"}\n",
    "getBlockTime": "{\"jsonrpc\":\"2.0\",\"result\":1644034719,\"id\":\"F944107E-4105-4B0A-8049-3BA73C1E4067\"}\n",
    "getClusterNodes": "{\"jsonrpc\":\"2.0\",\"result\":[{\"featureSet\":1070292356,\"gossip\":\"145.40.93.113:8001\",\"pubkey\":\"57UtuDwoCurTTWySMeV5MiopvDWvK2QeLWu47biQjjLJ\",\"rpc\":null,\"shredVersion\":8573,\"tpu\":\"145.40.93.113:8004\",\"version\":\"1.9.14\"}],\"id\":\"356C6D54-84EA-48D0-B13F-D5667A5DC750\"}\n",
    "getConfirmedBlock": "{\"jsonrpc\":\"2.0\",\"id\":\"2BAC562A-33FE-45E4-B49E-9008476A4EA8\",\"result\":{\"blockHeight\":119407643,\"blockTime\":1651131785,\"blockhash\":\"9iYcQnofTuZwwtuG4bbpoV8MMsihxfVT5eyBjzJRTHDc\",\"parentSlot\":131647711,\"previousBlockhash\":\"FkSQpuhgLMVRwGWPzw3zjXq3oXUMcNogfwAkgNC9KWy7\",\"rewards\":[{\"commission\":null,\"lamports\":-11967,\"postBalance\":1357161,\"pubkey\":\"DkZzno16JLXYda4eHZzM9J8Vxet9StJJ5mimrtjbK5V3\",\"rewardType\":\"Rent\"}],\"transactions\":[{\"meta\":{\"err\":{\"InstructionError\":[0,{\"Custom\":0}]},\"fee\":5000,\"innerInstructions\":[],\"logMessages\":[\"Program Vote111111111111111111111111111111111111111 invoke [1]\",\"Program Vote111111111111111111111111111111111111111 failed: custom program error: 0x0\"],\"postBalances\":[2055275200,8808836473,143487360,1169280,1],\"postTokenBalances\":[],\"preBalances\":[2055280200,8808836473,143487360,1169280,1],\"preTokenBalances\":[],\"rewards\":[],\"status\":{\"Err\":{\"InstructionError\":[0,{\"Custom\":0}]}}},\"transaction\":{\"message\":{\"accountKeys\":[\"tJ9HBhHM436kZ6udx8nBVEAsGaVCoy2Mw7K1U63bLyM\",\"85F9XWHuJ19iCgARo8P6E7yUT1mucqRHuKK9zu359hqR\",\"SysvarS1otHashes111111111111111111111111111\",\"SysvarC1ock11111111111111111111111111111111\",\"Vote111111111111111111111111111111111111111\"],\"header\":{\"numReadonlySignedAccounts\":0,\"numReadonlyUnsignedAccounts\":3,\"numRequiredSignatures\":1},\"instructions\":[{\"accounts\":[1,2,3,0],\"data\":\"rTDbDtm67JPw9WoF6jKWCCCH3zrLe1haxxDLEMTJB5TjB897zfAoiwVXkVq1HowpRBbRLZGfk4e4637rpxEEkzi6a4EWHBS9CqwLxXSP\",\"programIdIndex\":4}],\"recentBlockhash\":\"FddpWyVFoazKW4mD8GoghnMx8g18vpQhHGrcLwuRdRUs\"},\"signatures\":[\"2AqCkYUKCiv1zYEXBESaYCWeLUv2BwzoCXLrovhsXBu7Ss5XC6kqrBCGEguJbXt3BssmBurrwL54ZdYXwB4YYLrX\"]}}]}}\n",
    "getConfirmedSignaturesForAddress": "{\"jsonrpc\":\"2.0\",\"result\":[\"1\",\"2\",\"3\"],\"id\":\"71F4389A-854F-4738-A869-CC455598C11C\"}\n",
    "getTransaction": "{\"jsonrpc\":\"2.0\",\"result\":{\"blockTime\":1647268521,\"meta\":{\"err\":null,\"fee\":10000,\"innerInstructions\":[{\"index\":0,\"instructions\":[{\"accounts\":[\"11111111111111111111111111111111\",\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\",\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"GyvYVTFgrfCmkE4pHzw44xyELoaivkYDeP2P1TmeqFSs\",\"11111111111111111111111111111111\",\"HSqVcxpDaZzwkHxreLisDtR9bQsLaTCMzMATFVhDoeNe\",\"fjohsw9j8aBJaEE5ddzHk3AgMjdbQSXrMoPGrepNHrB\"],\"data\":\"12B5oCT463JwdTFKK1Xm3F2xL1NoDdJQGeMuRKappf2aRUXjfSUEeEPQYcW1cMis8VD\",\"programId\":\"namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX\"},{\"parsed\":{\"info\":{\"destination\":\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"lamports\":2227200,\"source\":\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\"},\"type\":\"transfer\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"account\":\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"space\":192},\"type\":\"allocate\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"account\":\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"owner\":\"namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX\"},\"type\":\"assign\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"destination\":\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"lamports\":974400,\"source\":\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\"},\"type\":\"transfer\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"account\":\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"space\":12},\"type\":\"allocate\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"account\":\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"owner\":\"B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog\"},\"type\":\"assign\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"}]}],\"logMessages\":[\"Program B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog invoke [1]\",\"Program namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX invoke [2]\",\"Program log: Entrypoint\",\"Program log: Beginning processing\",\"Program log: Instruction unpacked\",\"Program log: Instruction: Create\",\"Program 11111111111111111111111111111111 invoke [3]\",\"Program 11111111111111111111111111111111 success\",\"Program 11111111111111111111111111111111 invoke [3]\",\"Program 11111111111111111111111111111111 success\",\"Program 11111111111111111111111111111111 invoke [3]\",\"Program 11111111111111111111111111111111 success\",\"Program namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX consumed 20584 of 191569 compute units\",\"Program namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX success\",\"Program 11111111111111111111111111111111 invoke [2]\",\"Program 11111111111111111111111111111111 success\",\"Program 11111111111111111111111111111111 invoke [2]\",\"Program 11111111111111111111111111111111 success\",\"Program 11111111111111111111111111111111 invoke [2]\",\"Program 11111111111111111111111111111111 success\",\"Program B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog consumed 41308 of 200000 compute units\",\"Program B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog success\"],\"postBalances\":[443590671,100000000,2227200,974400,1,1141440,1009200,0,71353866,1001293440],\"postTokenBalances\":[],\"preBalances\":[446802271,100000000,0,0,1,1141440,1009200,0,71353866,1001293440],\"preTokenBalances\":[],\"rewards\":[],\"status\":{\"Ok\":null}},\"slot\":124916513,\"transaction\":{\"message\":{\"accountKeys\":[{\"pubkey\":\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\",\"signer\":true,\"writable\":true},{\"pubkey\":\"fjohsw9j8aBJaEE5ddzHk3AgMjdbQSXrMoPGrepNHrB\",\"signer\":true,\"writable\":false},{\"pubkey\":\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"signer\":false,\"writable\":true},{\"pubkey\":\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"signer\":false,\"writable\":true},{\"pubkey\":\"11111111111111111111111111111111\",\"signer\":false,\"writable\":false},{\"pubkey\":\"namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX\",\"signer\":false,\"writable\":false},{\"pubkey\":\"SysvarRent111111111111111111111111111111111\",\"signer\":false,\"writable\":false},{\"pubkey\":\"GyvYVTFgrfCmkE4pHzw44xyELoaivkYDeP2P1TmeqFSs\",\"signer\":false,\"writable\":false},{\"pubkey\":\"HSqVcxpDaZzwkHxreLisDtR9bQsLaTCMzMATFVhDoeNe\",\"signer\":false,\"writable\":false},{\"pubkey\":\"B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog\",\"signer\":false,\"writable\":false}],\"instructions\":[{\"accounts\":[\"11111111111111111111111111111111\",\"namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX\",\"SysvarRent111111111111111111111111111111111\",\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\",\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"GyvYVTFgrfCmkE4pHzw44xyELoaivkYDeP2P1TmeqFSs\",\"11111111111111111111111111111111\",\"HSqVcxpDaZzwkHxreLisDtR9bQsLaTCMzMATFVhDoeNe\",\"fjohsw9j8aBJaEE5ddzHk3AgMjdbQSXrMoPGrepNHrB\"],\"data\":\"1RxqKETLww2ut33YFYhShTyYLvJhfTf7WPWUiLK5XGL58wSWFHKvt4YJUXDoL8JFGkzGzVbP\",\"programId\":\"B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog\"}],\"recentBlockhash\":\"U9hxJeX42n3rEG8FJychJpeQucN1QqKoMb56GigUdrm\"},\"signatures\":[\"3kNdBJeLhLQX8FsyHjAKrtfnq5L6NwjQ3Nm96Wyx1pk5GFicbE47mpu2CtiU8krZDVDk7Di5ELAoKtw91Yj89bQ\",\"4w7p5ZvAgzZ7THtxKxRbFqAuD69Uk82tnbuz9BT822MRiGZUypAkok8u4sTPizjHmjx65vpGcw4SwFXu8hgafCoh\"]}},\"id\":\"03194776-D570-4887-8A2A-84007EE79A66\"}\n",
    "getEpochInfo": "{\"jsonrpc\":\"2.0\",\"result\":{\"absoluteSlot\":131686768,\"blockHeight\":119443373,\"epoch\":304,\"slotIndex\":358768,\"slotsInEpoch\":432000,\"transactionCount\":71271072342},\"id\":\"AE699DFA-84E8-495C-8B06-F30DDFA6C56D\"}\n",
    "getFees": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131770081},\"value\":{\"blockhash\":\"7jvToPQ4ASj3xohjM117tMqmtppQDaWVADZyaLFnytFr\",\"feeCalculator\":{\"lamportsPerSignature\":5000},\"lastValidBlockHeight\":119512694,\"lastValidSlot\":131770381}},\"id\":\"3FF1AACE-812A-4106-8C34-6EF66237673C\"}\n",
    "getFeeForMessage": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":5068},\"value\":1337},\"id\": \"FD486F1A-82F6-4295-B0B1-9E8905239A67\"}",
    "getMinimumBalanceForRentExemption": "{\"jsonrpc\":\"2.0\",\"result\":890880,\"id\":\"25423C5F-2FF3-4134-8CB3-9090BFCB2CE3\"}\n",
    "getRecentBlockhash": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131780453},\"value\":{\"blockhash\":\"63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1\",\"feeCalculator\":{\"lamportsPerSignature\":5000}}},\"id\":\"21D61199-F235-4CC9-9BE6-06745D3AC69E\"}\n",
    "getLatestBlockhash": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131780453},\"value\":{\"blockhash\":\"63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1\",\"lastValidBlockHeight\":3090}},\"id\":\"9C1116F2-688C-4A71-A7E4-FB436D9D9E44\"}\n",
    "getMultipleAccounts": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":132420615},\"value\":[{\"data\":[\"APoAh5MDAAAAAAKLjuya35R64GfrOPbupmMcxJ1pmaH2fciYq9DxSQ88FioLlNul6FnDNF06/RKhMFBVI8fFQKRYcqukjYZitosKxZBjjg9hLR2AsDm2e/itloPtlrPeVDPIVdnO4+dmM2JiSZHdhsj7+Fn94OTNte9elt1ek0p487C2fLrFA9CvUPerjZvfP97EqlF9OXbPSzaGJzdmfWhk4jRnThsg5scAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAObFpMVhxY3CRrzEcywhYTa4a4SsovPp4wKPRTbTJVtzAfQBZAAAAABDU47UFrGnHMTsb0EaE1TBoVQGvCIHKJ4/EvpK3zvIfwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACsWQY44PYS0dgLA5tnv4rZaD7Zaz3lQzyFXZzuPnZjMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\",\"base64\"],\"executable\":false,\"lamports\":1345194,\"owner\":\"617jbWo616ggkDxvW1Le8pV38XLbVSyWY8ae6QUmGBAU\",\"rentEpoch\":306}]},\"id\":\"D5BCACBB-3CE7-44D6-8F66-C57470A90440\"}\n",
    "getMultipleMintDatas": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":132426903},\"value\":[{\"data\":[\"AQAAABzjWe1aAS4E+hQrnHUaHF6Hz9CgFhuchf/TG3jN/Nj2dbn7oe7/EAAGAQEAAAAqnl7btTwEZ5CY/3sSZRcUQ0/AjFYqmjuGEQXmctQicw==\",\"base64\"],\"executable\":false,\"lamports\":122356825965,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":306},{\"data\":[\"AQAAAAXqnPFs5BGY8aSZN8iMNwqU1K//ibW6y470XmMku3j3J0UE6/G2BgAGAQEAAAAF6pzxbOQRmPGkmTfIjDcKlNSv/4m1usuO9F5jJLt49w==\",\"base64\"],\"executable\":false,\"lamports\":23879870146,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":306}]},\"id\":\"65766E4D-F678-489A-943B-8D70B5C6F1ED\"}\n",
    "simulateTransaction": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":132581497},\"value\":{\"accounts\":null,\"err\":\"AccountNotFound\",\"logs\":[],\"unitsConsumed\":0}},\"id\":\"3916EC69-2924-40E7-8843-8CBA8C6DB14C\"}\n",
    "getSignatureStatuses": #"{"jsonrpc":"2.0","result":{"context":{"slot":82},"value":[{"slot":72,"confirmations":10,"err":null,"status":{"Ok":null},"confirmationStatus":"confirmed"},null]},"id":1}"#,
    "getSignatureForAddress": "{\"jsonrpc\":\"2.0\",\"result\":[{\"blockTime\":1652351736,\"confirmationStatus\":\"finalized\",\"err\":null,\"memo\":null,\"signature\":\"31vx5MqPX1cxzfwGEWjaHuHnmSo9vwrtwBNXyTJjxtfbzkzqWr4sY8JE5Mq5ZZK7aokps9UjhHcNuJTF82FP2ekM\",\"slot\":133510309}],\"id\":\"6D72B578-401C-449E-A89F-2E31EA441A47\"}\n",
    "getTokenAccountsByOwner": "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":134133059},\"value\":[{\"account\":{\"data\":[\"KLrvuAuq+8gDEGl28m80PrYteWuPlqjGuBpCW5rA84gJ7HiGa7fztefqNjU2MSBOZ3HPlRmb0eAXj0bEanmyfAoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\"base64\"],\"executable\":false,\"lamports\":2039280,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":309},\"pubkey\":\"9nuVPk3KR7oUXmDsHL7irue2Nxaj3ejvuBXoaEcXMmN7\"},{\"account\":{\"data\":[\"ppdSk884LShYnHoHm7XiDlZ28iJVm9BHPgrAEfxU44AJ7HiGa7fztefqNjU2MSBOZ3HPlRmb0eAXj0bEanmyfAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\"base64\"],\"executable\":false,\"lamports\":2039280,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":309},\"pubkey\":\"9bNJ7AF8w1Ms4BsqpqbUPZ16vCSePYJpgSBUTRqd8ph4\"}]},\"id\":\"0891812F-1F8B-4927-80F7-C7C1C1D990B3\"}\n",
    "getToken2022AccountsByOwner":
        #"{"jsonrpc":"2.0","result":{"context":{"apiVersion":"1.17.14","slot":239989261},"value":[{"account":{"data":["qDijZLhcKuVLVBmL6Ve9S9DvSU7kn1XtkCnOtnDXGjA1zKFCx20D2kF7X/jEMh09sgYqyBraJk1DWsFwaUfQkCtqbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgcAAAACAAgAAAAAAAAAAAA=","base64"],"executable":false,"lamports":2157600,"owner":"TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb","rentEpoch":0,"space":182},"pubkey":"43W7QvyKr5hJhFRhvteb7VbsLdwGQG3VZ2fRYVcw5yFN"}]},"id":1}"#,
    "getTokenLargestAccounts":
        #"{"jsonrpc":"2.0","result":{"context":{"slot":1114},"value":[{"address":"FYjHNoFtSQ5uijKrZFyYAxvEr87hsKXkXcxkcmkBAf4r","amount":"771","decimals":2,"uiAmount":7.71,"uiAmountString":"7.71"},{"address":"BnsywxTcaYeNUtzrPxQUvzAWxfzZe3ZLUJ4wMMuLESnu","amount":"229","decimals":2,"uiAmount":2.29,"uiAmountString":"2.29"}]},"id":1}"#,
    "sendTransactionError1": #"{"jsonrpc":"2.0","error":{"code":-32003,"message":"Transaction precompile verification failure InvalidAccountIndex"},"id":"7DEDE6E5-95E7-4866-BFC0-B4C10A76B457"}"#,
    "getTokenAccountBalance": #"{"jsonrpc":"2.0","result":{"context":{"slot":135942588},"value":{"amount":"491717631607","decimals":9,"uiAmount":491.717631607,"uiAmountString":"491.717631607"}},"id":"3D9E7B6E-B48D-40EF-B656-EA3054227CCD"}"#,
    "getHealth": #"{ "jsonrpc": "2.0", "result": "ok", "id": 1 }"#,
    "getHealthError": #"{"jsonrpc":"2.0","error":{"code":-32005,"message":"Node is unhealthy","data":{}},"id":1}"#,
]
