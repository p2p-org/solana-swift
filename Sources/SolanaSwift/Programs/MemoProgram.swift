import Foundation

public enum MemoProgramError: Error {
    case invalid
}

public enum MemoProgram: SolanaBasicProgram {
    /// The public id of the program
    public static var id: PublicKey {
        "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr"
    }

    /// Create memo instruction
    public static func createMemoInstruction(
        memo: String
    ) throws -> TransactionInstruction {
        // TODO: - Memo length assertion
        guard let data = memo.data(using: .utf8) else {
            throw MemoProgramError.invalid
        }
        return TransactionInstruction(
            keys: [],
            programId: id,
            data: data.bytes
        )
    }
}
