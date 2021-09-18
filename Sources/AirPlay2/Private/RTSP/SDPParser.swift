import Foundation

class SDPParser: Parser {
    private let description: String

    required init?(data: Data) {
        guard let description = String(
            data: data, encoding: .utf8) else { return nil }
        self.description = description
    }

    func parse() -> [String: AnyHashable] {
        let key = getAttributeData(from: description, attribute: "rsaaeskey")!
        let iv = getAttributeData(from: description, attribute: "aesiv")!

        return ["key": key, "iv": iv]
    }

    private func getAttributeData(from description: String, attribute: String) -> Data? {
        guard let value = description.match(
            "(a=\(attribute):)(\\S*)",
            group: 2
        ) else {
            return nil
        }

        return Data(base64Encoded: value)
    }
}
