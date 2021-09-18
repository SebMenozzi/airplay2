import Foundation

final class BonjourService {
    private var airPlayService: NetService!
    private var airTunesService: NetService!

    private let name: String
    private let hardwareAddress: [UInt8]

    init(name: String, hardwareAddress: [UInt8]) {
        self.name = name
        self.hardwareAddress = hardwareAddress
    }
    
    func publish() {
        createAirPlayService()
        airPlayService.publish()

        createAirTunesService()
        airPlayService.publish()
    }

    private func createAirPlayService() {
        airPlayService = NetService(
            domain: "",
            type: AirPlayMDNSProperties.type,
            name: name,
            port: AirPlayMDNSProperties.rtspPort
        )

        airPlayService.setTXTRecord(AirPlayMDNSProperties.txtRecord)
    }

    private func createAirTunesService() {
        airTunesService = NetService(
            domain: "",
            type: AirTunesMDNSProperties.type,
            name: hardwareAddress.reduce("", {$0 + String(format: "%02X", $1)}) + "@\(name)",
            port: AirTunesMDNSProperties.rtspPort
        )

        airTunesService.setTXTRecord(AirTunesMDNSProperties.txtRecord)
    }
}

private enum AirPlayMDNSProperties {
    static let type = "_airplay._tcp."

    static let rtspPort: Int32 = 5001

    static let features = String(
        format: "0x%llX,0x%llX",
        Constants.FEATURES & 0xffffffff,
        Constants.FEATURES >> 32 & 0xffffffff
    )

    static var txtRecord: Data {
        var txtRecord = [String: Data]()
        let txtFields = [
            "deviceid": "01:02:03:04:05:06",
            "features": features,
            "srcvers": Constants.SERVER_VERSION,
            "flags": "0x4",
            //"vv": "2", // Vodka version
            "protovers": "1.1", 
            "acl": "0", // Access ControL. 0,1,2 == anon,users,admin(?)
            "model": "Coucou", //
            "rsf": "0x0", // bitmask: required sender features(?)
            "fv": "p20.78000.12", // Firmware version. p20 == AirPlay Src revision?
            "gcgl": "0", // Group Contains Group Leader.
            "rhd": "5.6.0.0",
            "pw": "false", // No password
            "pk": "b07727d6f6cd6e08b58ede525ec3cdeaa252ad9f683feb212ef8a205246554e7",
            "pi": Constants.publicID
        ]

        txtFields.forEach {
            txtRecord[$0.0] = $0.1.data(using: .utf8)
        }

        return NetService.data(fromTXTRecord: txtRecord)
    }
}

private enum AirTunesMDNSProperties {
    static let type = "_raop._tcp."

    static let rtspPort: Int32 = 7001

    static var txtRecord: Data {
        var txtRecord = [String: Data]()
        let txtFields = [
            "ch": "2",
            "cn": "0,1,2,3", // Compression types (CODEC) => Apple Lossless (ALAC)
            "da": "true", // RFC2617 digest auth key
            "et": "0,3,5", // Encryption types => 1: RSA
            "vv": "2", // Vodka version
            "ft": "0x5A7FFFF7,0x1E", // Features
            "am": "AppleTV2,1", // Device model
            "md": "0,1,2", // Metadata types => 0: text, 1: artwork, 2: progress
            "rhd": "5.6.0.0",
            "pw": "false", // Password
            "sr": "44100",
            "ss": "16",
            "sv": "false",
            "tp": "UDP", // Transport types
            "txtvers": "1",
            "sf": "0x4", // System flags
            "vs": "220.68", // AirPlay version
            "vn": "65537", // AirTunes protocol version
            "pk": "b07727d6f6cd6e08b58ede525ec3cdeaa252ad9f683feb212ef8a205246554e7" // Public key
        ]

        txtFields.forEach {
            txtRecord[$0.0] = $0.1.data(using: .utf8)
        }

        return NetService.data(fromTXTRecord: txtRecord)
    }
}
