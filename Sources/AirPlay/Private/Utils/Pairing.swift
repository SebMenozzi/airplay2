import Foundation

import Ed25519
import Curve25519
import CryptoKit
import CryptoSwift

final class Pairing {
    var isPairingVerified: Bool = false

    private let seed = try! Ed25519Seed()
    private lazy var ed25519keyPair = Ed25519KeyPair(seed: seed)

    private var ecdhSecret = Data()
    private var ecdhTheirs = Data()
    private var edTheirs = Data()
    private var ecdhOurs = Data()

    // MARK: - Public

    func setup() -> Data {
        return ed25519keyPair.publicKey.bytes.data
    }

    func verify(body: Data) -> Data? {
        // 68 bytes (the first 4 bytes are 00/01 00 00 00)
        if body.count != 4 + 32 + 32 {
            fatalError("Invalid pair-verify data: should be 4 + 32 + 32 bytes")
        }

        let stream = CustomStream(data: body)

        guard let flag = stream.readByte() else {
            fatalError("Pair Verify: Can't retrieve flag")
        }

        if flag > 0 {
            stream.skipBytesNumber(n: 3)

            self.ecdhTheirs = Data(stream.readBytes(with: 32)!)
            self.edTheirs = Data(stream.readBytes(with: 32)!)

            let curve25519KeyPair = Curve25519.generateKeyPair(seed.bytes)

            self.ecdhOurs = curve25519KeyPair.publicKey.data
            let ecdhPrivateKey = curve25519KeyPair.privateKey.data

            self.ecdhSecret = generateSecret(
                ecdhTheirs: ecdhTheirs,
                privateKey: ecdhPrivateKey
            )

            let dataToSign = ecdhOurs + ecdhTheirs

            let signature = generateSignature(
                dataToSign: dataToSign,
                keyPair: ed25519keyPair
            )

            let encryptedSignature = encryptSignature(
                signature: signature,
                ecdhSecret: ecdhSecret
            )

            let output = ecdhOurs + encryptedSignature

            return output
        } else {
            stream.skipBytesNumber(n: 3)

            let signature = Data(stream.readBytes(with: 64)!)

            let encryptedSignature = encryptSignature(
                signature: signature,
                ecdhSecret: ecdhSecret,
                withEncryptorInit: true
            )

            let message = ecdhTheirs + ecdhOurs

            let publicKey = try! Ed25519PublicKey(edTheirs.bytes)

            self.isPairingVerified = try! publicKey.verify(
                signature: encryptedSignature.bytes,
                message: message.bytes
            )

            if !isPairingVerified {
                fatalError("The Paring must be verified!")
            }

            return nil
        }
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

    private func generateDeriveKey(salt: String, key: Data) -> Data {
        var sha512Digest = SHA512()
        sha512Digest.update(data: salt.data(using: .utf8)!)
        sha512Digest.update(data: key)

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
        let aesKey = generateDeriveKey(salt: "Pair-Verify-AES-Key", key: ecdhSecret)
        let aesIV = generateDeriveKey(salt: "Pair-Verify-AES-IV", key: ecdhSecret)

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
