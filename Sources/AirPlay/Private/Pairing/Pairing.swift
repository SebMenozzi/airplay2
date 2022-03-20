import Foundation

import Ed25519
import Curve25519
import CryptoKit
import CryptoSwift

final class Pairing: NSObject {

    private let session: Session

    init(session: Session) {
        self.session = session

        super.init()
    }

    // MARK: - Public

    func setup() -> Data {
        return session.pairingEd25519keyPair.publicKey.bytes.data
    }

    func verify1(stream: CustomStream) -> Data? {
        stream.skipBytesNumber(n: 3)

        guard let ecdhTheirsBytes = stream.readBytes(with: 32),
              let edTheirsBytes = stream.readBytes(with: 32) else {
            return nil
        }

        session.pairingEcdhTheirs = ecdhTheirsBytes.data
        session.pairingEdTheirs = edTheirsBytes.data

        let curve25519KeyPair = Curve25519.generateKeyPair(session.pairingSeed.bytes)

        session.pairingEcdhOurs = curve25519KeyPair.publicKey.data

        session.pairingEcdhSecret = generateSecret(
            ecdhTheirs: session.pairingEcdhTheirs!,
            privateKey: curve25519KeyPair.privateKey.data
        )

        guard let ecdhTheirs = session.pairingEcdhTheirs,
              let ecdhOurs = session.pairingEcdhOurs,
              let ecdhSecret = session.pairingEcdhSecret else {
            return nil
        }

        let dataToSign = ecdhOurs + ecdhTheirs

        let signature = generateSignature(
            dataToSign: dataToSign,
            keyPair: session.pairingEd25519keyPair
        )

        let encryptedSignature = encryptSignature(
            signature: signature,
            ecdhSecret: ecdhSecret
        )

        let output = ecdhOurs + encryptedSignature

        return output
    }

    func verify2(stream: CustomStream) -> Bool {
        stream.skipBytesNumber(n: 3)

        guard let signature = stream.readBytes(with: 64),
              let ecdhTheirs = session.pairingEcdhTheirs,
              let edTheirs = session.pairingEdTheirs,
              let ecdhOurs = session.pairingEcdhOurs,
              let ecdhSecret = session.pairingEcdhSecret else {
            return false
        }

        let encryptedSignature = encryptSignature(
            signature: signature.data,
            ecdhSecret: ecdhSecret,
            withEncryptorInit: true
        )

        let message = ecdhTheirs + ecdhOurs

        guard let publicKey = try? Ed25519PublicKey(edTheirs.bytes) else {
            return false
        }

        session.isPairingVerified = (try? publicKey.verify(
            signature: encryptedSignature.bytes,
            message: message.bytes
        )) ?? false

        return session.isPairingVerified
    }

    // MARK: - Private

    private func generateSecret(ecdhTheirs: Data, privateKey: Data) -> Data {
        return Curve25519.sharedKey(
            secretKey: privateKey.bytes,
            publicKey: ecdhTheirs.bytes
        ).data
    }

    private func generateSignature(dataToSign: Data, keyPair: Ed25519KeyPair) -> Data {
        return keyPair.sign(dataToSign.bytes).data
    }

    private func generateDeriveKey(salt: Data, key: Data) -> Data {
        let sha512Digest = SHA512()..{
            $0.update(data: salt)
            $0.update(data: key)
        }

        let deriveKey = sha512Digest.finalize().withUnsafeBytes({ Data($0) })

        return CustomStream(
            data: deriveKey
        ).readBytes(with: 16)!.data
    }

    private func createEncryptor(
        key: Data,
        iv: Data
    ) -> (Cryptor & Updatable)? {
        return try? AES(
            key: key.bytes,
            blockMode: CTR(iv: iv.bytes),
            padding: .noPadding
        ).makeEncryptor()
    }

    private func encryptSignature(
        signature: Data,
        ecdhSecret: Data,
        withEncryptorInit: Bool = false
    ) -> Data {
        let aesKey = generateDeriveKey(salt: "Pair-Verify-AES-Key".data(using: .utf8)!, key: ecdhSecret)
        let aesIV = generateDeriveKey(salt: "Pair-Verify-AES-IV".data(using: .utf8)!, key: ecdhSecret)

        var encryptor = createEncryptor(key: aesKey, iv: aesIV)!

        var output = Array<UInt8>()

        if withEncryptorInit {
            // I don't understand why this is required for the second pair verify
            _ = try! encryptor.update(withBytes: [UInt8](repeating: 0, count: signature.count))
        }

        output += try! encryptor.update(withBytes: signature.bytes)
        output += try! encryptor.finish()

        return output.data
    }
}
