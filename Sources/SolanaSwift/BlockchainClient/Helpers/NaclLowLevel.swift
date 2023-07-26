import Foundation

// https://github.com/miguelsandro/curve25519-swift/blob/master/axlsign.swift

infix operator >>>: BitwiseShiftPrecedence
func >>> (lhs: Int, rhs: Int) -> Int {
    let l = getInt32(Int64(lhs))
    let r = getInt32(Int64(rhs))
    return Int(Int32(bitPattern: UInt32(bitPattern: l) >> UInt32(r)))
}

func getInt32(_ value: Int64) -> Int32 {
    Int32(truncatingIfNeeded: value)
}

enum NaclLowLevel {
    // MARK: - Constants

    static var D = gf([0x78A3, 0x1359, 0x4DCA, 0x75EB,
                       0xD8AB, 0x4141, 0x0A4D, 0x0070,
                       0xE898, 0x7779, 0x4079, 0x8CC7,
                       0xFE73, 0x2B6F, 0x6CEE, 0x5203])
    static let I = gf([0xA0B0, 0x4A0E, 0x1B27, 0xC4EE,
                       0xE478, 0xAD2F, 0x1806, 0x2F43,
                       0xD7A7, 0x3DFB, 0x0099, 0x2B4D,
                       0xDF0B, 0x4FC1, 0x2480, 0x2B83])

    // MARK: - Methods

    static func gf() -> [Int64] {
        gf([0])
    }

    static func gf(_ ai: [Int64]) -> [Int64] {
        var r = [Int64](repeating: 0, count: 16)
        for i in 0 ..< ai.count {
            r[i] = ai[i]
        }
        return r
    }

    static func unpack25519(_ o: inout [Int64], _ n: [UInt8]) {
        for i in 0 ..< 16 {
            o[i] = Int64(n[2 * i]) + (Int64(n[2 * i + 1]) << 8) // *** R
        }
        o[15] = o[15] & 0x7FFF
    }

    static func A(_ o: inout [Int64], _ a: [Int64], _ b: [Int64]) {
        for i in 0 ..< 16 {
            o[i] = a[i] + b[i]
        }
    }

    static func Z(_ o: inout [Int64], _ a: [Int64], _ b: [Int64]) {
        for i in 0 ..< 16 {
            o[i] = a[i] - b[i]
        }
    }

    static func M(_ o: inout [Int64], _ a: [Int64], _ b: [Int64]) {
        var at = [Int64](repeating: 0, count: 32)
        var ab = [Int64](repeating: 0, count: 16)

        for i in 0 ..< 16 {
            ab[i] = b[i]
        }

        var v: Int64
        for i in 0 ..< 16 {
            v = a[i]
            for j in 0 ..< 16 {
                at[j + i] += v * ab[j]
            }
        }

        for i in 0 ..< 15 {
            at[i] += 38 * at[i + 16]
        }
        // t15 left as is
        // first car
        var c: Int64 = 1
        for i in 0 ..< 16 {
            v = at[i] + c + 65535
            c = Int64(floor(Double(v) / 65536.0))
            at[i] = v - c * 65536
        }
        at[0] += c - 1 + 37 * (c - 1)

        // second car
        c = 1
        for i in 0 ..< 16 {
            v = at[i] + c + 65535
            c = Int64(floor(Double(v) / 65536.0))
            at[i] = v - c * 65536
        }
        at[0] += c - 1 + 37 * (c - 1)

        for i in 0 ..< 16 {
            o[i] = at[i]
        }
    }

    static func S(_ o: inout [Int64], _ a: [Int64]) {
        M(&o, a, a)
    }

    static func pow2523(_ o: inout [Int64], _ i: [Int64]) {
        var c = gf()
        for a in 0 ..< 16 {
            c[a] = i[a]
        }
        for a in (0 ... 250).reversed() {
            S(&c, c)
            if a != 1 {
                M(&c, c, i)
            }
        }
        for a in 0 ..< 16 {
            o[a] = c[a]
        }
    }

    static func vn(_ x: [UInt8], _ xi: Int, _ y: [UInt8], _ yi: Int, _ n: Int) -> Int {
        var d: UInt8 = 0
        for i in 0 ..< n {
            d = d | (x[xi + i] ^ y[yi + i])
        }
        return (1 & ((Int(d) - 1) >>> 8)) - 1
    }

    static func crypto_verify_32(_ x: [UInt8], _ xi: Int, _ y: [UInt8], _ yi: Int) -> Int {
        vn(x, xi, y, yi, 32)
    }

    static func set25519(_ r: inout [Int64], _ a: [Int64]) {
        for i in 0 ..< 16 {
            r[i] = a[i] | 0
        }
    }

    static func car25519(_ o: inout [Int64]) {
        var v: Int64
        var c = 1
        for i in 0 ..< 16 {
            v = o[i] + Int64(c + 65535)
            c = Int(floor(Double(v) / 65536.0))
            o[i] = v - Int64(c * 65536)
        }
        o[0] += Int64(c - 1 + 37 * (c - 1))
    }

    static func sel25519(_ p: inout [Int64], _ q: inout [Int64], _ b: Int) {
        var t: Int64
        let c = Int64(~(b - 1))
        for i in 0 ..< 16 {
            t = c & (p[i] ^ q[i])
            p[i] = p[i] ^ t
            q[i] = q[i] ^ t
        }
    }

    static func pack25519(_ o: inout [UInt8], _ n: [Int64]) {
        var b: Int64
        var m = gf()
        var t = gf()

        for i in 0 ..< 16 {
            t[i] = n[i]
        }
        car25519(&t)
        car25519(&t)
        car25519(&t)

        for _ in 0 ... 1 {
            m[0] = t[0] - 0xFFED
            for i in 1 ... 14 {
                m[i] = t[i] - 0xFFFF - ((m[i - 1] >> 16) & 1)
                m[i - 1] = m[i - 1] & 0xFFFF
            }
            m[15] = t[15] - 0x7FFF - ((m[14] >> 16) & 1)
            b = (m[15] >> 16) & 1
            m[14] = m[14] & 0xFFFF
            sel25519(&t, &m, Int(1 - b))
        }
        for i in 0 ..< 16 {
            o[2 * i] = UInt8(t[i] & 0xFF) // *** R
            o[2 * i + 1] = UInt8(t[i] >> 8) // *** R
        }
    }

    static func neq25519(_ a: [Int64], _ b: [Int64]) -> Int {
        var c = [UInt8](repeating: 0, count: 32)
        var d = [UInt8](repeating: 0, count: 32)
        pack25519(&c, a)
        pack25519(&d, b)
        return crypto_verify_32(c, 0, d, 0)
    }
}
