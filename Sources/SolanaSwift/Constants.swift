//
//  File.swift
//
//
//  Created by Giang Long Tran on 13.01.2023.
//

import Foundation

public enum Constants {
    public static let packageDataSize: Int = 1280 - 40 - 8
    public static let versionPrefixMask: UInt8 = 0x7f
    
    public static let signatureLength = 64
    public static let defaultSignature = Data(repeating: 0, count: 64)
}
