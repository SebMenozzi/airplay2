import CocoaAsyncSocket
import Cocoa

final class Mirroring: NSObject {

    private let session: Session

    init(session: Session) {
        self.session = session

        super.init()
    }

    // MARK: - Public

    func setup(body: Data) -> Data? {
        guard let converter = PlistConverter(binaryData: body),
              let plist = converter.plist else {
            return nil
        }

        let plistDict: NSDictionary

        if let streams = plist["streams"] as? NSArray,
           let stream = streams.firstObject as? [String: Any],
           let type = stream["type"] as? Int {
            session.streamConnectionID = stream["streamConnectionID"] as? Int

            var plist = [String: Array<[String: Any]>]()

            if type == 110 {
                plist = [
                    "streams": [[
                        "type": 110,
                        "dataPort": Constants.airPlayPort
                    ]]
                ]
            } else if type == 96 {
                plist = [
                    "streams": [[
                        "type": 96,
                        "controlPort": 7002,
                        "dataPort": 7003
                    ]]
                ]
            }

            plistDict = NSDictionary(dictionary: plist)
        } else {
            /// AES Key
            session.ekey = plist["ekey"] as? Data

            /// AES IV
            session.eiv = plist["eiv"] as? Data

            /// Boolean used to indicate the type of streaming (video or audio only)
            session.isScreenMirroringSession = plist["isScreenMirroringSession"] as? Bool ?? false

            /// We can return the same port used by AirTunes and manage timing and event requests directly from the AirTunes service.
            let plist: [String: Any] = [
                /// Port used from the client to send heartbeat to the receiver (only if you want change the port sent from client)
                "timingPort": Constants.airTunesPort,
                /// Port used from the client to send events to the receiver
                "eventPort": Constants.airTunesPort
            ]

            plistDict = NSDictionary(dictionary: plist)
        }

        let plistData = try? PropertyListSerialization.data(
            fromPropertyList: plistDict,
            format: .binary,
            options: .zero
        )

        return plistData
    }
}
