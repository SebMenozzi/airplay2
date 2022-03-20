import CocoaAsyncSocket
import Cocoa

final class MirroringService: NSObject {

    private let sessionService: SessionService
    private var tcpSockets = [GCDAsyncSocket]()

    init(sessionService: SessionService) {
        self.sessionService = sessionService

        super.init()
    }

    func start() {
        let socket = createSocket()
        tcpSockets.append(socket)
    }

    // MARK: - Private

    private func createSocket() -> GCDAsyncSocket {
        let tcpQueue = DispatchQueue(label: "tcpQueue")

        let socket = GCDAsyncSocket(delegate: self, delegateQueue: tcpQueue)
        try? socket.accept(onPort: UInt16(Constants.airPlayPort))

        return socket
    }
}

// MARK: - GCDAsyncSocketDelegate
extension MirroringService: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        tcpSockets.append(newSocket)
        newSocket.readData(withTimeout: 30, tag: 0)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print(data.bytes)
    }

    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        #if DEBUG
        print("Connection timed out")
        #endif
        return 0
    }
}
