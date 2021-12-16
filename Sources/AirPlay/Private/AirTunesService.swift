import CocoaAsyncSocket
import Cocoa

final class AirTunesService: NSObject {
    private var tcpSockets = [GCDAsyncSocket]()

    private let pairing = Pairing()
    private let fairPlay = FairPlay()

    private let port: UInt16
    init(port: UInt16) {
        self.port = port

        super.init()
    }

    func start() {
        let socket = createSocket()
        tcpSockets.append(socket)
    }

    // MARK: Private
    
    private func createSocket() -> GCDAsyncSocket {
        let tcpQueue = DispatchQueue(label: "tcpQueue")

        let socket = GCDAsyncSocket(delegate: self, delegateQueue: tcpQueue)
        try? socket.accept(onPort: port)

        return socket
    }

    private func handleRTSPData(_ data: Data, from sock: GCDAsyncSocket) {
        let parser = RTSPParser(data: data)
        let message = parser.parse()

        setSessionSocket(sock)
        respond(message: message, using: sock)
        readNextPacket(from: sock)
    }

    private func setSessionSocket(_ sock: GCDAsyncSocket!) {
        // Disconnect any other session
        for i in 1..<tcpSockets.count {
            if tcpSockets[i] === sock {
                break
            }

            tcpSockets[i].disconnect()
        }
    }

    private func respond(message: RTSPMessage, using sock: GCDAsyncSocket) {
        let response = RTSPResponse()
        let method = message.method
        let url = message.url
        let sessionId = message.header.activeRemote

        print("-", method, url)

        switch method {
            case "GET":
                switch url {
                case "/info":
                    guard  let converter = PlistConverter(binaryData: message.body),
                           let txtAirplay = (converter.plist?["qualifier"] as? NSArray)?.firstObject as? String else {
                        return
                    }

                    if txtAirplay != "txtAirPlay" {
                        fatalError("Should return txtAirplay for key qualifier!")
                    }

                    let plist: [String: Any] = [
                        "displays": [
                            [
                                "primaryInputDevice": true,
                                "rotation": true,
                                "widthPhysical": false,
                                "widthPixels": 1920,
                                "uuid": "061013ae-7b0f-4305-984b-974f677a150b",
                                "heightPhysical": false,
                                "features": 30,
                                "heightPixels": 1080,
                                "overscanned": false,
                                "refreshRate": 60,
                            ]
                        ],
                        "audioFormats": [
                            [
                                "type": 100,
                                "audioInputFormats": 67108860,
                                "audioOutputFormats": 67108860
                            ],
                            [
                                "type": 101,
                                "audioInputFormats": 67108860,
                                "audioOutputFormats": 67108860
                            ]
                        ],
                        "audioLatencies": [
                            [
                                "outputLatencyMicros": false,
                                "type": 100,
                                "audioType": "default",
                                "inputLatencyMicros": false
                            ],
                            [
                                "outputLatencyMicros": false,
                                "type": 101,
                                "audioType": "default",
                                "inputLatencyMicros": false
                            ]
                        ],
                        "features": 61379444727,
                        "name": "airserver",
                        "vv": 2,
                        "statusFlags": 4,
                        "keepAliveLowPower": true,
                        "sourceVersion": "220.68",
                        "pk": "b07727d6f6cd6e08b58ede525ec3cdeaa252ad9f683feb212ef8a205246554e7",
                        "keepAliveSendStatsAsBody": true,
                        "deviceID": "78:7B:8A:BD:C9:4D",
                        "model": "AppleTV5,3",
                        "macAddress": "78:7B:8A:BD:C9:4D"
                    ]

                    let plistDict = NSDictionary(dictionary: plist)

                    let plistData = try! PropertyListSerialization.data(
                        fromPropertyList: plistDict,
                        format: .binary,
                        options: .zero
                    )

                    response.addContentType(type: "application/x-apple-binary-plist")
                    response.addBody(body: plistData)
                    break
                default:
                    break
                }
            case "POST":
                switch url {
                case "/pair-setup":
                    if message.body.count != 32 {
                        fatalError("Invalid pair-setup data: should be 32 bytes")
                    }

                    response.addBody(body: pairing.setup())
                    response.addContentType(type: "application/octet-stream")
                case "/pair-verify":
                    guard let data = pairing.verify(body: message.body) else {
                        break
                    }

                    response.addBody(body: data)
                    response.addContentType(type: "application/octet-stream")
                case "/fp-setup":
                    if !pairing.isPairingVerified {
                        response.replaceUnauthorized()
                    } else {
                        guard let data = fairPlay.setup(body: message.body) else {
                            break
                        }

                        response.addContentType(type: "application/octet-stream")
                        response.addBody(body: data)
                    }
                default:
                    break
                }
            case "SETUP":
                if !fairPlay.isFairPlaySetupCompleted {
                    response.replaceBadRequest()
                } else {
                    let converter = PlistConverter(binaryData: message.body)!
                    let plist = converter.plist!

                    print(converter.convertToXML()!)

                    if let streams = plist["streams"] as? NSArray {
                        for stream in streams {
                            print(stream)
                        }
                    } else {
                        let et = plist["et"] as! Int
                        let ekey = plist["ekey"] as! Data
                        let eiv = plist["eiv"] as! Data
                        let isScreenMirroringSession = plist["isScreenMirroringSession"] as? Bool ?? false
                        let timingPort = plist["timingPort"] as! Int

                        let plist: [String: Any] = [
                            "timingPort": port,
                            "eventPort": port
                        ]

                        let plistDict = NSDictionary(dictionary: plist)

                        let plistData = try! PropertyListSerialization.data(
                            fromPropertyList: plistDict,
                            format: .binary,
                            options: .zero
                        )

                        response.addContentType(type: "application/x-apple-binary-plist")
                        response.addBody(body: plistData)
                    }
                }
            default:
                break
        }

        response.addSequenceNumber(message.header.cseq)

        let responseData = response.build()

        sock.write(responseData, withTimeout: 30, tag: 0)
    }
    
    private func readNextPacket(from sock: GCDAsyncSocket) {
        sock.readData(withTimeout: 30, tag: 0)
    }
}

extension AirTunesService: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        tcpSockets.append(newSocket)
        newSocket.readData(withTimeout: 30, tag: 0)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        handleRTSPData(data, from: sock)
    }

    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        #if DEBUG
        print("Connection timed out")
        #endif
        return 0
    }
}
