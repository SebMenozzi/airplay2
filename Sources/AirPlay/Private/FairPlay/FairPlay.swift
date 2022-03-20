import Foundation

final class FairPlay: NSObject {

    private let session: Session

    init(session: Session) {
        self.session = session

        super.init()
    }

    // MARK: - Public

    func setup(body: Data) -> Data? {
        if body.count == 16 {
            let mode = body[14]

            // The 5th byte must be 0x03.
            if body[4] != 3 {
                return nil
            }

            return Self.replyMessage[Int(mode)].data
        } else if body.count == 164 {
            // The 5th byte must be 0x03.
            if body[4] != 3 {
                return nil
            }

            // Save the 164 bytes because this is the KeyMessage.
            session.keyMessage = body

            let stream = CustomStream(data: body)
            stream.skipBytesNumber(n: 144)

            session.isFairPlaySetupCompleted = true

            // First 12 bytes are fairplay header
            return Self.fpHeader.data + stream.getLastBytes()
        }

        return nil
    }

}
