import Foundation

extension String {
    /**
     Searches for a regex pattern in `self` and returns the first
     full string match or the matched capture group if the `group`
     argument is passed.
     - Parameter pattern: The regex pattern to match.
     - Parameter group: The capture group to return. Defaults to
                     the full match.
     - Returns: The first matched string if it exists; nil otherwise.
     */
    func match(_ pattern: String, group: Int = 0) -> String? {
        let pattern = try! NSRegularExpression(pattern: pattern)

        guard let match = pattern.firstMatch(
            in: self,
            range: NSRange(location: 0, length: utf8.count)
        ) else {
            return nil
        }

        var captureGroups = [String]()

        for i in 0..<match.numberOfRanges {
            captureGroups.append(
                (self as NSString).substring(
                    with: match.range(at: i)
                )
            )
        }

        return captureGroups[group]
    }
}
