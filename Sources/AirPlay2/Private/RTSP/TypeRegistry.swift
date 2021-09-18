import Foundation

class TypeRegistry {
    private var typeMap = [Int: String]()
    private var tagMap = [String: Int]()
    private var tagIndex = 0

    func registerContentType(_ type: String) {
        createTag(for: type)
    }

    func tag(for contentType: String) -> Int? {
        return tagMap[contentType]
    }

    func contentType(for tag: Int) -> String? {
        return typeMap[tag]
    }

    private func createTag(for type: String) {
        tagMap[type] = tagIndex
        typeMap[tagIndex] = type
        tagIndex += 1
    }
}
