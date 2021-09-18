import Foundation

class EmptyPacket: RTPPacket {
    let sequenceNumber = UInt16()
    let timestamp = UInt32()
    let payloadData = Data()

    private static let emptyPacket = EmptyPacket()

    private init() {}

    static func packet() -> EmptyPacket {
        return emptyPacket
    }
}
