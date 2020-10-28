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
		let customCodingKeys = model.customCodingKeys;
		if (customCodingKeys) {
			structs += "\n\t\tprivate enum CodingKeys : String, CodingKey {\n"
			for (const [key, value] of Object.entries(model.customCodingKeys)) {
				structs += "\t\t\tcase "+key+" = \""+value+"\"\n";
			}
			structs += "\t\t}\n"
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
	"public extension SolanaSDK {\n"+structs+"}"

	fs.writeFileSync('../Classes/Models/SolanaSDK+Response.swift', string);
}