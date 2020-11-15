//
//  ASKBase58.swift
//  AskCoin-HD
//
//  Created by 仇弘扬 on 2017/8/16.
//  Copyright © 2017年 askcoin. All rights reserved.
//

import Foundation

struct ASKBase58 {
	
	static let dec58 = BInt(58)
	static let dec0 = BInt(0)
	static let alphabet = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
	
	static func encode(data: Data) -> String {
		
		let checksum = data.ask_BTCHash256()
		let tmp = data + checksum[0...3]
		
		var dec = BInt(hex: tmp.toHexString())
		
		var results = Array<String>()
		while dec > dec0 {
			
			let rem = dec % dec58
			dec = dec / dec58
			
			if let index = rem.toInt() {
				results.insert(String(alphabet[index]), at: 0)
			}
			
		}
		
		// replace leading char '0' with '1'
		for char in results {
			if char == "0" {
                let index = results.firstIndex(of: char)!
				results.replaceSubrange(index...index + 1, with: ["1"])
			}
			else
			{
				break
			}
		}
		
		let result = results.joined()
		
		return result
	}
}
