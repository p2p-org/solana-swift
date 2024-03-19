import OSLog
import SolanaSwift
import XCTest

final class GetAccountBalancesTests: XCTestCase {
    var rpcClient: SolanaAPIClient!
    var tokensRepository: TokenRepository!

    override func setUp() async throws {
        rpcClient = JSONRPCAPIClient(
            endpoint: .init(
                address: "https://example.com",
                network: .mainnetBeta
            ),
            networkManager: MockSolanaAPINetworkManager()
        )
        tokensRepository = SolanaTokenListRepository(
            tokenListSource: SolanaTokenListSourceImpl(
                url: "https://example.com",
                networkManager: MockTokensRepositoryNetworkManager()
            )
        )
    }

    func testGetAccountBalances() async throws {
        let result = try await rpcClient.getAccountBalances(
            for: "abctest",
            withToken2022: false,
            tokensRepository: tokensRepository
        )

        XCTAssertEqual(result.unresolved.count, 0)

        let resolved = result.resolved

        XCTAssertEqual(resolved.count, 2)

        // Token
        XCTAssertEqual(resolved[0].pubkey, "BNUGJRjzQYeGTSLPkCp4xNSH4oBDMCevpsHEfWvWMYeq")
        XCTAssertEqual(resolved[0].lamports, 153_269_049_492)
        XCTAssertEqual(resolved[0].token.chainId, 101)
        XCTAssertEqual(resolved[0].token.symbol, "$DEDE")
        XCTAssertEqual(resolved[0].token.name, "$DEDE")
        XCTAssertEqual(resolved[0].token.decimals, 6)
        XCTAssertEqual(
            resolved[0].token.logoURI,
            "https://bafkreic2m54r4fvg4a6jfuxe2pnxzkuwx75gzu2jbxw4magd2eraqhccua.ipfs.nftstorage.link"
        )
        XCTAssertEqual(resolved[0].token.mintAddress, "CzXyy265vDCXRysRd5nvpy9oieq2KUtx51Sz1jUMUWyE")
        XCTAssertEqual(resolved[0].tokenProgramId, TokenProgram.id.base58EncodedString)
        XCTAssertEqual(resolved[0].minimumBalanceForRentExemption, 2_039_280)

        XCTAssertEqual(resolved[1].pubkey, "6uJPNjuLnoT6rvwj2wFLHnvbFtJqkbdvKhtdw16EabNx")
        XCTAssertEqual(resolved[1].lamports, 4_030_896)
        XCTAssertEqual(resolved[1].token.chainId, 101)
        XCTAssertEqual(resolved[1].token.symbol, "BONK")
        XCTAssertEqual(resolved[1].token.name, "Bonk")
        XCTAssertEqual(resolved[1].token.decimals, 5)
        XCTAssertEqual(resolved[1].token.logoURI, "https://arweave.net/hQiPZOsRZXGXBJd_82PhVdlM_hACsT_q6wqwf5cSY7I")
        XCTAssertEqual(resolved[1].token.mintAddress, "DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263")
        XCTAssertEqual(resolved[1].tokenProgramId, TokenProgram.id.base58EncodedString)
        XCTAssertEqual(resolved[1].minimumBalanceForRentExemption, 2_039_280)
    }

