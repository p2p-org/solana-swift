//
//  Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 24/08/2021.
//

import Foundation

extension BInt {
    /// Shift-right
    /// - Parameters:
    ///   - bits: Number
    ///   - hint: lowest bit before trailing zeroes
    ///   - extended: if `extended` is present - it will be filled with destroyed bits
    /// - Returns: BInt
    func ushrn(bits: UInt, hint: UInt? = nil, extended: BInt? = nil) -> Self {
        var words = self.words
        var length = UInt(words.count)
        
        var h: UInt = 0
        if let hint = hint {
            h = (hint - (hint % 26)) / 26
        }
        
        let r: UInt = bits % 26
        let s: UInt = min((bits - r) / 26, length)
        let mask: UInt = UInt(0x3ffffff ^ ((0x3ffffff >>> Int(r)) << r))
        
        h -= s
        h = max(0, h)
        
        // Extended mode, copy masked part
        var maskedWords = extended?.words
        if maskedWords != nil {
            let sa = Int(s)
            for i in 0..<sa {
                maskedWords![i] = words[i]
            }
        }
        
        if s == 0 {
            // No-op, we should not move anything at all
        } else if length > s {
            length -= s
            let lengtha = Int(length)
            for i in 0..<lengtha {
                words[i] = words[i+Int(s)]
            }
        } else {
            words = [0]
            length = 1
        }
        
        var carry: UInt = 0
        
        var i = length - 1
        while i >= 0 && (carry != 0 || i >= h) {
            let word = words[Int(i)] | 0
            i -= 1
            words[Int(i)] = (carry << (26 - r)) | UInt((Int(word) >>> Int(r)))
            carry = word & UInt(mask)
        }
        
        // Push carried bits as a mask
        if maskedWords != nil,
           carry != 0
        {
            maskedWords![maskedWords!.count+1] = carry
        }
        
        if length == 0 {
            words[0] = 0
            length = 1
        }
        
        return BInt(limbs: words.map {Limb($0)})
    }
}
