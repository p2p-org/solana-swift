const fs = require('fs');

module.exports = function() {
	let models = require('./models.json');
	let structs = "";
	for (const index in models) {
		let model = models[index];
		structs += "\tpublic struct " + model.structName + ": Decodable {\n";
		for (const [key, value] of Object.entries(model.params)) {
			structs += "\t\tpublic let " + key + ": " + value + "\n";
		}
		structs += "\t}\n";
	}

	let string = 
	"//\n"+
	"//  SolanaSDK+Response.swift\n"+
	"//  SolanaSwift\n"+
	"//\n"+
	"//  Created by Chung Tran on 10/27/20.\n"+
	"//\n"+
	"// NOTE: THIS FILE IS GENERATED FROM APIGEN PACKAGE, DO NOT MAKE CHANGES DIRECTLY INTO IT, PLEASE EDIT MODELS.JSON AND modelsGen.js TO MAKE CHANGES (IN ../APIGen FOLDER)\n\n"+
	"import Foundation\n"+
	"import RxSwift\n"+
	"\n"+
	"public extension SolanaSDK {\n\ttypealias Commitment = String\n\n"+structs+"}"

	fs.writeFileSync('../Classes/Models/SolanaSDK+Response.swift', string);
}

//
////  Response.swift
////  p2p_wallet
////
////  Created by Chung Tran on 10/26/20.
////
//
//import Foundation
//
//public extension SolanaSDK {
//    internal struct Response<T: Decodable>: Decodable {
//        let jsonrpc: String
//        let id: String?
//        let result: T
//    }
//    
//    /// Get account info
//    struct AccountInfo: Decodable {
//        let context: Context
//        public let value: AccountInfoValue?
//    }
//    
//    struct AccountInfoValue: Decodable {
//        let data: [String]
//        let executable: Bool
//        let lamports: UInt
//        let owner: String
//        let rentEpoch: String
//    }
//    
//    /// Get balance
//    struct Balance: Decodable {
//        let context: Context
//        public let value: Int
//    }
//    
//    struct Context: Decodable {
//        let slot: Int
//    }
//}