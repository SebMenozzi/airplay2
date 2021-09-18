import CocoaAsyncSocket

class RemoteService: NSObject, GCDAsyncSocketDelegate, RemoteLocatorDelegate {
    private var request = [String]()
    private var socket = GCDAsyncSocket()
    private var locator = RemoteLocator()
    private var isServiceResolved = false
    private var token = ""
    private var host: String?
    private var port: UInt16?

    override init() {
        super.init()

        locator.delegate = self
        socket.delegate = self
        socket.delegateQueue = DispatchQueue(label: "remoteQueue")
    }

    func play() {
        sendCommand("playpause")
    }

    func pause() {
        sendCommand("pause")
    }

    func next() {
        sendCommand("nextitem")
    }

    func previous() {
        sendCommand("previtem")
    }

    func updateToken(_ token: String, forRemoteIdentifier id: String) {
        if self.token != token {
            self.token = token

            disconnectFromCurrentRemote()
            locator.searchForRemote(withIdentifier: id)
        }
    }

    private func disconnectFromCurrentRemote() {
        isServiceResolved = false
        socket.disconnect()
    }

    private func sendCommand(_ command: String) {
        guard isServiceResolved else {
            return locator.retrySearch()
        }

        if socket.isConnected {
            createRequest(withCommand: command)
            sendRequest()
        } else {
            connectToRemote()
        }
    }

    private func createRequest(withCommand command: String) {
        request = ["GET /ctrl-int/1/\(command) HTTP/1.1"]
        request += ["Active-Remote: \(token)"]
        request += ["\r\n"]
    }

    private func sendRequest() {
        let requestData = request.joined(separator: "\r\n").data(using: .utf8)!
        socket.write(requestData, withTimeout: 30, tag: 0)
        request.removeAll()
    }

    private func connectToRemote() {
        if let host = self.host, let port = self.port {
            _ = try? socket.connect(toHost: host, onPort: port)
        }
    }

    fileprivate func remoteLocator(_ locator: RemoteLocator,
                       didFindRemoteWithHost host: String, port: UInt16){
        self.host = host
        self.port = port
        isServiceResolved = true
        connectToRemote()
    }

    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        // Retry pending request if we successfully connect
        if !request.isEmpty {
            sendRequest()
        }
    }
}

private class RemoteLocator: NSObject, NetServiceDelegate, NetServiceBrowserDelegate {
    private var service: NetService?
    private var browser = NetServiceBrowser()
    private var identifier = ""

    var delegate: RemoteLocatorDelegate? = nil

    init(delegate: RemoteLocatorDelegate? = nil) {
        super.init()
        self.delegate = delegate
        browser.delegate = self
    }

    func searchForRemote(withIdentifier id: String) {
        identifier = id
        retrySearch()
    }

    func retrySearch() {
        browser.stop()
        browser.searchForServices(ofType: "_dacp._tcp", inDomain: "local.")
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        browser.stop()
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if service.name.contains(identifier) {
            self.service = service
            service.delegate = self
            service.resolve(withTimeout: 30)
            browser.stop()
        }

        if !moreComing {
            browser.stop()
        }
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let host = sender.hostName else { return }
        let port = UInt16(sender.port)

        delegate?.remoteLocator(self, didFindRemoteWithHost: host, port: port)
    }
}

private protocol RemoteLocatorDelegate {
    func remoteLocator(_ locator: RemoteLocator, didFindRemoteWithHost host: String, port: UInt16)
}
