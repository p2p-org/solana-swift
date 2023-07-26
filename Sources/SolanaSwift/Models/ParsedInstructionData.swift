import Foundation

public extension TransactionInfo {
    struct ParsedInstructionData {
        public let instruction: ParsedInstruction
        public let innerInstruction: InnerInstruction?
    }

    func instructionsData() -> [ParsedInstructionData] {
        let instructions = transaction.message.instructions
        let innerInstructions = meta?.innerInstructions ?? []

        return instructions.enumerated().map { index, element in
            ParsedInstructionData(
                instruction: element,
                innerInstruction: innerInstructions.first(where: { $0.index == index })
            )
        }
    }
}
