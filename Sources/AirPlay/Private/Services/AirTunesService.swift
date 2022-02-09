import CocoaAsyncSocket
import Cocoa

final class AirTunesService: NSObject {
    
    private var tcpSockets = [GCDAsyncSocket]()

    private let pairingService = PairingService()
    private let fairPlayService = FairPlayService()
    private let mirrorService = MirrorService()
    // private let audioService = AudioService()

    func start() {
        let socket = createSocket()
        tcpSockets.append(socket)
    }

    // MARK: Private
    
    private func createSocket() -> GCDAsyncSocket {
        let tcpQueue = DispatchQueue(label: "tcpQueue")

        let socket = GCDAsyncSocket(delegate: self, delegateQueue: tcpQueue)
        try? socket.accept(onPort: UInt16(Constants.airTunesPort))

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
                let plist: [String: Any] = [
                    "displays": [
                        [
                            "primaryInputDevice": true,
                            "rotation": true,
                            "widthPhysical": false,
                            "edid": "AP///////wAGEBOuhXxiyAoaAQS1PCJ4IA8FrlJDsCYOT1QAAAABAQEBAQEBAQEBAQEBAQEBAAAAEAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAA/ABpTWFjCiAgICAgICAgAAAAAAAAAAAAAAAAAAAAAAAAAqBwE3kDAAMAFIBuAYT/E58AL4AfAD8LUQACAAQAf4EY+hAAAQEAEnYx/Hj7/wIQiGLT+vj4/v//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADHkHATeQMAAwFQU+wABP8PnwAvAB8A/whBAAIABABM0AAE/w6fAC8AHwBvCD0AAgAEAMyRAAR/DJ8ALwAfAAcHMwACAAQAVV4ABP8JnwAvAB8AnwUoAAIABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB+Q",
                            "widthPixels": 1920.0,
                            "heightPixels": 1080.0,
                            "uuid": "061013ae-7b0f-4305-984b-974f677a150b",
                            "heightPhysical": false,
                            "features": 30,
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
                    "pk": Constants.publicKey,
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

                response.addContentType(type: Constants.contentTypeBinaryPlist)
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

                response.addBody(body: pairingService.setup())
                response.addContentType(type: "application/octet-stream")

                break
            case "/pair-verify":
                guard let data = pairingService.verify(body: message.body) else {
                    break
                }

                response.addBody(body: data)
                response.addContentType(type: "application/octet-stream")

                break
            case "/fp-setup":
                if !pairingService.isPairingVerified {
                    response.replaceUnauthorized()
                } else {
                    guard let data = fairPlayService.setup(body: message.body) else {
                        break
                    }

                    response.addContentType(type: "application/octet-stream")
                    response.addBody(body: data)
                }

                break
            default:
                break
            }
        case "SETUP":
            if !fairPlayService.isFairPlaySetupCompleted {
                response.replaceBadRequest()
            } else {
                guard let data = mirrorService.setup(body: message.body) else {
                    break
                }

                response.addContentType(type: Constants.contentTypeBinaryPlist)
                response.addBody(body: data)
            }

            break

        case "GET_PARAMETER":
            /// The client makes this call when it wants to know the receiver's volume level.
            guard let data = String(bytes: message.body, encoding: .ascii),
                  data == "volume\r\n" else {
                break
            }

            response.addContentType(type: "text/parameters")
            response.addBody(body: "volume: 1.000000\r\n".data(using: .ascii)!)

            break

        case "RECORD":
            response.addHeader(key: "Audio-Latency", value: "0")

            break
        case "TEARDOWN":
            let converter = PlistConverter(binaryData: message.body)!
            let plist = converter.plist!

            print(converter.convertToXML()!)

            break
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
