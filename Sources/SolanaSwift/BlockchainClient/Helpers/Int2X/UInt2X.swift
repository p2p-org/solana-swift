import Accelerate.vecLib
import Foundation

public typealias UInt1X = FixedWidthInteger & BinaryInteger & UnsignedInteger & Codable

public struct UInt2X<Word: UInt1X>: Hashable, Codable {
    public typealias IntegerLiteralType = UInt64
    public typealias Magnitude = UInt2X
    public typealias Words = [Word.Words.Element]
    public typealias Stride = Int
    // internally it is least significant word first to make Accelerate happy
    public var lo: Word = 0
    public var hi: Word = 0
    public init(hi: Word, lo: Word) { (self.hi, self.lo) = (hi, lo) }
    public init(_ source: UInt2X) { (hi, lo) = (source.hi, source.lo) }
}

// Swift bug?
// auto-generated == incorrectly reports
// UInt2X(hi:nonzero, lo:0) == 0 is true
public extension UInt2X {
    static func == (_ lhs: UInt2X, _ rhs: UInt2X) -> Bool {
        lhs.hi == rhs.hi && lhs.lo == rhs.lo
    }
}

extension UInt2X: ExpressibleByIntegerLiteral {
    public static var isSigned: Bool { false }
    public static var bitWidth: Int {
        Word.bitWidth * 2
    }

    public static var min: UInt2X { UInt2X(hi: Word.min, lo: Word.min) }
    public static var max: UInt2X { UInt2X(hi: Word.max, lo: Word.max) }
    public init(_ source: Word) {
        (hi, lo) = (0, source)
    }

    public init?<T>(exactly source: T) where T: BinaryInteger {
        guard source.bitWidth <= UInt2X.bitWidth || source <= T(UInt2X.max) else {
            return nil
        }
        self.init(source)
    }

    public init<T>(_ source: T) where T: BinaryInteger {
        hi = Word(source.magnitude >> Word.bitWidth)
        lo = Word(truncatingIfNeeded: source.magnitude)
    }

    public init?<T>(exactly source: T) where T: BinaryFloatingPoint {
        print("\(#line)", source)
        guard source.sign != .minus else { return nil }
        guard source.exponent < UInt2X.bitWidth else { return nil }
        self = UInt2X(source.significandBitPattern | (1 << T.significandBitCount))
        self <<= Int(source.exponent) - T.significandBitCount
    }

    public init<T>(_ source: T) where T: BinaryFloatingPoint {
        guard let result = UInt2X(exactly: source) else {
            fatalError("Not enough bits to represent a signed value")
        }
        self = result
    }

