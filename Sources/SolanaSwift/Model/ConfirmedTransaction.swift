import Foundation


public struct ConfirmedTransaction: Decodable {
    public let message: Message
    let signatures: [String]
}

public extension ConfirmedTransaction {
    struct Message: Decodable {
        public let accountKeys: [Account.Meta]
        public let instructions: [ParsedInstruction]
        public let recentBlockhash: String
    }
}


public struct ParsedInstruction: Decodable {
    struct Parsed: Decodable {
        struct Info: Decodable {
            let owner: String?
            let account: String?
            let source: String?
            let destination: String?
            
            // create account
            let lamports: UInt64?
            let newAccount: String?
            let space: UInt64?
            
            // initialize account
            let mint: String?
            let rentSysvar: String?
            
            // approve
            let amount: String?
            let delegate: String?
            
            // transfer
            let authority: String?
            let wallet: String? // spl-associated-token-account
            
            // transferChecked
            let tokenAmount: TokenAccountBalance?
        }
        
        let info: Info
        let type: String?
    }
    
    let program: String?
    public let programId: String
    let parsed: Parsed?
    
    // swap
    public let data: String?
    let accounts: [String]?
}

extension Sequence where Iterator.Element == ParsedInstruction {
    func containProgram(with name: String) -> Bool {
        getFirstProgram(with: name) != nil
    }
    
    func getFirstProgram(with name: String) -> ParsedInstruction? {
        first(where: { $0.program == name })
    }
}
