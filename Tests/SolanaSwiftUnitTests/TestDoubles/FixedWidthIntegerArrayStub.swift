import Foundation

extension Array where Element: FixedWidthInteger {
    enum StubFactory {
        static func make(length: UInt, range: Range<Element> = Element.min ..< Element.max) -> [Element] {
            (0 ..< length).map { _ in .random(in: range) }
        }
    }
}