    // alway succeeds
    public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
        hi = Word(truncatingIfNeeded: source.magnitude >> Word.bitWidth)
        lo = Word(truncatingIfNeeded: source.magnitude)
    }

    // alway succeeds
    public init<T: BinaryInteger>(clamping source: T) {
        self = UInt2X(exactly: source) ?? UInt2X.max
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

// Comparable
extension UInt2X: Comparable {
    public static func < (lhs: UInt2X, rhs: UInt2X) -> Bool {
        lhs.hi < rhs.hi ? true : lhs.hi == rhs.hi && lhs.lo < rhs.lo
    }
}

// Accelerate support
// careful with the significance order.  Accerelate is least significant first.
#if os(macOS) || os(iOS)
    import Accelerate
#endif
public enum Int2XConfig {
    #if os(macOS) || os(iOS)
        public static var useAccelerate = true
    #else
        public static let useAccelerate = false
    #endif
}

// numeric
extension UInt2X: Numeric {
    public var magnitude: UInt2X {
        self
    }

    // unary operators
    public static prefix func ~ (_ value: UInt2X) -> UInt2X {
        UInt2X(hi: ~value.hi, lo: ~value.lo)
    }

    public static prefix func + (_ value: UInt2X) -> UInt2X {
        value
    }

    public static prefix func - (_ value: UInt2X) -> UInt2X {
        ~value &+ 1 // two's complement
    }

    // additions
    public func addingReportingOverflow(_ other: UInt2X) -> (partialValue: UInt2X, overflow: Bool) {
        guard self != 0 else { return (other, false) }
        guard other != 0 else { return (self, false) }
        #if os(macOS)
            if Int2XConfig.useAccelerate {
                // print("line \(#line):Accelerated! \(UInt2X.self)(\(self)).addingReportingOverflow(\(other))")
                switch self {
                case is UInt128:
                    var a = unsafeBitCast((self, vU128()), to: vU256.self)
                    var b = unsafeBitCast((other, vU128()), to: vU256.self)
                    var ab = vU256()
                    vU256Add(&a, &b, &ab)
                    let (r, o) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (r, o != 0)
                case is UInt256:
                    var a = unsafeBitCast((self, vU256()), to: vU512.self)
                    var b = unsafeBitCast((other, vU256()), to: vU512.self)
                    var ab = vU512()
                    vU512Add(&a, &b, &ab)
                    let (r, o) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (r, o != 0)
                case is UInt512:
                    var a = unsafeBitCast((self, vU512()), to: vU1024.self)
                    var b = unsafeBitCast((other, vU512()), to: vU1024.self)
                    var ab = vU1024()
                    vU1024Add(&a, &b, &ab)
                    let (r, o) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (r, o != 0)
                default:
                    break
                }
            }
        #endif
        var of = false
        let (lv, lf) = lo.addingReportingOverflow(other.lo)
        var (hv, uo) = hi.addingReportingOverflow(other.hi)
        if lf {
            (hv, of) = hv.addingReportingOverflow(1)
        }
        return (partialValue: UInt2X(hi: hv, lo: lv), overflow: uo || of)
    }

    public func addingReportingOverflow(_ other: Word) -> (partialValue: UInt2X, overflow: Bool) {
        return addingReportingOverflow(UInt2X(hi: 0, lo: other))
    }

    public static func &+ (_ lhs: UInt2X, _ rhs: UInt2X) -> UInt2X {
        lhs.addingReportingOverflow(rhs).partialValue
    }

    public static func + (_ lhs: UInt2X, _ rhs: UInt2X) -> UInt2X {
        precondition(~lhs >= rhs, "\(lhs) + \(rhs): Addition overflow!")
        return lhs &+ rhs
    }

    public static func + (_ lhs: UInt2X, _ rhs: Word) -> UInt2X {
        lhs + UInt2X(hi: 0, lo: rhs)
    }

    public static func + (_ lhs: Word, _ rhs: UInt2X) -> UInt2X {
        UInt2X(hi: 0, lo: lhs) + rhs
    }

    public static func += (lhs: inout UInt2X, rhs: UInt2X) {
        lhs = lhs + rhs
    }

    public static func += (lhs: inout UInt2X, rhs: Word) {
        lhs = lhs + rhs
    }

    // subtraction
    public func subtractingReportingOverflow(_ other: UInt2X) -> (partialValue: UInt2X, overflow: Bool) {
        guard self != other else { return (0, false) }
        guard self != 0 else { return (-other, false) }
        guard other != 0 else { return (+self, false) }
        #if os(macOS)
            if Int2XConfig.useAccelerate {
                // print("line \(#line):Accelerated! \(UInt2X.self)(\(self)).subtractingReportingOverflow(\(other))")
                switch self {
                case is UInt128:
                    var a = unsafeBitCast((self, vU128()), to: vU256.self)
                    var b = unsafeBitCast((other, vU128()), to: vU256.self)
                    var ab = vU256()
                    vU256Sub(&a, &b, &ab)
                    let (r, o) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (r, o != 0)
                case is UInt256:
                    var a = unsafeBitCast((self, vU256()), to: vU512.self)
                    var b = unsafeBitCast((other, vU256()), to: vU512.self)
                    var ab = vU512()
                    vU512Sub(&a, &b, &ab)
                    let (r, o) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (r, o != 0)
                case is UInt512:
                    var a = unsafeBitCast((self, vU512()), to: vU1024.self)
                    var b = unsafeBitCast((other, vU512()), to: vU1024.self)
                    var ab = vU1024()
                    vU1024Sub(&a, &b, &ab)
                    let (r, o) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (r, o != 0)
                default:
                    break
                }
            }
        #endif
        return addingReportingOverflow(-other)
    }

    public func subtractingReportingOverflow(_ other: Word) -> (partialValue: UInt2X, overflow: Bool) {
        return subtractingReportingOverflow(UInt2X(hi: 0, lo: other))
    }

    public static func &- (_ lhs: UInt2X, _ rhs: UInt2X) -> UInt2X {
        lhs.subtractingReportingOverflow(rhs).partialValue
    }

    public static func - (_ lhs: UInt2X, _ rhs: UInt2X) -> UInt2X {
        precondition(lhs >= rhs, "\(lhs) - \(rhs): Subtraction overflow!")
        return lhs &- rhs
    }

    public static func - (_ lhs: UInt2X, _ rhs: Word) -> UInt2X {
        lhs - UInt2X(hi: 0, lo: rhs)
    }

    public static func - (_ lhs: Word, _ rhs: UInt2X) -> UInt2X {
        UInt2X(hi: 0, lo: lhs) - rhs
    }

    public static func -= (lhs: inout UInt2X, rhs: UInt2X) {
        lhs = lhs - rhs
    }

    public static func -= (lhs: inout UInt2X, rhs: Word) {
        lhs = lhs - rhs
    }

    // multiplication
    public func multipliedHalfWidth(by other: Word) -> (high: UInt2X, low: Magnitude) {
        guard self != 0 else { return (0, 0) }
        guard other != 0 else { return (0, 0) }
        let l = lo.multipliedFullWidth(by: other)
        let h = hi.multipliedFullWidth(by: other)
        let r0 = Word(l.low)
        let (r1, o1) = Word(h.low).addingReportingOverflow(Word(l.high))
        let r2 = Word(h.high) &+ (o1 ? 1 : 0) // will not overflow
        return (UInt2X(hi: 0, lo: r2), UInt2X(hi: r1, lo: r0))
    }

    public func multipliedFullWidth(by other: UInt2X) -> (high: UInt2X, low: Magnitude) {
        guard self != 0 else { return (0, 0) }
        guard other != 0 else { return (0, 0) }
        #if os(macOS)
            if Int2XConfig.useAccelerate {
                // print("line \(#line):Accelerated! \(UInt2X.self)(\(self)).multipliedFullWidth(by:\(other))")
                switch self {
                case is UInt128:
                    var a = unsafeBitCast(self, to: vU128.self)
                    var b = unsafeBitCast(other, to: vU128.self)
                    var ab = vU256()
                    vU128FullMultiply(&a, &b, &ab)
                    let (l, h) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (h, l)
                case is UInt256:
                    var a = unsafeBitCast(self, to: vU256.self)
                    var b = unsafeBitCast(other, to: vU256.self)
                    var ab = vU512()
                    vU256FullMultiply(&a, &b, &ab)
                    let (l, h) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (h, l)
                case is UInt512:
                    var a = unsafeBitCast(self, to: vU512.self)
                    var b = unsafeBitCast(other, to: vU512.self)
                    var ab = vU1024()
                    vU512FullMultiply(&a, &b, &ab)
                    let (l, h) = unsafeBitCast(ab, to: (UInt2X, UInt2X).self)
                    return (h, l)
                default:
                    break
                }
            }
        #endif
        let l = multipliedHalfWidth(by: other.lo)
        let hs = multipliedHalfWidth(by: other.hi)
        let h = (high: UInt2X(hi: hs.high.lo, lo: hs.low.hi), low: UInt2X(hi: hs.low.lo, lo: 0))
        let (rl, ol) = h.low.addingReportingOverflow(l.low)
        let rh = h.high &+ l.high &+ (ol ? 1 : 0) // will not overflow
        return (rh, rl)
    }

    public func multipliedReportingOverflow(by other: UInt2X) -> (partialValue: UInt2X, overflow: Bool) {
        guard self != 0 else { return (0, false) }
        guard other != 0 else { return (0, false) }
        let result = multipliedFullWidth(by: other)
        return (result.low, result.high > 0)
    }

    public static func &* (lhs: UInt2X, rhs: UInt2X) -> UInt2X {
        lhs.multipliedReportingOverflow(by: rhs).partialValue
    }

    public static func &* (lhs: UInt2X, rhs: Word) -> UInt2X {
        lhs.multipliedHalfWidth(by: rhs).low
    }

    public static func &* (lhs: Word, rhs: UInt2X) -> UInt2X {
        rhs.multipliedHalfWidth(by: lhs).low
    }

    public static func * (lhs: UInt2X, rhs: UInt2X) -> UInt2X {
        let result = lhs.multipliedReportingOverflow(by: rhs)
        precondition(!result.overflow, "Multiplication overflow!")
        return result.partialValue
    }

    public static func * (lhs: UInt2X, rhs: Word) -> UInt2X {
        let result = lhs.multipliedHalfWidth(by: rhs)
        precondition(result.high == 0, "Multiplication overflow!")
        return result.low
    }

    public static func * (lhs: Word, rhs: UInt2X) -> UInt2X {
        let result = rhs.multipliedHalfWidth(by: lhs)
        precondition(result.high == 0, "Multiplication overflow!")
        return result.low
    }

    public static func *= (lhs: inout UInt2X, rhs: UInt2X) {
        lhs = lhs * rhs
    }

    public static func *= (lhs: inout UInt2X, rhs: Word) {
        lhs = lhs * rhs
    }
}

// bitshifts
public extension UInt2X {
    func rShifted(_ width: Int) -> UInt2X {
        if width < 0 { return lShifted(-width) }
        if width == 0 { return self }
        if width == Word.bitWidth { return UInt2X(hi: 0, lo: hi) }
        #if os(macOS)
            if Int2XConfig.useAccelerate {
                // print("line \(#line):Accelerated! \(UInt2X.self)(\(self)).rShifted(\(other))")
                switch self {
                case is UInt128:
                    var a = unsafeBitCast((self, vU128()), to: vU256.self)
                    var r = vU256()
                    vLR256Shift(&a, UInt32(width), &r)
                    return unsafeBitCast(r, to: (UInt2X, UInt2X).self).0
                case is UInt256:
                    var a = unsafeBitCast(self, to: vU256.self)
                    var r = vU256()
                    vLR256Shift(&a, UInt32(width), &r)
                    return unsafeBitCast(r, to: UInt2X.self)
                case is UInt512:
                    var a = unsafeBitCast(self, to: vU512.self)
                    var r = vU512()
                    vLR512Shift(&a, UInt32(width), &r)
                    return unsafeBitCast(r, to: UInt2X.self)
                case is UInt1024:
                    var a = unsafeBitCast(self, to: vU1024.self)
                    var r = vU1024()
                    vLR1024Shift(&a, UInt32(width), &r)
                    return unsafeBitCast(r, to: UInt2X.self)
                default:
                    break
                }
            }
        #endif
        if Word.bitWidth < width {
            return UInt2X(hi: 0, lo: hi >> (width - Word.bitWidth))
        } else {
            let mask = Word((1 << width) &- 1)
            let carry = (hi & mask) << (Word.bitWidth - width)
            return UInt2X(hi: hi >> width, lo: carry | lo >> width)
        }
    }

    func lShifted(_ width: Int) -> UInt2X {
        if width < 0 { return rShifted(-width) }
        if width == 0 { return self }
        if width == Word.bitWidth { return UInt2X(hi: lo, lo: 0) }
        #if os(macOS)
            if Int2XConfig.useAccelerate {
                // print("line \(#line):Accelerated! \(UInt2X.self)(\(self)).lShifted(\(other))")
                switch self {
                case is UInt128:
                    var a = unsafeBitCast((self, vU128()), to: vU256.self)
                    var r = vU256()
                    vLL256Shift(&a, UInt32(width), &r)
                    return unsafeBitCast(r, to: (UInt2X, UInt2X).self).0
                case is UInt256:
                    var a = unsafeBitCast(self, to: vU256.self)
                    var r = vU256()
                    vLL256Shift(&a, UInt32(width), &r)
                    return unsafeBitCast(r, to: UInt2X.self)
                case is UInt512:
                    var a = unsafeBitCast(self, to: vU512.self)
                    var r = vU512()
                    vLL512Shift(&a, UInt32(width), &r)
                    return unsafeBitCast(r, to: UInt2X.self)
                case is UInt1024:
                    var a = unsafeBitCast(self, to: vU1024.self)
                    var r = vU1024()
                    vLL1024Shift(&a, UInt32(width), &r)
                    return unsafeBitCast(r, to: UInt2X.self)
                default:
                    break
                }
            }
        #endif
        if Word.bitWidth < width {
            return UInt2X(hi: lo << (width - Word.bitWidth), lo: 0)
        } else {
            let carry = lo >> (Word.bitWidth - width)
            return UInt2X(hi: hi << width | carry, lo: lo << width)
        }
    }

    static func &>> (_ lhs: UInt2X, _ rhs: UInt2X) -> UInt2X {
        lhs.rShifted(Int(rhs.lo))
    }

    static func &>>= (_ lhs: inout UInt2X, _ rhs: UInt2X) {
        return lhs = lhs &>> rhs
    }

    static func &<< (_ lhs: UInt2X, _ rhs: UInt2X) -> UInt2X {
        lhs.lShifted(Int(rhs.lo))
    }

    static func &<<= (_ lhs: inout UInt2X, _ rhs: UInt2X) {
        return lhs = lhs &<< rhs
    }
}

// division, which is rather tough
public extension UInt2X {
    func quotientAndRemainder(dividingBy other: Word) -> (quotient: UInt2X, remainder: UInt2X) {
        precondition(other != 0, "division by zero!")
        let (qh, rh) = hi.quotientAndRemainder(dividingBy: other)
        let (ql, rl) = other.dividingFullWidth((high: rh, low: lo.magnitude))
        return (UInt2X(hi: qh, lo: ql), UInt2X(rl))
    }

    func quotientAndRemainder(dividingBy other: UInt2X) -> (quotient: UInt2X, remainder: UInt2X) {
        precondition(other != 0, "division by zero!")
        guard other != self else { return (1, 0) }
        guard other < self else { return (0, self) }
        guard other.hi != 0 else {
            return quotientAndRemainder(dividingBy: other.lo)
        }
        #if os(macOS)
            if Int2XConfig.useAccelerate {
                // print("line \(#line):Accelerated! \(UInt2X.self)(\(self)).quotientAndRemainder(dividingBy:\(other))")
                switch self {
                case is UInt128:
                    var a = unsafeBitCast((self, vU128()), to: vU256.self)
                    var b = unsafeBitCast((other, vU128()), to: vU256.self)
                    var (q, r) = (vU256(), vU256())
                    vU256Divide(&a, &b, &q, &r)
                    let qq = unsafeBitCast(q, to: (UInt2X, UInt2X).self).0
                    let rr = unsafeBitCast(r, to: (UInt2X, UInt2X).self).0
                    return (qq, rr)
                case is UInt256:
                    var a = unsafeBitCast(self, to: vU256.self)
                    var b = unsafeBitCast(other, to: vU256.self)
                    var (q, r) = (vU256(), vU256())
                    vU256Divide(&a, &b, &q, &r)
                    let qq = unsafeBitCast(q, to: UInt2X.self)
                    let rr = unsafeBitCast(r, to: UInt2X.self)
                    return (qq, rr)
                case is UInt512:
                    var a = unsafeBitCast(self, to: vU512.self)
                    var b = unsafeBitCast(other, to: vU512.self)
                    var (q, r) = (vU512(), vU512())
                    vU512Divide(&a, &b, &q, &r)
                    let qq = unsafeBitCast(q, to: UInt2X.self)
                    let rr = unsafeBitCast(r, to: UInt2X.self)
                    return (qq, rr)
                case is UInt1024:
                    var a = unsafeBitCast(self, to: vU1024.self)
                    var b = unsafeBitCast(other, to: vU1024.self)
                    var (q, r) = (vU1024(), vU1024())
                    vU1024Divide(&a, &b, &q, &r)
                    let qq = unsafeBitCast(q, to: UInt2X.self)
                    let rr = unsafeBitCast(r, to: UInt2X.self)
                    return (qq, rr)
                default:
                    break
                }
            }
        #endif
        #if false
            if Word.bitWidth * 2 <= UInt64.bitWidth { // cheat when we can :-)
                let divided = (UInt64(hi) << Word.bitWidth) + UInt64(lo)
                let divider = (UInt64(other.hi) << Word.bitWidth) + UInt64(other.lo)
                let (q, r) = divided.quotientAndRemainder(dividingBy: divider)
                return (UInt2X(q), UInt2X(r))
            }
        #endif
        // slow but steady bitwise long division
        // print("line \(#line): \(UInt2X.self)(\(self)).quotientAndRemainder(dividingBy:\(other))")
        var (q, r) = (UInt2X(0), UInt2X(0))
        for i in (0 ..< UInt2X.bitWidth).reversed() {
            r <<= 1
            r |= (self >> i) & 1
            if other <= r {
                r -= other
                q |= (1 << i)
            }
        }
        return (q, r)
    }

    static func / (_ lhs: UInt2X, rhs: UInt2X) -> UInt2X {
        lhs.quotientAndRemainder(dividingBy: rhs).quotient
    }

    static func /= (_ lhs: inout UInt2X, rhs: UInt2X) {
        lhs = lhs / rhs
    }

    static func % (_ lhs: UInt2X, rhs: UInt2X) -> UInt2X {
        lhs.quotientAndRemainder(dividingBy: rhs).remainder
    }

    static func %= (_ lhs: inout UInt2X, rhs: UInt2X) {
        lhs = lhs % rhs
    }

    func dividedReportingOverflow(by other: UInt2X) -> (partialValue: UInt2X, overflow: Bool) {
        return (self / other, false)
    }

    func remainderReportingOverflow(dividingBy other: UInt2X) -> (partialValue: UInt2X, overflow: Bool) {
        return (self % other, false)
    }

    func dividingFullWidth(_ dividend: (high: UInt2X, low: Magnitude)) -> (quotient: UInt2X, remainder: UInt2X) {
        precondition(self != 0, "division by zero!")
        guard dividend.high != 0 else { return dividend.low.quotientAndRemainder(dividingBy: self) }
        #if os(macOS)
            if Int2XConfig.useAccelerate {
                // print("line \(#line):Accelerated! \(UInt2X.self)(\(self)).dividingFullWidth(\(dividend))")
                switch self {
                case is UInt128:
                    var a = unsafeBitCast((dividend.low, dividend.high), to: vU256.self)
                    var b = unsafeBitCast((self, vU128()), to: vU256.self)
                    var (q, r) = (vU256(), vU256())
                    vU256Divide(&a, &b, &q, &r)
                    let qq = unsafeBitCast(q, to: (UInt2X, UInt2X).self).0
                    let rr = unsafeBitCast(r, to: (UInt2X, UInt2X).self).0
                    return (qq, rr)
                case is UInt256:
                    var a = unsafeBitCast((dividend.low, dividend.high), to: vU512.self)
                    var b = unsafeBitCast((self, vU256()), to: vU512.self)
                    var (q, r) = (vU512(), vU512())
                    vU512Divide(&a, &b, &q, &r)
                    let qq = unsafeBitCast(q, to: (UInt2X, UInt2X).self).0
                    let rr = unsafeBitCast(r, to: (UInt2X, UInt2X).self).0
                    return (qq, rr)
                case is UInt512:
                    var a = unsafeBitCast((dividend.low, dividend.high), to: vU1024.self)
                    var b = unsafeBitCast((self, vU512()), to: vU1024.self)
                    var (q, r) = (vU1024(), vU1024())
                    vU1024Divide(&a, &b, &q, &r)
                    let qq = unsafeBitCast(q, to: (UInt2X, UInt2X).self).0
                    let rr = unsafeBitCast(r, to: (UInt2X, UInt2X).self).0
                    return (qq, rr)
                default:
                    break
                }
            }
        #endif
        // slow but steady bitwise long division
        // print("line \(#line): \(UInt2X.self)(\(self)).dividingFullWidth(\(dividend))")
        var (q, r) = (UInt2X(0), dividend.high % self)
        for i in (0 ..< UInt2X.bitWidth).reversed() {
            r <<= 1
            r |= (dividend.low >> i) & 1
            if self <= r {
                r -= self
                q |= (1 << i)
            }
        }
        return (q, r)
    }
}

// UInt2X -> String
extension UInt2X: CustomStringConvertible, CustomDebugStringConvertible {
    public func toString(radix: Int = 10, uppercase: Bool = false) -> String {
        precondition((2 ... 36) ~= radix, "radix must be within the range of 2-36.")
        if self == 0 { return "0" }
        if hi == 0 { return String(lo, radix: radix, uppercase: uppercase) }
        if radix == 16 || radix == 4 || radix == 2 { // time-saver
            let sl = String(lo, radix: radix, uppercase: uppercase)
            let dCount = Word.bitWidth / (radix == 16 ? 4 : radix == 4 ? 2 : 1)
            let zeros = [Character](repeating: "0", count: dCount - sl.count)
            return String(hi, radix: radix, uppercase: uppercase) + String(zeros) + sl
        }
        let digits = uppercase
            ? Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            : Array("0123456789abcdefghijklmnopqrstuvwxyz")
        #if false // slow but steady digit by digit conversion
            var result = [Character]()
            var qr = (quotient: self, remainder: UInt2X(0))
            repeat {
                qr = qr.quotient.quotientAndRemainder(dividingBy: Word(radix))
                result.append(digits[Int(qr.remainder.lo)])
            } while qr.quotient != UInt2X(0)
            return String(result.reversed())
        #else // faster n-digit-at-once conversion
            let base: UInt64 = [
                0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0xA8B8_B452_291F_E800, //  0 ~  3
                0x0000_0000_0000_0000, 0x6765_C793_FA10_0800, 0x41C2_1CB8_E100_0000, 0x3642_7987_5022_6200, //  4 ~  7
                0x8000_0000_0000_0000, 0xA8B8_B452_291F_E800, 0x8AC7_2304_89E8_0000, 0x4D28_CB56_C33F_A400, //  8 ~ 11
                0x1ECA_170C_0000_0000, 0x780C_7372_621B_D800, 0x1E39_A505_7D81_0000, 0x5B27_AC99_3DF9_7800, // 11 ~ 15
                0x0000_0000_0000_0000, 0x27B9_5E99_7E21_DA00, 0x5DA0_E1E5_3C5C_8000, 0xD2AE_3299_C1C4_B000, // 16 ~ 19
                0x16BC_C41E_9000_0000, 0x2D04_B7FD_D9C0_F000, 0x5658_597B_CAA2_4000, 0xA0E2_0737_3760_9000, // 20 ~ 23
                0x0C29_E980_0000_0000, 0x14AD_F4B7_3203_3500, 0x226E_D364_78BF_A000, 0x383D_9170_B85F_F800, // 24 ~ 27
                0x5A3C_23E3_9C00_0000, 0x8E65_1373_8812_2800, 0xDD41_BB36_D259_E000, 0x0AEE_5720_EE83_0680, // 28 ~ 31
                0x1000_0000_0000_0000, 0x1725_88AD_4F5F_0A00, 0x211E_44F7_D02C_1000, 0x2EE5_6725_F06E_5C00, // 32 ~ 35
                0x41C2_1CB8_E100_0000, // 36
            ][radix]
            let nlen = base.description.count - 1
            // print("base=",base)
            var qr = (quotient: self, remainder: UInt2X(0))
            var result = [UInt64]()
            repeat {
                qr = qr.quotient.quotientAndRemainder(dividingBy: UInt2X(base))
                result.append(UInt64(qr.remainder))
            } while qr.quotient != UInt2X(0)
            let firstDigit = result.removeLast()
            return String(firstDigit, radix: radix, uppercase: uppercase) + result.map {
                let s = String($0, radix: radix, uppercase: uppercase)
                return String([Character](repeating: "0", count: nlen - s.count)) + s
            }.reversed().joined()
        #endif
    }

    public var description: String {
        toString()
    }

    public var debugDescription: String {
        "0x" + toString(radix: 16)
    }
}

public extension StringProtocol {
    init?<Word>(_ source: UInt2X<Word>, radix: Int = 10, uppercase: Bool = false) {
        self.init(source.toString(radix: radix, uppercase: uppercase))
    }
}

// String <- UInt2X
extension UInt2X: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        if let result = UInt2X.fromString(value) {
            self = result
        }
    }

    internal static func fromString(_ value: String) -> UInt2X? {
        let radix = UInt2X.radixFromString(value)
        let source = radix == 10 ? value : String(value.dropFirst(2))
        return UInt2X(source, radix: radix)
    }

    internal static func radixFromString(_ string: String) -> Int {
        switch string.prefix(2) {
        case "0b": return 2
        case "0o": return 8
        case "0x": return 16
        default: return 10
        }
    }
}

