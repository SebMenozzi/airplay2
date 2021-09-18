import Foundation

protocol RTPPacket {
    var sequenceNumber: UInt16 { get }
    var timestamp: UInt32 { get }
    var payloadData: Data { get }
}
