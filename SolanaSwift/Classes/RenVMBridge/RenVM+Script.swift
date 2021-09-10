//
//  RenVM+Script.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/09/2021.
//

import Foundation

extension RenVM {
    class Script {
        private static let CHECKSUM_LENGTH = 4
        private var bos = Data() //    private ByteArrayOutputStream bos;
        
        // get current bytes
        var bytes: [UInt8] {
            bos.bytes
        }
        
        func op(_ opcode: Int) -> Self {
            bos += Data.encodeLength(opcode)
            return self
        }
        
        func data(_ data: Data) -> Self {
            bos += Data.encodeLength(data.count)
            return self
        }
        
        func toAddress(prefix: Data) -> Data {
            let hash = Data(bytes).hash160
            let hashWithPrefix = prefix + hash
        }
    //
    //    public byte[] toAddress(byte[] prefix) {
    //        byte[] hash = Hash.hash160(this.toByteArray());
    //        byte[] hashWithPrefix = ByteBuffer.allocate(prefix.length + hash.length).put(prefix).put(hash).array();
    //        byte[] hashWithChecksum = ByteBuffer.allocate(hashWithPrefix.length + CHECKSUM_LENGTH).put(hashWithPrefix)
    //                .put(checksum(hashWithPrefix)).array();
    //        return hashWithChecksum;
    //    }
    //
    //    public static Script gatewayScript(byte[] gGubKeyHash, byte[] gHash) {
    //        Script script = new Script();
    //        script.data(gHash);
    //        script.op(ScriptOpCodes.OP_DROP);
    //        script.op(ScriptOpCodes.OP_DUP);
    //        script.op(ScriptOpCodes.OP_HASH160);
    //        script.data(gGubKeyHash);
    //        script.op(ScriptOpCodes.OP_EQUALVERIFY);
    //        script.op(ScriptOpCodes.OP_CHECKSIG);
    //        return script;
    //    }
    //
    //    public static byte[] createAddressByteArray(byte[] gGubKeyHash, byte[] gHash, byte[] prefix) {
    //        return gatewayScript(gGubKeyHash, gHash).toAddress(prefix);
    //    }
    //
    //    public static byte[] checksum(byte[] hash) {
    //        byte[] sha256sha256Hash = Hash.sha256(Hash.sha256(hash));
    //        return Arrays.copyOf(sha256sha256Hash, CHECKSUM_LENGTH);
    //    }
    //
    //    public static class ScriptOpCodes {
    //        public static final int OP_DROP = 0x75;
    //        public static final int OP_DUP = 0x76;
    //        public static final int OP_HASH160 = 0xa9;
    //        public static final int OP_EQUALVERIFY = 0x88;
    //        public static final int OP_CHECKSIG = 0xac;
    //    }
    }
}

