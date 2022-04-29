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
            public let owner: String?
            public let account: String?
            public let source: String?
            public let destination: String?
            
            // create account
            public let lamports: UInt64?
            public let newAccount: String?
            public let space: UInt64?
            
            // initialize account
            public let mint: String?
            public let rentSysvar: String?
            
            // approve
            public let amount: String?
            public let delegate: String?
            
            // transfer
            public let authority: String?
            public let wallet: String? // spl-associated-token-account
            
            // transferChecked
            public let tokenAmount: TokenAccountBalance?
        }
        
        public let info: Info
        public let type: String?
    }
    
    public let program: String?
    public let programId: String
    public let parsed: Parsed?
    
    // swap
    public let data: String?
    public let accounts: [String]?
}

extension Sequence where Iterator.Element == ParsedInstruction {
    func containProgram(with name: String) -> Bool {
        getFirstProgram(with: name) != nil
    }
    
    func getFirstProgram(with name: String) -> ParsedInstruction? {
        first(where: { $0.program == name })
    }
}
