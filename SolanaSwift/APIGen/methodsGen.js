const fs = require('fs');

module.exports = function() {
	let methods = require('./methods.json');

	let funcs = "";
	for (const index in methods) {

		funcs += "\tfunc " + methods[index].method + "(";

		let funcParams = [];
		let paramsToPass = [];
		for (let [key, value] of Object.entries(methods[index].params)) {
  			funcParams.push(key + ": " + value);
  			if (key == 'commitment') {key = "RequestConfiguration(commitment: "+key+")";}
  			paramsToPass.push(key);
		}
		funcs += funcParams.join(", ");

		let returnedType = methods[index].returnedType;
		let startWithRpc = returnedType.startsWith("Rpc<");
		if (startWithRpc) {
			returnedType = returnedType.replace("Rpc<", "");
			returnedType = returnedType.replace(">", "");
		}
		funcs += ") -> Single<"+returnedType+"> {\n";

		let parameters = "";
		if (paramsToPass.length > 0) {
			parameters = "parameters: ["+ paramsToPass.join(", ") +"]"
		}

		funcs += "\t\t";
		if (startWithRpc) {
			funcs += "(";
		}
		funcs += "request("+parameters+")";
		if (startWithRpc) {
			funcs += " as Single<Rpc<"+returnedType+">>)\n"
			funcs += "\t\t\t.map {$0.value}";
		}
		funcs += "\n"
		funcs += "\t}\n";
	}

	let string = 
	"//\n"+
	"//  SolanaSDK+Methods.swift\n"+
	"//  SolanaSwift\n"+
	"//\n"+
	"//  Created by Chung Tran on 10/27/20.\n"+
	"//\n"+
	"// NOTE: THIS FILE IS GENERATED FROM APIGEN PACKAGE, DO NOT MAKE CHANGES DIRECTLY INTO IT, PLEASE EDIT METHODS.JSON AND methodsGen.js TO MAKE CHANGES (IN ../APIGen FOLDER)\n\n"+
	"import Foundation\n"+
	"import RxSwift\n"+
	"\n"+
	"public extension SolanaSDK {\n"+funcs+"}"

	fs.writeFileSync('../Classes/SolanaSDK+Methods.swift', string)
}