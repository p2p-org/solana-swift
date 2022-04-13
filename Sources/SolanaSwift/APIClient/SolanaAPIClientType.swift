//
//  File.swift
//  
//
//  Created by Chung Tran on 13/04/2022.
//

import Foundation

public protocol SolanaAPIClientType: AnyObject {
    associatedtype HTTPMethod
    associatedtype Error: Swift.Error
}
