import Foundation

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }

    func range(start: Int) -> Data {
        let stream = CustomStream(data: self)
        stream.skipBytesNumber(n: start)

        let bytes = stream.getLastBytes()

        return bytes.data
    }

    func range(start: Int, end: Int) -> Data? {
        let stream = CustomStream(data: self)
        stream.skipBytesNumber(n: start)
        let bytes = stream.readBytes(with: end)

        return bytes?.data
    }
}

extension Array where Element == UInt8  {
    var data: Data {
        return Data(self)
    }
}
