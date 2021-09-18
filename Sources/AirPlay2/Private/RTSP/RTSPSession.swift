import CocoaAsyncSocket
import Cocoa
import CryptoBindings
import CryptoKit
import SRP
import CommonCrypto

class RTSPSession: NSObject, GCDAsyncSocketDelegate {
    private let manager: SessionManager
    private var tcpSockets = [GCDAsyncSocket]()
    private let username = "Pair-Setup"
    private let password = "123-44-321"
    private lazy var server: Server<SHA512> = {
        let (salt, verificationKey) = createSaltedVerificationKey(
            using: SHA512.self,
            group: .N3072,
            username: username,
            password: password
        )

        return Server<SHA512>(
            username: username,
            salt: salt,
            verificationKey: verificationKey,
            group: .N3072
        )
    }()

    init(manager: SessionManager) {
        self.manager = manager

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
        handleRTSPData(data, from: sock)
    }

    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        #if DEBUG
            print("Connection timed out")
        #endif

        return 0
    }
    
    private func createSocket() -> GCDAsyncSocket {
        let tcpQueue = DispatchQueue(label: "tcpQueue")
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: tcpQueue)
        try? socket.accept(onPort: RTSPSessionConstants.port)
        return socket
    }

    private func handleRTSPData(_ data: Data, from sock: GCDAsyncSocket) {
        let parser = RTSPParser(data: data)
        let message = parser.parse()

        handleMethod(message: message, from: sock)
        respond(message: message, using: sock)
        updateRemoteFromInfo(message: message)
        readNextRTSPPacket(from: sock)

        #if DEBUG
            manager.printDebugInfo()
        #endif
    }

    private func handleMethod(message: RTSPMessage, from sock: GCDAsyncSocket) {
        switch message.method {
            // SETUP: This is the setup request used to establish the communication with the receiver
            case "SETUP":
                setSessionSocket(sock)
                manager.beginPlayback()
            // RECORD: The sender wants to start streaming
            // FLUSH: Sent every time the audio streaming is about to start
            case "RECORD", "FLUSH":
                manager.resetPlayback()
            // TEARDOWN: Sent when audio is paused or AirPlay is stopped
            case "TEARDOWN":
                manager.endPlayback()
            default:
                break
        }
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


    private var clientPublicKey: Data?
    //private var edTheirs: Data?

    private let keyPair = Curve25519.generateKeyPair()!

    private func respond(message: RTSPMessage, using sock: GCDAsyncSocket) {
        let response = RTSPResponse()
        let method = message.method
        let url = message.url

        switch method {
            case "GET":
                switch url {
                case "/info":
                    response.addContentType(type: Constants.bplistContentType)

                    let path = Bundle.module.path(forResource: "info-response", ofType: "bplist")!
                    let url = URL(fileURLWithPath: path)
                    let binaryPlist = try! Data(contentsOf: url, options: .alwaysMapped)

                    response.addBody(body: binaryPlist)
                default:
                    break
                }
            case "POST":
                switch url {
                // Pair Setup is a one-time operation that creates a valid paring
                // between an iOS device and an accessory by securely exchanging public keys
                // with an iOS device and an accessory. Pair Setup requires the customer to enter 8 digit
                // setup code on their iOS device.
                case "/pair-setup":
                    print("pair-setup")

                    response.addBody(body: keyPair.publicKey()!)

                    response.addContentType(type: "application/octet-stream")
                case "/pair-verify":
                    let stream = CustomStream(data: message.body)

                    print("pair-verify", message.body.base64EncodedString())

                    guard let flag = stream.readByte() else {
                        fatalError("Pair Verify: Can't retrieve flag")
                    }

                    stream.skipBytesNumber(n: 3)

                    if flag > 0 {
                        let clientPublicKey = Data(stream.readBytesNumber(n: 32)!)
                        let later = Data(stream.readBytesNumber(n: 32)!)

                        let deviceId = Constants.publicID.data(using: .utf8)!

                        self.clientPublicKey = clientPublicKey
                        //self.edTheirs = edTheirs

                        // 1. Generate new, random Curve25519 keypair
                        let keyPair = Curve25519.generateKeyPair()!
                        let accessoryPublicKey = keyPair.publicKey()!

                        // 2. Generate the shared secret, SharedSecret, from its Curve25519 secret
                        // key and the iOS deviceʼs Curve25519 public key.
                        let accessorySharedKey = Curve25519.generateSharedSecret(
                            fromPublicKey: clientPublicKey,
                            andKeyPair: keyPair
                        )!

                        // 3. Construct AccessoryInfo
                        let accessoryInfo = accessoryPublicKey + deviceId + clientPublicKey

                        // 4. Use Ed25519 to generate AccessorySignature by signing AccessoryInfo
                        let accessorySignature = Ed25519.sign(accessoryInfo, with: keyPair)!

                        // 5. Construct a sub-TLV with the following items
                        let pairTLV8: PairTagTLV8 = [
                            (.identifier, deviceId),
                            (.signature, accessorySignature)
                        ]

                        //  6. Derive the symmetric shared key from the
                        // Curve25519 shared secret by using HKDF-SHA-512 with the following
                        // parameters:
                        let encryptedAccessorySharedKey = HKDF<SHA512>.deriveKey(
                            inputKeyMaterial: SymmetricKey(data: accessorySharedKey),
                            salt: "Pair-Verify-Encrypt-Salt".data(using: .utf8)!,
                            info: "Pair-Verify-Encrypt-Info".data(using: .utf8)!,
                            outputByteCount: 32
                        )

                        //  7. Encrypt the TVL8 pair
                        let message = encodeTVL8(pairTLV8)

                        // We add 4 bytes because it expects 12 bytes in total
                        let nonce = try! ChaChaPoly.Nonce(
                            data: Data(count: 4) + "PV-Msg02".data(using: .utf8)!
                        )

                        let box = try! ChaChaPoly.seal(
                            message,
                            using: encryptedAccessorySharedKey,
                            nonce: nonce
                        )

                        // 8. Construct the response
                        let result: PairTagTLV8 = [
                            (.state, Data([PairVerifyStep.startResponse.rawValue])),
                            (.publicKey, accessoryPublicKey),
                            (.encryptedData, box.ciphertext + box.tag)
                        ]

                        let resultData = encodeTVL8(result)

                        // 9. Send the response to the iOS device
                        response.addBody(body: resultData)
                    }

                    response.addContentType(type: "application/pairing+tlv8")
                default:
                    break
                }
            case "SETUP":
                response.addSetupResponse()
            default:
                break
        }

        response.addSequenceNumber(message.header.cseq)

        let responseData = response.build()

        sock.write(responseData, withTimeout: 30, tag: 0)
    }

    private func createResponse(forChallenge challenge: String, from sock: GCDAsyncSocket) -> String {
        var responseData = Data(base64Encoded: challenge)!
        responseData.append(sock.localAddress!)
        responseData.append(Data(manager.hardwareAddress))

        while responseData.count < 32 {
            responseData.append(0)
        }

        let signedResponse = manager.sign(responseData)

        return signedResponse.base64EncodedString()
    }

    private func updateRemoteFromInfo(message: RTSPMessage) {
        manager.updateToken(
            message.header.activeRemote,
            forRemoteIdentifier: message.header.dacpID
        )
    }
    
    private func readNextRTSPPacket(from sock: GCDAsyncSocket) {
        sock.readData(withTimeout: 30, tag: 0)
    }

    private func handleSDPData(_ data: Data) {
        let parsed = SDPParser(data: data)!.parse()

        manager.updateEncryption(with: parsed)
    }

    private func handleJPEGData(_ data: Data) {
        let artwork = NSImage(data: data) ?? NSImage()
        let parsed = ["artwork": artwork]

        manager.updateTrackInfo(withKeyedValues: parsed)
    }

    private func handleParameterData(_ data: Data) {
        let parsed = ParameterParser(data: data)!.parse()

        manager.updateTrackInfo(withKeyedValues: parsed)
    }

    private func handleDAAPData(_ data: Data) {
        let parsed = DAAPParser(data: data)!.parse()

        manager.updateTrackInfo(withKeyedValues: parsed)
        manager.updatePlayerInfo(withKeyedValues: parsed)
    }
}

private enum RTSPSessionConstants {
    static let port: UInt16 = 5001
}
