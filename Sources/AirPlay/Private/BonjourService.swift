import Foundation

final class BonjourService {
    private var airPlayService: NetService!
    private var airTunesService: NetService!

    private let airTunesPort: UInt16
    private let airPlayPort: UInt16
    private let name: String
    private let hardwareAddress: [UInt8]

    init(name: String, airTunesPort: UInt16, airPlayPort: UInt16, hardwareAddress: [UInt8]) {
        self.airTunesPort = airTunesPort
        self.airPlayPort = airPlayPort
        self.name = name
        self.hardwareAddress = hardwareAddress
    }
    
    func publish() {
        createAirTunesService()
        airTunesService.publish()

        createAirPlayService()
        airPlayService.publish()
    }

    private func createAirTunesService() {
        let airTunesServerName = hardwareAddress.reduce("", {$0 + String(format: "%02X", $1)}) + "@\(name)"

        airTunesService = NetService(
            domain: "local.",
            type: AirTunesMDNSProperties.type,
            name: airTunesServerName,
            port: Int32(airTunesPort)
        )

        let recordData = createRecordData(from: AirTunesMDNSProperties.txtFields)
        airTunesService.setTXTRecord(recordData)
    }

    private func createAirPlayService() {
        airPlayService = NetService(
            domain: "local.",
            type: AirPlayMDNSProperties.type,
            name: name,
            port: Int32(airPlayPort)
        )

        let recordData = createRecordData(from: AirPlayMDNSProperties.txtFields)
        airPlayService.setTXTRecord(recordData)
    }

    private func createRecordData(from txtFields: [String: String]) -> Data {
        var txtRecord = [String: Data]()

        txtFields.forEach {
            txtRecord[$0.0] = $0.1.data(using: .utf8)
        }

        return NetService.data(fromTXTRecord: txtRecord)
    }
}

private enum AirTunesMDNSProperties {
    static let type = "_raop._tcp"

    static var txtFields: [String: String] = [
        "et": "0,3,5", // Encryption types
        "sf": "0x4",  // System flags
        "tp": "UDP", // Transport types
        "vn": "3", // AirTunes protocol version
        "cn": "2,3", // Compression types (CODEC) => Apple Lossless (ALAC)
        "md": "0,1,2", // Metadata types => 0: text, 1: artwork, 2: progress
        "pw": "false", // Password
        "sr": "44100", // Audio sample rate: 44100 Hz
        "ss": "16", // Audio sample size: 16-bit
        "sv": "false",
        "da": "true", // RFC2617 digest auth key
        "vv": "2", // Vodka version
        "vs": "220.68", // AirPlay version
        "ch": "2",
        //"am": "AppleTV5,3", // Device model
        "ft": "0x5A7FFFF7,0x1E", // Features
        "rhd": "5.6.0.0",
        "pk": "b07727d6f6cd6e08b58ede525ec3cdeaa252ad9f683feb212ef8a205246554e7", // Public key
   ]
}


private enum AirPlayMDNSProperties {
    static let type = "_airplay._tcp"

    /*
    static let features = String(
        format: "0x%llX,0x%llX",
        Constants.FEATURES & 0xffffffff,
        Constants.FEATURES >> 32 & 0xffffffff
    )
    */

    static var txtFields: [String: String] = [
        "deviceid": "01:02:03:04:05:06",
        "features": "0x5A7FFFF7,0x1E",
        "srcvers": "220.68",
        "flags": "0x4",
        "vv": "2", // Vodka version
        "model": "AppleTV5,3", // Device model
        "rhd": "5.6.0.0",
        "pw": "false", // No password
        "pk": "b07727d6f6cd6e08b58ede525ec3cdeaa252ad9f683feb212ef8a205246554e7",
        "pi": "2e388006-13ba-4041-9a67-25dd4a43d536"
    ]
}
