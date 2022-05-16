import XCTest
@testable import SolanaSwift

class SocketDecodingTests: XCTestCase {
    
    func testDecodingSocketSubscription() {
        let string = #"{"jsonrpc":"2.0","result":22529999,"id":"ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E"}"#
        let result = try! JSONDecoder().decode(SocketSubscription.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.id, "ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E")
        XCTAssertEqual(result.result, 22529999)
    }
    
    func testDecodingSOLAccountNotification() {
        let string = #"{"jsonrpc":"2.0","method":"accountNotification","params":{"result":{"context":{"slot":80221533},"value":{"data":["","base64"],"executable":false,"lamports":41083620,"owner":"11111111111111111111111111111111","rentEpoch":185}},"subscription":46133}}"#
        let result = try! JSONDecoder().decode(Response<BufferInfo<EmptyInfo>>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.result?.value.lamports, 41083620)
    }
    
    func testDecodingProgramNotification() {
        let string = #"{"jsonrpc":"2.0","method":"programNotification","params":{"result":{"context":{"slot":5208469},"value":{"pubkey":"H4vnBqifaSACnKa7acsxstsY1iV1bvJNxsCY7enrd1hq","account":{"data":["11116bv5nS2h3y12kD1yUKeMZvGcKLSjQgX6BeV7u1FrjeJcKfsHPXHRDEHrBesJhZyqnnq9qJeUuF7WHxiuLuL5twc38w2TXNLxnDbjmuR","base58"],"executable":false,"lamports":33594,"owner":"11111111111111111111111111111111","rentEpoch":636}}},"subscription":24040}}"#
        let result = try! JSONDecoder().decode(Response<ProgramAccount<EmptyInfo>>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.subscription, 24040)
    }
    
    
    func testDecodingTokenAccountNotification() {
        let string = #"{"jsonrpc":"2.0","method":"accountNotification","params":{"result":{"context":{"slot":80216037},"value":{"data":{"parsed":{"info":{"isNative":false,"mint":"kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6","owner":"6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm","state":"initialized","tokenAmount":{"amount":"390000101","decimals":5,"uiAmount":3900.00101,"uiAmountString":"3900.00101"}},"type":"account"},"program":"spl-token","space":165},"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":185}},"subscription":42765}}"#
        
        let result = try! JSONDecoder().decode(Response<BufferInfoParsed<SocketTokenAccountNotificationData>>.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.params?.result?.value.data?.parsed.info.tokenAmount.amount, "390000101")
    }
    
    func testDecodingSignatureNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"signatureNotification","params":{"result":{"context":{"slot":80768508},"value":{"err":null}},"subscription":43601}}"#
        
        let result = try JSONDecoder().decode(Response<SocketSignatureNotification>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.method, "signatureNotification")
    }

}
