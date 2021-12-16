import Foundation

final class CustomStream: NSObject {
    let bytes: [UInt8]
    let count: Int

    var offset: Int = 0

    init(data: Data) {
        self.bytes = data.bytes
        self.count = data.count
    }

    func readByte() -> UInt8? {
        if offset >= bytes.count {
            return nil
        }

        let byte = bytes[offset]

        offset += 1

        return byte
    }

    func unread() {
        offset -= 1
    }

    func readBytes(with byte: UInt8, and n: Int) -> [UInt8]? {
        var result = [UInt8]()

        for _ in 1...n {
            guard let lastByte = readByte() else {
                return nil
            }

            if lastByte == byte {
                return result
            } else {
                result.append(lastByte)
            }
        }
        

        return nil
    }

    func readBytes(with n: Int) -> [UInt8]? {
        var result = [UInt8]()

        for _ in 1...n {
            guard let lastByte = readByte() else {
                return nil
            }

            result.append(lastByte)
        }

        return result
    }

    func readByteEqual(byte: UInt8) -> Bool {
        guard let lastByte = readByte() else {
            return false
        }

        // Compare the byte with the expected one
        return lastByte == byte
    }

    func skipBytesDelim(byte: UInt8) {
        while true {
            guard let lastByte = readByte() else {
                return
            }

            if lastByte != byte {
                unread()
                return
            }
        }
    }

    func skipBytesNumber(n: Int) {
        for _ in 1...n {
            _  = readByte()
        }
    }

    func getLastBytes() -> [UInt8] {
        return bytes.suffix(count - offset)
    }
}
