import Foundation

class SessionManager {
    private var audioSession: AudioSession!
    private var rtpSession: RTPSession!
    private var rtspSession: RTSPSession!
    private var remote: RemoteService!
    private var crypto: CryptoService!
    private var bonjour: BonjourService!

    var trackInfo = TrackInfo()
    var playerInfo = PlayerInfo()

    init(name: String) {
        rtspSession = RTSPSession(manager: self)
        audioSession = AudioSession(manager: self)
        rtpSession = RTPSession(manager: self)
        remote = RemoteService()
        crypto = CryptoService()
        bonjour = BonjourService(
            name: name,
            hardwareAddress: hardwareAddress
        )
    }

    var hardwareAddress: [UInt8] {
        // Hard-code a random address to avoid the
        // convoluted lookup process
        return [184, 199, 93, 59, 114, 43]
    }

    var isPlaying: Bool {
        return playerInfo.isPlaying
    }

    func start() {
        bonjour.publish()
        audioSession.start()
        rtspSession.start()
        rtpSession.start()
    }

    func play() {
        remote.play()
    }

    func pause() {
        remote.pause()
    }

    func next() {
        remote.next()
    }

    func previous() {
        remote.previous()
    }

    func add(_ packet: RTPPacket) {
        audioSession.add(packet)
    }

    func sign(_ data: Data) -> Data {
        return crypto.sign(data)
    }

    func beginPlayback() {
        playerInfo.isPlaying = true
    }

    func endPlayback() {
        trackInfo.reset()
        audioSession.pause()
        playerInfo.isPlaying = false
    }

    func resetPlayback() {
        audioSession.reset()
        rtpSession.reset()
    }

    func updateEncryption(with info: [String: AnyHashable]) {
        let encryptedKey = info["key"] as! Data
        rtpSession.key = crypto.decrypt(encryptedKey)
        rtpSession.iv = info["iv"] as! Data
    }

    func updateToken(_ token: String, forRemoteIdentifier id: String) {
        remote.updateToken(token, forRemoteIdentifier: id)
    }

    func updateTrackInfo(withKeyedValues keyedValues: [String: AnyHashable]) {
        trackInfo.update(withKeyedValues: keyedValues)
    }

    func updatePlayerInfo(withKeyedValues keyedValues: [String: AnyHashable]) {
        playerInfo.update(withKeyedValues: keyedValues)
    }

    func setSequenceNumber(_ sequenceNumber: UInt16) {
        audioSession.setSequenceNumber(sequenceNumber)
    }

    func printDebugInfo() {
        audioSession.printDebugInfo()
    }
}
