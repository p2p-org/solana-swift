import Foundation
@testable import SolanaSwift

extension Message {
    enum StubFactory {
        static func makeSignedWithInstructions() -> Message {
            .init(
                header: .init(
                    numRequiredSignatures: 2,
                    numReadonlySignedAccounts: 0,
                    numReadonlyUnsignedAccounts: 3
                ),
                accountKeys: [
                    try! PublicKey(string: "3z5p9oNxJVDkxkcvxkb9bcYZJsipNseRKzLC9N9CPZD4"),
                    try! PublicKey(string: "H4ChXmobu28k7SLHfybPt3w2CHaxiXZ4hn6rmDcTxsyS"),
                    try! PublicKey(string: "11111111111111111111111111111111"),
                    try! PublicKey(string: "SysvarRent111111111111111111111111111111111"),
                    try! PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"),
                ],
                recentBlockhash: "VLortStdEx517K8wQ4eaijZGzrYVxenfoDYKGhkeGYc",
                instructions: [
                    .init(
                        programIdIndex: 2,
                        keyIndicesCount: [2],
                        keyIndices: [0, 1],
                        dataLength: [52],
                        data: Base58.decode("11119os1e9qSs2u7TsThXqkBSRVFxhmYaFKFZ1waB2X7armDmvK3p5GmLdUxYdg3h7QSrL")
                    ),
                    .init(
                        programIdIndex: 4,
                        keyIndicesCount: [2],
                        keyIndices: [0, 3],
                        dataLength: [67],
                        data: Base58.decode("114uwbVTPRz2R47GYXvCB1asLS15keuV56qsVWt112YpzPp2osYuGtdJ9wenk2w7hT6pnZA2FDcT65SV7nbuk11kXUs")
                    ),
                ]
            )
        }
    }
}