    func testGetAccountBalancesWithToken2022() async throws {
        let result = try await rpcClient.getAccountBalances(
            for: "abctest",
            withToken2022: true,
            tokensRepository: tokensRepository
        )

        XCTAssertEqual(result.unresolved.count, 0)

        let resolved = result.resolved

        XCTAssertEqual(resolved.count, 3)

        // Token
        XCTAssertEqual(resolved[0].pubkey, "BNUGJRjzQYeGTSLPkCp4xNSH4oBDMCevpsHEfWvWMYeq")
        XCTAssertEqual(resolved[0].lamports, 153_269_049_492)
        XCTAssertEqual(resolved[0].token.chainId, 101)
        XCTAssertEqual(resolved[0].token.symbol, "$DEDE")
        XCTAssertEqual(resolved[0].token.name, "$DEDE")
        XCTAssertEqual(resolved[0].token.decimals, 6)
        XCTAssertEqual(
            resolved[0].token.logoURI,
            "https://bafkreic2m54r4fvg4a6jfuxe2pnxzkuwx75gzu2jbxw4magd2eraqhccua.ipfs.nftstorage.link"
        )
        XCTAssertEqual(resolved[0].token.mintAddress, "CzXyy265vDCXRysRd5nvpy9oieq2KUtx51Sz1jUMUWyE")
        XCTAssertEqual(resolved[0].tokenProgramId, TokenProgram.id.base58EncodedString)
        XCTAssertEqual(resolved[0].minimumBalanceForRentExemption, 2_039_280)

        XCTAssertEqual(resolved[1].pubkey, "6uJPNjuLnoT6rvwj2wFLHnvbFtJqkbdvKhtdw16EabNx")
        XCTAssertEqual(resolved[1].lamports, 4_030_896)
        XCTAssertEqual(resolved[1].token.chainId, 101)
        XCTAssertEqual(resolved[1].token.symbol, "BONK")
        XCTAssertEqual(resolved[1].token.name, "Bonk")
        XCTAssertEqual(resolved[1].token.decimals, 5)
        XCTAssertEqual(resolved[1].token.logoURI, "https://arweave.net/hQiPZOsRZXGXBJd_82PhVdlM_hACsT_q6wqwf5cSY7I")
        XCTAssertEqual(resolved[1].token.mintAddress, "DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263")
        XCTAssertEqual(resolved[1].tokenProgramId, TokenProgram.id.base58EncodedString)
        XCTAssertEqual(resolved[1].minimumBalanceForRentExemption, 2_039_280)

        // Token 2022
        XCTAssertEqual(resolved[2].pubkey, "43W7QvyKr5hJhFRhvteb7VbsLdwGQG3VZ2fRYVcw5yFN")
        XCTAssertEqual(resolved[2].lamports, 6_363_367)
        XCTAssertEqual(resolved[2].token.chainId, 101)
        XCTAssertEqual(resolved[2].token.symbol, "BERN")
        XCTAssertEqual(resolved[2].token.name, "BonkEarn")
        XCTAssertEqual(resolved[2].token.decimals, 5)
        XCTAssertEqual(resolved[2].token.logoURI, "https://i.imgur.com/nd9AVZ4.jpeg")
        XCTAssertEqual(resolved[2].token.mintAddress, "CKfatsPMUf8SkiURsDXs7eK6GWb4Jsd6UDbs7twMCWxo")
        XCTAssertEqual(resolved[2].tokenProgramId, Token2022Program.id.base58EncodedString)
        XCTAssertEqual(resolved[2].minimumBalanceForRentExemption, 2_157_600)
    }
}

final class MockSolanaAPINetworkManager: NetworkManager {
    func requestData(request: URLRequest) async throws -> Data {
        let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8)!

        if bodyString.contains("getTokenAccountsByOwner") &&
            bodyString.contains(Token2022Program.id.base58EncodedString)
        {
            return #"{"jsonrpc":"2.0","result":{"context":{"apiVersion":"1.16.20","slot":241158536},"value":[{"account":{"data":["qDijZLhcKuVLVBmL6Ve9S9DvSU7kn1XtkCnOtnDXGjA1zKFCx20D2kF7X/jEMh09sgYqyBraJk1DWsFwaUfQkOcYYQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgcAAAACAAgAAAAAAAAAAAA=","base64"],"executable":false,"lamports":2157600,"owner":"TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb","rentEpoch":0,"space":182},"pubkey":"43W7QvyKr5hJhFRhvteb7VbsLdwGQG3VZ2fRYVcw5yFN"}]},"id":"45F7BFDE-A0E8-4734-B4FA-8DD2BF223D50"}"#
                .data(using: .utf8)!
        }

        if bodyString.contains("getTokenAccountsByOwner") &&
            bodyString.contains(TokenProgram.id.base58EncodedString)
        {
            return #"{"id":"74C86140-D982-4694-9590-C76C6D8DB000","jsonrpc":"2.0","result":{"context":{"apiVersion":"1.16.27","slot":241158536},"value":[{"account":{"data":["si2xpzyKyRRhAYu81RzXwI9jPdXY6/w9/mVj+atY0qk1zKFCx20D2kF7X/jEMh09sgYqyBraJk1DWsFwaUfQkJQYjK8jAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"],"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":0,"space":165},"pubkey":"BNUGJRjzQYeGTSLPkCp4xNSH4oBDMCevpsHEfWvWMYeq"},{"account":{"data":["vAfFbmCtPT8Xc4LqxlSPuh/TLP2QygKz58+hhf3Oc5g1zKFCx20D2kF7X/jEMh09sgYqyBraJk1DWsFwaUfQkLCBPQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"],"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":0,"space":165},"pubkey":"6uJPNjuLnoT6rvwj2wFLHnvbFtJqkbdvKhtdw16EabNx"}]}}"#
                .data(using: .utf8)!
        }

        fatalError()
    }
}

final class MockTokensRepositoryNetworkManager: NetworkManager {
    func requestData(request _: URLRequest) async throws -> Data {
        try Data(contentsOf: Bundle.module.url(forResource: "get_all_tokens_info", withExtension: "json")!)
    }
}
