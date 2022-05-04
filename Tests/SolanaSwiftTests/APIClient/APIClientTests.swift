import XCTest
@testable import SolanaSwift

class APIClientTests: XCTestCase {
    
    let endpoint = SolanaSDK.APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )
    var solanaSDK: SolanaSDK!

    override func setUpWithError() throws {
        let accountStorage = InMemoryAccountStorage()
        solanaSDK = SolanaSDK(endpoint: endpoint, accountStorage: accountStorage)
        let account = try SolanaSDK.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try accountStorage.save(account)
    }

    override func tearDownWithError() throws {
        
    }
    
    func testGetBlock() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBlockHeight"]!)
        let apiClient = SolanaSwift.JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getBlockHeight()
        XCTAssertEqual(result, 119396901)
    }

    func testGetAccountInfo() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getAccountInfo"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: BufferInfo<AccountInfo> = try! await apiClient.getAccountInfo(account: "HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk")
        XCTAssert(result.owner == "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        XCTAssert(result.lamports == 2039280)
        XCTAssert(result.rentEpoch == 304)
    }
    
    func testGetConfirmedBlocksWithLimit() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getConfirmedBlocksWithLimit"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: [UInt64] = try! await apiClient.getConfirmedBlocksWithLimit(startSlot: 131421172, limit: 10)
        XCTAssert(result.count == 10)
        XCTAssert(result[0] == 131421172)
        XCTAssert(result[1] == 131421173)
        XCTAssert(result[9] == 131421181)
    }
    
    func testBatchRequest() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["batch1"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let req1: JSONRPCAPIClientRequest<AnyDecodable> = JSONRPCAPIClientRequest(method: "getBlockHeight", params: [])
        let req2: JSONRPCAPIClientRequest<AnyDecodable> = JSONRPCAPIClientRequest(method: "getConfirmedBlocksWithLimit", params: [10])
        let response = try await apiClient.request(with: [req1, req2])
        XCTAssert(response.count == 2)
        XCTAssert(response[0].result != nil)
        XCTAssert(response[1].result != nil)
    }
    
    func testGetBalance() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBalance"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let account = try SolanaSDK.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network).publicKey.base58EncodedString
        let result: UInt64 = try! await apiClient.getBalance(account: account, commitment: "recent")
        XCTAssert(result == 123456)
    }
    
    func testGetBlockCommitment() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBlockCommitment"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: BlockCommitment = try! await apiClient.getBlockCommitment(block: 119396901)
        XCTAssert(result.totalStake == 394545529101613343)
    }

    func testGetBlockTime() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getBlockTime"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: Date = try! await apiClient.getBlockTime(block: 119396901)
        XCTAssert(result == Date(timeIntervalSince1970: TimeInterval(1644034719)))
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
        let account = try SolanaSDK.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network).publicKey.base58EncodedString
        let result: [String] = try! await apiClient.getConfirmedSignaturesForAddress(account: account, startSlot: 131647712, endSlot: 131647713)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], "1")
        XCTAssertEqual(result[1], "2")
        XCTAssertEqual(result[2], "3")
    }
    
    func testGetTransaction() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getTransaction"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result: TransactionInfo = try! await apiClient.getTransaction(transactionSignature: "3kNdBJeLhLQX8FsyHjAKrtfnq5L6NwjQ3Nm96Wyx1pk5GFicbE47mpu2CtiU8krZDVDk7Di5ELAoKtw91Yj89bQ")
        XCTAssertNotNil(result)
    }
    
    func testGetEpochInfo() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getEpochInfo"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getEpochInfo()
        XCTAssertNotNil(result)
        XCTAssertEqual(result.absoluteSlot, 131686768)
        XCTAssertEqual(result.epoch, 304)
    }
    
    func testGetFees() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getFees"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getFees(commitment: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result.lastValidSlot, 131770381)
        XCTAssertEqual(result.feeCalculator?.lamportsPerSignature, 5000)
        XCTAssertEqual(result.blockhash, "7jvToPQ4ASj3xohjM117tMqmtppQDaWVADZyaLFnytFr")
    }
    
    func testSendTransaction() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["sendTransaction"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.sendTransaction(transaction: "")
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "123")
    }
    
    func testGetMinimumBalanceForRentExemption() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getMinimumBalanceForRentExemption"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getMinimumBalanceForRentExemption(span: 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 890880)
    }
    
    func testGetRecentBlockhash() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["getRecentBlockhash"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getRecentBlockhash(commitment: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1")
    }
    
    // MARK: - Mocks
    
    
    class NetworkManagerMock: NetworkManager {
        private let json: String
        init(_ json: String) {
            self.json = json
        }

        func requestData(request: URLRequest) async throws -> Data {
            let str = json.data(using: .utf8)!
            return str
        }
    }

    var NetworkManagerMockJSON = [
        "getBlockHeight": "[{\"jsonrpc\":\"2.0\",\"result\":119396901,\"id\":\"45ECD42F-D53C-4A02-8621-52D88840FFC1\"}]\n"
        , "getAccountInfo": "[{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131421172},\"value\":{\"data\":[\"xvp6877brTo9ZfNqq8l0MbG75MLS9uDkfKYCA0UvXWF9P8kKbTPTsQZqMMzOan8jwyOl0jQaxrCPh8bU1ysTa96DDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\"base64\"],\"executable\":false,\"lamports\":2039280,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":304}},\"id\":\"6B1C0860-44BE-4FA9-9F57-CB14BC7636BB\"}]\n"
        , "getConfirmedBlocksWithLimit": "[{\"jsonrpc\":\"2.0\",\"result\":[131421172,131421173,131421174,131421175,131421176,131421177,131421178,131421179,131421180,131421181],\"id\":\"A5A1EB9D-CC05-496F-8582-2B8D610859DB\"}]\n"
        , "batch1": "[{\"jsonrpc\":\"2.0\",\"result\":119396901,\"id\":\"45ECD42F-D53C-4A02-8621-52D88840FFC1\"},{\"jsonrpc\":\"2.0\",\"result\":[131421172,131421173,131421174,131421175,131421176,131421177,131421178,131421179,131421180,131421181],\"id\":\"A5A1EB9D-CC05-496F-8582-2B8D610859DB\"}]"
        , "getBalance": "[{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131647712},\"value\":123456},\"id\":\"5D174E0A-0826-428A-9EEA-7B75A854671E\"}]\n"
        , "getBlockCommitment": "[{\"jsonrpc\":\"2.0\",\"result\":{\"commitment\":null,\"totalStake\":394545529101613343},\"id\":\"BB79B171-937B-4EB1-9D13-EC961F186D75\"}]\n"
        , "getBlockTime": "[{\"jsonrpc\":\"2.0\",\"result\":1644034719,\"id\":\"F944107E-4105-4B0A-8049-3BA73C1E4067\"}]\n"
        , "getClusterNodes": "[{\"jsonrpc\":\"2.0\",\"result\":[{\"featureSet\":1070292356,\"gossip\":\"145.40.93.113:8001\",\"pubkey\":\"57UtuDwoCurTTWySMeV5MiopvDWvK2QeLWu47biQjjLJ\",\"rpc\":null,\"shredVersion\":8573,\"tpu\":\"145.40.93.113:8004\",\"version\":\"1.9.14\"}],\"id\":\"356C6D54-84EA-48D0-B13F-D5667A5DC750\"}]\n"
        , "getConfirmedBlock": "[{\"jsonrpc\":\"2.0\",\"id\":\"2BAC562A-33FE-45E4-B49E-9008476A4EA8\",\"result\":{\"blockHeight\":119407643,\"blockTime\":1651131785,\"blockhash\":\"9iYcQnofTuZwwtuG4bbpoV8MMsihxfVT5eyBjzJRTHDc\",\"parentSlot\":131647711,\"previousBlockhash\":\"FkSQpuhgLMVRwGWPzw3zjXq3oXUMcNogfwAkgNC9KWy7\",\"rewards\":[{\"commission\":null,\"lamports\":-11967,\"postBalance\":1357161,\"pubkey\":\"DkZzno16JLXYda4eHZzM9J8Vxet9StJJ5mimrtjbK5V3\",\"rewardType\":\"Rent\"}],\"transactions\":[{\"meta\":{\"err\":{\"InstructionError\":[0,{\"Custom\":0}]},\"fee\":5000,\"innerInstructions\":[],\"logMessages\":[\"Program Vote111111111111111111111111111111111111111 invoke [1]\",\"Program Vote111111111111111111111111111111111111111 failed: custom program error: 0x0\"],\"postBalances\":[2055275200,8808836473,143487360,1169280,1],\"postTokenBalances\":[],\"preBalances\":[2055280200,8808836473,143487360,1169280,1],\"preTokenBalances\":[],\"rewards\":[],\"status\":{\"Err\":{\"InstructionError\":[0,{\"Custom\":0}]}}},\"transaction\":{\"message\":{\"accountKeys\":[\"tJ9HBhHM436kZ6udx8nBVEAsGaVCoy2Mw7K1U63bLyM\",\"85F9XWHuJ19iCgARo8P6E7yUT1mucqRHuKK9zu359hqR\",\"SysvarS1otHashes111111111111111111111111111\",\"SysvarC1ock11111111111111111111111111111111\",\"Vote111111111111111111111111111111111111111\"],\"header\":{\"numReadonlySignedAccounts\":0,\"numReadonlyUnsignedAccounts\":3,\"numRequiredSignatures\":1},\"instructions\":[{\"accounts\":[1,2,3,0],\"data\":\"rTDbDtm67JPw9WoF6jKWCCCH3zrLe1haxxDLEMTJB5TjB897zfAoiwVXkVq1HowpRBbRLZGfk4e4637rpxEEkzi6a4EWHBS9CqwLxXSP\",\"programIdIndex\":4}],\"recentBlockhash\":\"FddpWyVFoazKW4mD8GoghnMx8g18vpQhHGrcLwuRdRUs\"},\"signatures\":[\"2AqCkYUKCiv1zYEXBESaYCWeLUv2BwzoCXLrovhsXBu7Ss5XC6kqrBCGEguJbXt3BssmBurrwL54ZdYXwB4YYLrX\"]}}]}}]\n"
        , "getConfirmedSignaturesForAddress": "[{\"jsonrpc\":\"2.0\",\"result\":[\"1\",\"2\",\"3\"],\"id\":\"71F4389A-854F-4738-A869-CC455598C11C\"}]\n"
        , "getTransaction": "[{\"jsonrpc\":\"2.0\",\"result\":{\"blockTime\":1647268521,\"meta\":{\"err\":null,\"fee\":10000,\"innerInstructions\":[{\"index\":0,\"instructions\":[{\"accounts\":[\"11111111111111111111111111111111\",\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\",\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"GyvYVTFgrfCmkE4pHzw44xyELoaivkYDeP2P1TmeqFSs\",\"11111111111111111111111111111111\",\"HSqVcxpDaZzwkHxreLisDtR9bQsLaTCMzMATFVhDoeNe\",\"fjohsw9j8aBJaEE5ddzHk3AgMjdbQSXrMoPGrepNHrB\"],\"data\":\"12B5oCT463JwdTFKK1Xm3F2xL1NoDdJQGeMuRKappf2aRUXjfSUEeEPQYcW1cMis8VD\",\"programId\":\"namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX\"},{\"parsed\":{\"info\":{\"destination\":\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"lamports\":2227200,\"source\":\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\"},\"type\":\"transfer\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"account\":\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"space\":192},\"type\":\"allocate\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"account\":\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"owner\":\"namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX\"},\"type\":\"assign\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"destination\":\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"lamports\":974400,\"source\":\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\"},\"type\":\"transfer\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"account\":\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"space\":12},\"type\":\"allocate\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"},{\"parsed\":{\"info\":{\"account\":\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"owner\":\"B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog\"},\"type\":\"assign\"},\"program\":\"system\",\"programId\":\"11111111111111111111111111111111\"}]}],\"logMessages\":[\"Program B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog invoke [1]\",\"Program namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX invoke [2]\",\"Program log: Entrypoint\",\"Program log: Beginning processing\",\"Program log: Instruction unpacked\",\"Program log: Instruction: Create\",\"Program 11111111111111111111111111111111 invoke [3]\",\"Program 11111111111111111111111111111111 success\",\"Program 11111111111111111111111111111111 invoke [3]\",\"Program 11111111111111111111111111111111 success\",\"Program 11111111111111111111111111111111 invoke [3]\",\"Program 11111111111111111111111111111111 success\",\"Program namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX consumed 20584 of 191569 compute units\",\"Program namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX success\",\"Program 11111111111111111111111111111111 invoke [2]\",\"Program 11111111111111111111111111111111 success\",\"Program 11111111111111111111111111111111 invoke [2]\",\"Program 11111111111111111111111111111111 success\",\"Program 11111111111111111111111111111111 invoke [2]\",\"Program 11111111111111111111111111111111 success\",\"Program B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog consumed 41308 of 200000 compute units\",\"Program B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog success\"],\"postBalances\":[443590671,100000000,2227200,974400,1,1141440,1009200,0,71353866,1001293440],\"postTokenBalances\":[],\"preBalances\":[446802271,100000000,0,0,1,1141440,1009200,0,71353866,1001293440],\"preTokenBalances\":[],\"rewards\":[],\"status\":{\"Ok\":null}},\"slot\":124916513,\"transaction\":{\"message\":{\"accountKeys\":[{\"pubkey\":\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\",\"signer\":true,\"writable\":true},{\"pubkey\":\"fjohsw9j8aBJaEE5ddzHk3AgMjdbQSXrMoPGrepNHrB\",\"signer\":true,\"writable\":false},{\"pubkey\":\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"signer\":false,\"writable\":true},{\"pubkey\":\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"signer\":false,\"writable\":true},{\"pubkey\":\"11111111111111111111111111111111\",\"signer\":false,\"writable\":false},{\"pubkey\":\"namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX\",\"signer\":false,\"writable\":false},{\"pubkey\":\"SysvarRent111111111111111111111111111111111\",\"signer\":false,\"writable\":false},{\"pubkey\":\"GyvYVTFgrfCmkE4pHzw44xyELoaivkYDeP2P1TmeqFSs\",\"signer\":false,\"writable\":false},{\"pubkey\":\"HSqVcxpDaZzwkHxreLisDtR9bQsLaTCMzMATFVhDoeNe\",\"signer\":false,\"writable\":false},{\"pubkey\":\"B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog\",\"signer\":false,\"writable\":false}],\"instructions\":[{\"accounts\":[\"11111111111111111111111111111111\",\"namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX\",\"SysvarRent111111111111111111111111111111111\",\"5qePAZpkrsxkhPQrwmmzFmi84xBwV4Z2hBuHh2jFA1FA\",\"F2kK1Z55NTZcagih78suvreP3UjNfrVLP2UBcR3orNub\",\"6GxxbzceU62bMwRcrRAnDqgfCQD9Z1FLUJCdwnFpFUvX\",\"GyvYVTFgrfCmkE4pHzw44xyELoaivkYDeP2P1TmeqFSs\",\"11111111111111111111111111111111\",\"HSqVcxpDaZzwkHxreLisDtR9bQsLaTCMzMATFVhDoeNe\",\"fjohsw9j8aBJaEE5ddzHk3AgMjdbQSXrMoPGrepNHrB\"],\"data\":\"1RxqKETLww2ut33YFYhShTyYLvJhfTf7WPWUiLK5XGL58wSWFHKvt4YJUXDoL8JFGkzGzVbP\",\"programId\":\"B59xBt3AVAcV5jiHGEbGHe93mbycA44EK3vA6E4VqKog\"}],\"recentBlockhash\":\"U9hxJeX42n3rEG8FJychJpeQucN1QqKoMb56GigUdrm\"},\"signatures\":[\"3kNdBJeLhLQX8FsyHjAKrtfnq5L6NwjQ3Nm96Wyx1pk5GFicbE47mpu2CtiU8krZDVDk7Di5ELAoKtw91Yj89bQ\",\"4w7p5ZvAgzZ7THtxKxRbFqAuD69Uk82tnbuz9BT822MRiGZUypAkok8u4sTPizjHmjx65vpGcw4SwFXu8hgafCoh\"]}},\"id\":\"03194776-D570-4887-8A2A-84007EE79A66\"}]\n"
        , "getEpochInfo": "[{\"jsonrpc\":\"2.0\",\"result\":{\"absoluteSlot\":131686768,\"blockHeight\":119443373,\"epoch\":304,\"slotIndex\":358768,\"slotsInEpoch\":432000,\"transactionCount\":71271072342},\"id\":\"AE699DFA-84E8-495C-8B06-F30DDFA6C56D\"}]\n"
        , "getFees": "[{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131770081},\"value\":{\"blockhash\":\"7jvToPQ4ASj3xohjM117tMqmtppQDaWVADZyaLFnytFr\",\"feeCalculator\":{\"lamportsPerSignature\":5000},\"lastValidBlockHeight\":119512694,\"lastValidSlot\":131770381}},\"id\":\"3FF1AACE-812A-4106-8C34-6EF66237673C\"}]\n"
        , "sendTransaction": "[{\"jsonrpc\":\"2.0\",\"result\":\"123\",\"id\":\"3FF1AACE-812A-4106-8C34-6EF66237673C\"}]\n"
        , "getMinimumBalanceForRentExemption": "[{\"jsonrpc\":\"2.0\",\"result\":890880,\"id\":\"25423C5F-2FF3-4134-8CB3-9090BFCB2CE3\"}]\n"
        , "getRecentBlockhash": "[{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131780453},\"value\":{\"blockhash\":\"63ionHTAM94KaSujUCg23hfg7TLharchq5BYXdLGqia1\",\"feeCalculator\":{\"lamportsPerSignature\":5000}}},\"id\":\"21D61199-F235-4CC9-9BE6-06745D3AC69E\"}]\n"

    ]

}
