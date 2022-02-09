import CocoaAsyncSocket
import Cocoa

final class MirrorService: NSObject {

    private(set) var isMirrorSetupCompleted: Bool = false

    private(set) var ekey = Data()
    private(set) var eiv = Data()
    private(set) var isScreenMirroringSession: Bool = false
    private(set) var streamConnectionID: Int?

    private var tcpSockets = [GCDAsyncSocket]()

    func setup(body: Data) -> Data? {
        let converter = PlistConverter(binaryData: body)!
        let plist = converter.plist!

        if let streams = plist["streams"] as? NSArray {
            let streamsDic = streams.firstObject as! [String: Any]

            streamConnectionID = streamsDic["streamConnectionID"] as? Int

            let plist: [String: Array<[String: Any]>] = [
                "streams": [[
                    "type": 110,
                    "dataPort": Constants.airTunesPort
                ]]
            ]

            let plistDict = NSDictionary(dictionary: plist)

            let plistData = try! PropertyListSerialization.data(
                fromPropertyList: plistDict,
                format: .binary,
                options: .zero
            )

            return plistData
        } else {
            /// AES Key
            ekey = plist["ekey"] as! Data

            /// AES IV
            eiv = plist["eiv"] as! Data

            /// Boolean used to indicate the type of streaming (video or audio only)
            isScreenMirroringSession = plist["isScreenMirroringSession"] as? Bool ?? false

            /// We can return the same port used by AirTunes and manage timing and event requests directly from the AirTunes service.
            let plist: [String: Any] = [
                /// Port used from the client to send heartbeat to the receiver (only if you want change the port sent from client)
                "timingPort": Constants.airTunesPort,
                /// Port used from the client to send events to the receiver
                "eventPort": Constants.airTunesPort
            ]

            let plistDict = NSDictionary(dictionary: plist)

            let plistData = try! PropertyListSerialization.data(
                fromPropertyList: plistDict,
                format: .binary,
                options: .zero
            )

            return plistData
        }
    }

    // MARK: - Private

    private func start() {
        let socket = createSocket()
        tcpSockets.append(socket)
    }

    private func createSocket() -> GCDAsyncSocket {
        let tcpQueue = DispatchQueue(label: "tcpQueue")

        let socket = GCDAsyncSocket(delegate: self, delegateQueue: tcpQueue)
        try? socket.accept(onPort: UInt16(Constants.airTunesPort))

        return socket
    }
}

extension MirrorService: GCDAsyncSocketDelegate {
    internal func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        tcpSockets.append(newSocket)
        newSocket.readData(withTimeout: 30, tag: 0)
    }

    internal func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("Mirror", data)
    }

    internal func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        #if DEBUG
        print("Connection timed out")
        #endif
        return 0
    }
}
