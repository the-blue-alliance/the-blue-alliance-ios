import Foundation

// "12.34" - what `%.2f` gave, with the user's decimal separator.
extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    static var twoDecimals: Self { .number.precision(.fractionLength(2)).grouping(.never) }
}

extension FormatStyle where Self == FloatingPointFormatStyle<Float> {
    static var twoDecimals: Self { .number.precision(.fractionLength(2)).grouping(.never) }
}
