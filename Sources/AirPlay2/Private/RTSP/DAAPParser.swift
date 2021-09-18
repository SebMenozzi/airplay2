import Foundation

class DAAPParser: Parser {
    private var data: Data
    private var offset = 0

    required init?(data: Data) {
        self.data = data
    }

    func parse() -> [String: AnyHashable] {
        var parsed = [String: AnyHashable]()

        while hasBytesAvailable {
            let tag = stringValue(from: readBytes(4))

            // marks start of data
            if tag == "mlit" {
                advance(byBytes: 4)
                continue
            }

            let length = intValue(from: readBytes(4))
            switch tag {
                case "asal":
                    parsed["album"] = stringValue(from: readBytes(length))
                case "asar":
                    parsed["artist"] = stringValue(from: readBytes(length))
                case "minm":
                    parsed["name"] = stringValue(from: readBytes(length))
                case "caps":
                    parsed["isPlaying"] = (byteValue(from: readBytes(1)) == 1)
                default:
                    // skip tags we're not interested in
                    advance(byBytes: length)
            }
        }

        return parsed
    }

    private var hasBytesAvailable: Bool {
        return offset < data.count
    }

    private func advance(byBytes bytes: Int) {
        offset += bytes
    }

    private func readBytes(_ bytes: Int) -> Data {
        assert(offset + bytes <= data.count)

        let range = offset..<offset + bytes

        offset += bytes

        return data.subdata(in: range)
    }

    private func stringValue(from data: Data) -> String {
        let value = String(data: data, encoding: .utf8) ?? ""

        return value
    }

    private func intValue(from data: Data) -> Int {
        assert(data.count == 4)

        let value: Int32 = data.withUnsafeBytes { $0.load(as: Int32.self) }

        return Int(value.bigEndian)
    }

    private func byteValue(from data: Data) -> UInt8 {
        assert(data.count == 1)

        let value: UInt8 = data.withUnsafeBytes { $0.load(as: UInt8.self) }

        return value
    }
}
