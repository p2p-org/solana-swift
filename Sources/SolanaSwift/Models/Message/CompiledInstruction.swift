import Foundation

// TODO: follow code from solana!
public struct CompiledInstruction: Equatable {
    public let programIdIndex: UInt8
    let keyIndicesCount: [UInt8]
    let keyIndices: [UInt8]
    let dataLength: [UInt8]
    public let data: [UInt8]

    public var accounts: [Int] {
        keyIndices.map { x in Int(x) }
    }

    var programIdIndexValue: Int {
        Int(programIdIndex)
    }

    var serializedData: Data {
        Data([programIdIndex]
            + keyIndicesCount
            + keyIndices
            + dataLength
            + data)
    }
}

extension Sequence where Iterator.Element == TransactionInstruction {
    func compile(accountKeys: [PublicKey]) -> [CompiledInstruction] {
        var compiledInstructions = [CompiledInstruction]()

        for instruction in self {
            let keysSize = instruction.keys.count

            var keyIndices = Data()
            for i in 0 ..< keysSize {
                let index = accountKeys.firstIndex(of: instruction.keys[i].publicKey)!
                keyIndices.append(UInt8(index))
            }

            let compiledInstruction = CompiledInstruction(
                programIdIndex: UInt8(accountKeys.firstIndex(of: instruction.programId)!),
                keyIndicesCount: [UInt8](Data.encodeLength(keysSize)),
                keyIndices: [UInt8](keyIndices),
                dataLength: [UInt8](Data.encodeLength(instruction.data.count)),
                data: instruction.data
            )

            compiledInstructions.append(compiledInstruction)
        }

        return compiledInstructions
    }
}
