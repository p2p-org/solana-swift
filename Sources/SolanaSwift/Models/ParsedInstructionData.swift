//
// Created by Giang Long Tran on 29.10.21.
//

import Foundation

extension TransactionInfo {
    
    struct ParsedInstructionData {
        let instruction: ParsedInstruction
        let innerInstruction: InnerInstruction?
    }
    
    func instructionsData() -> [ParsedInstructionData] {
        let instructions = transaction.message.instructions
        let innerInstructions = meta?.innerInstructions ?? []
        
        return instructions.enumerated().map { (index, element) in
            ParsedInstructionData(
                instruction: element,
                innerInstruction: innerInstructions.first(where: { $0.index == index })
            )
        }
    }
}
