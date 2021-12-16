import CocoaAsyncSocket
import Cocoa

final class MirrorService: NSObject, GCDAsyncSocketDelegate {
    private var tcpSockets = [GCDAsyncSocket]()

    private let port: UInt16
    init(port: UInt16) {
        self.port = port

        super.init()
    }

    func start() {
        let socket = createSocket()
        tcpSockets.append(socket)
    }

    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        tcpSockets.append(newSocket)
        newSocket.readData(withTimeout: 30, tag: 0)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print(data)
    }

    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        #if DEBUG
        print("Connection timed out")
        #endif
        return 0
    }

    // MARK: Private

    private func createSocket() -> GCDAsyncSocket {
        let tcpQueue = DispatchQueue(label: "tcpQueue")

        let socket = GCDAsyncSocket(delegate: self, delegateQueue: tcpQueue)
        try? socket.accept(onPort: port)

        return socket
    }
}
