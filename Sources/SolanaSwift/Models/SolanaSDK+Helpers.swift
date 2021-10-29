//
// Created by Giang Long Tran on 29.10.21.
//

import Foundation

extension SolanaSDK.TransactionInfo {
    
    struct ParsedInstructionData {
        let instruction: SolanaSDK.ParsedInstruction
        let innerInstruction: SolanaSDK.InnerInstruction?
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