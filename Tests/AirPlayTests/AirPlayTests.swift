import XCTest
import class Foundation.Bundle

//import class AirPlay.Pairing

final class AirPlayTests: XCTestCase {
    func testGeneratedSecret() throws {
        /*
        let ecdhTheirs = Data(base64Encoded: "9KIHmnYDt9gTvfGqJkyGOG991ljhdGWrgDMNs74bZwA=")!
        let curvePrivateKey = Data(base64Encoded: "aMoaZxDmN+lJ/Mx+gG87WpgohYZwPhvdEiYM1vQ4110=")!

        let pairing = Pairing()

        let ecdhSecret = pairing.generateSecret(
            publicKey: ecdhTheirs,
            privateKey: curvePrivateKey
        )

        XCTAssertEqual("oaO/5ZOuyzEuiUW7RoLSJ42Jp+nhU3OSlOhSQWyluj4=", ecdhSecret.base64EncodedString())
        */
    }

    func testIVAndKey() throws {
        /*
        let pairing = Pairing()

        let ecdhSecret = Data(base64Encoded: "dTcKfeOrIAbn/64zH4Zby2Qxyfincth7JAPq2GrmKmE=")!

        let aesKey = pairing.generateDeriveKey(salt: "Pair-Verify-AES-Key", key: ecdhSecret)
        XCTAssertEqual("0ZPYl0YKHR9ov7sdlQsjog==", aesKey.base64EncodedString())

        let aesIV = pairing.generateDeriveKey(salt: "Pair-Verify-AES-IV", key: ecdhSecret)
        XCTAssertEqual("8XDfHIoIgNKKP7vtvtmY6A==", aesIV.base64EncodedString())
        */
    }
}
