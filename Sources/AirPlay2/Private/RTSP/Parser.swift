import Foundation

protocol Parser {
    init?(data: Data)
    func parse() -> [String: AnyHashable]
}
