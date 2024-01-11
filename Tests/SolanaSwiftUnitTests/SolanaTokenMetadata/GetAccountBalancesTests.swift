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

    func testGetAccountBalancesWithToken2022() async throws {
        let result = try await rpcClient.getAccountBalancesWithToken2022(
            for: "abctest",
            tokensRepository: tokensRepository
        )
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
