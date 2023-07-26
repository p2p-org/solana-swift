import Foundation
import SolanaSwift

extension PublicKey {
    enum StubFactory {
        static func make() -> PublicKey {
            try! .init(bytes: .StubFactory.make(length: 32, range: 0 ..< UInt8.max))
        }
    }
}
