import Foundation
import CommonCrypto

class DecryptedPacket: RTPPacket, CustomDebugStringConvertible {
    let sequenceNumber: UInt16
    let timestamp: UInt32
    let payloadData: Data

    init(packet: RTPPacket, key: Data, iv: Data) {
        self.sequenceNumber = packet.sequenceNumber
        self.timestamp = packet.timestamp
        self.payloadData = DecryptedPacket.decrypt(
            packet.payloadData, withKey: key, iv: iv)
    }

    var debugDescription: String {
        return "\(sequenceNumber)"
    }

    private static func decrypt(_ payloadData: Data, withKey key: Data, iv: Data) -> Data {
        var cryptor: CCCryptorRef? = nil
        let length = payloadData.count
        var output = [UInt8](repeating: 0, count: length)
        var moved = 0

        key.withUnsafeBytes { keyUnsafeUInt8BufferPtr in
            let keyUnsafeUInt8Ptr = keyUnsafeUInt8BufferPtr.bindMemory(to: UInt8.self).baseAddress!

            iv.withUnsafeBytes { ivUnsafeUInt8BufferPtr in
                let ivUnsafeUInt8Ptr = ivUnsafeUInt8BufferPtr.bindMemory(to: UInt8.self).baseAddress!

                CCCryptorCreate(UInt32(kCCDecrypt), 0, 0, keyUnsafeUInt8Ptr, 16,ivUnsafeUInt8Ptr, &cryptor)
            }
        }

        payloadData.withUnsafeBytes { payloadUnsafeUInt8BufferPtr in
            let payloadUnsafeUInt8Ptr = payloadUnsafeUInt8BufferPtr.bindMemory(to: UInt8.self).baseAddress!

            CCCryptorUpdate(cryptor, payloadUnsafeUInt8Ptr, length, &output, output.count, &moved)
        }

        var decrypted = Data(output[0..<moved])

        // Remaining data is plain-text
        let remaining = decrypted.count..<length
        decrypted.append(payloadData.subdata(in: remaining))

        CCCryptorRelease(cryptor)

        return decrypted
    }
}
