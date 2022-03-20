import Foundation
import Ed25519

final class SessionService: NSObject {

    var sessions = [String: Session]()

    func getSession(sessionId: String) -> Session {
        if let session = sessions[sessionId] {
            return session
        } else {
            let session = Session(sessionId: sessionId)
            sessions[sessionId] = session
            return session
        }
    }

}
