import Foundation

public extension PublicKey {
    static func isSPLTokenProgram(_ programId: String?) -> Bool {
        programId == TokenProgram.id.base58EncodedString ||
            programId == Token2022Program.id.base58EncodedString
    }
}
