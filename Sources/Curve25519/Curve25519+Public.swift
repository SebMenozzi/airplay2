import Foundation

public class Curve25519 {
    public static func sharedKey(secretKey: [UInt8], publicKey: [UInt8]) -> [UInt8] {
        var sharedKey = [UInt8](repeating: 0, count: 32)
        _ = crypto_scalarmult(&sharedKey, secretKey, publicKey)

        return sharedKey
    }

    public func signMessage(secretKey:[UInt8], msg:[UInt8], opt_random: [UInt8]?) -> [UInt8] {
        if opt_random != nil {
            var buf = [UInt8](repeating: 0, count: 128 + msg.count)
            _ = curve25519_sign(&buf, msg, msg.count, secretKey, opt_random!)

            return Array(buf[0..<64 + msg.count])
        } else {
            var signedMsg = [UInt8](repeating: 0, count: 64 + msg.count)
            _ = curve25519_sign(&signedMsg, msg, msg.count, secretKey, nil)

            return signedMsg
        }
    }

    // add by Miguel
    public func openMessageStr(publicKey:[UInt8], signedMsg: [UInt8]) -> String {
        let m = openMessage(publicKey: publicKey, signedMsg: signedMsg)

        var msg = ""
        for i in 0..<m.count {
            let value = Int( m[i] )
            msg += String( Character( UnicodeScalar( value )! ) )
        }

        return msg
    }

    public func openMessage(publicKey: [UInt8], signedMsg: [UInt8]) -> [UInt8] {
        var tmp = [UInt8](repeating: 0, count: signedMsg.count)
        let mlen = curve25519_sign_open(&tmp, signedMsg, signedMsg.count, publicKey)

        if mlen < 0 {
            print("fail: \(mlen) \n\n")
            return []
        }

        var m = [UInt8](repeating: 0, count: mlen)

        for i in 0..<m.count {
            m[i] = tmp[i]
        }

        return m
    }

    public func sign(secretKey: [UInt8], msg: [UInt8], opt_random: [UInt8]?) -> [UInt8] {
        var len = 64
        if opt_random != nil {
            len = 128
        }

        var buf = [UInt8](repeating: 0, count: len + msg.count)

        _ = curve25519_sign(&buf, msg, msg.count, secretKey, opt_random)

        var signature = [UInt8](repeating: 0, count: 64)

        for i in 0..<signature.count {
            signature[i] = buf[i]
        }

        return signature
    }

    public func verify(publicKey: [UInt8], msg: [UInt8], signature: [UInt8]) -> Int {
        var sm = [UInt8](repeating: 0, count: 64 + msg.count)
        var m = [UInt8](repeating: 0, count: 64 + msg.count)

        for i in 0..<64 {
            sm[i] = signature[i]
        }

        for i in 0..<msg.count {
            sm[i+64] = msg[i]
        }

        if curve25519_sign_open(&m, sm, sm.count, publicKey) >= 0 {
            return 1
        } else {
            return 0
        }
    }

    public class Keys {
        public var publicKey: [UInt8]
        public var privateKey: [UInt8]

        init (pk: [UInt8], sk: [UInt8]) {
            publicKey = pk
            privateKey = sk
        }
    }

    public static func generateKeyPair(_ seed: [UInt8]) -> Keys {
        var sk = [UInt8](repeating: 0, count: 32)
        var pk = [UInt8](repeating: 0, count: 32)

        for i in 0..<32 {
        sk[i] = seed[i]
        }

        _ = crypto_scalarmult_base(&pk, sk)

        // Turn secret key into the correct format.
        sk[0] = sk[0] & 248
        sk[31] = sk[31] & 127
        sk[31] = sk[31] | 64

        // Remove sign bit from public key.
        pk[31] = pk[31] & 127

        return Keys(pk: pk, sk: sk)
    }

    public func randomBytes(_ size: Int) -> [UInt8] {
        let High: Int = 255
        var seed = [UInt8](repeating: 0, count: size)

        for i in 0..<seed.count {
            seed[i] = UInt8(Int(arc4random()) % (High + 1))
        }

        return seed
    }
}
