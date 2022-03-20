import Foundation
import Ed25519

final class Session: NSObject {
    let sessionId: String

    init(sessionId: String) {
        self.sessionId = sessionId

        super.init()
    }

    /// Pairing
    var isPairingVerified: Bool = false
    var pairingSeed = try! Ed25519Seed()
    lazy var pairingEd25519keyPair = Ed25519KeyPair(seed: pairingSeed)
    var pairingEcdhSecret: Data?
    var pairingEcdhTheirs: Data?
    var pairingEdTheirs: Data?
    var pairingEcdhOurs: Data?

    /// FairPlay
    var isFairPlaySetupCompleted: Bool = false
    var keyMessage: Data?

    /// Mirroring
    var mirrorService: MirroringService?
    var ekey: Data?
    var eiv: Data?
    var isScreenMirroringSession: Bool = false
    var streamConnectionID: Int?
    var descryptedAesKey: Int?
}