// Int -> UInt2X
public extension Int {
    init<Word>(_ source: UInt2X<Word>) {
        self.init(bitPattern: UInt(source.hi << Word.bitWidth + source.lo))
    }
}

// Strideable
extension UInt2X: Strideable {
    public func distance(to other: UInt2X) -> Int {
        Int(other) - Int(self)
    }

    public func advanced(by n: Int) -> UInt2X {
        self + UInt2X(n)
    }
}

// BinaryInteger
extension UInt2X: BinaryInteger {
    public var bitWidth: Int {
        Word.bitWidth * 2
    }

    public var words: Words {
        Array(lo.words) + Array(hi.words)
    }

    public var trailingZeroBitCount: Int {
        hi == 0 ? lo.trailingZeroBitCount : hi.trailingZeroBitCount + Word.bitWidth
    }

    public static func &= (lhs: inout UInt2X, rhs: UInt2X) {
        lhs = UInt2X(hi: lhs.hi & rhs.hi, lo: lhs.lo & rhs.lo)
    }

    public static func |= (lhs: inout UInt2X, rhs: UInt2X) {
        lhs = UInt2X(hi: lhs.hi | rhs.hi, lo: lhs.lo | rhs.lo)
    }

    public static func ^= (lhs: inout UInt2X<Word>, rhs: UInt2X<Word>) {
        lhs = UInt2X(hi: lhs.hi ^ rhs.hi, lo: lhs.lo ^ rhs.lo)
    }

    public static func <<= <RHS>(lhs: inout UInt2X<Word>, rhs: RHS) where RHS: BinaryInteger {
        lhs = lhs.lShifted(Int(rhs))
    }

    public static func >>= <RHS>(lhs: inout UInt2X, rhs: RHS) where RHS: BinaryInteger {
        lhs = lhs.rShifted(Int(rhs))
    }
}

// FixedWidthInteger
extension UInt2X: FixedWidthInteger {
    public init(_truncatingBits _: UInt) {
        fatalError()
    }

    public var nonzeroBitCount: Int {
        hi.nonzeroBitCount + lo.nonzeroBitCount
    }

    public var leadingZeroBitCount: Int {
        hi == 0 ? lo.leadingZeroBitCount + Word.bitWidth : hi.leadingZeroBitCount
    }

    public var byteSwapped: UInt2X {
        UInt2X(hi: lo.byteSwapped, lo: hi.byteSwapped)
    }
}

// UnsignedInteger
extension UInt2X: UnsignedInteger {}

public typealias UInt128 = UInt2X<UInt64>
public typealias UInt256 = UInt2X<UInt128>
public typealias UInt512 = UInt2X<UInt256>
public typealias UInt1024 = UInt2X<UInt512>
