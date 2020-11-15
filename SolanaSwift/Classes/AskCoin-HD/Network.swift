//
//  ASKNetwork.swift
//  AskCoin-HD
//
//  Created by 仇弘扬 on 2017/8/16.
//  Copyright © 2017年 askcoin. All rights reserved.
//

import UIKit

enum NetworkType {
	case main
	case test
}

struct Network {
	
	var networkType: NetworkType = .main
	
	var isMainNet: Bool { get { return networkType == .main } }
	var isTestNet: Bool { get { return networkType == .test } }
	
}
