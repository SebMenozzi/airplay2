import Foundation

/**
 Bonjour Discovery Service.

 AirPlay can find devices thanks to mDNS protocol.
 In a local network, the server advertises two services (AirTunes service and AirPlay service) publishing 'A', 'TXT', 'PTR' and 'SRV' records.
 The client, on the other hand, sends an IP multicast query message to identify the receiver.

 - airPlayService: AirPlay service is used to send/receive audio and video streaming.
 - airTunesService: AirTunes service is used to exchange informations between devices.
*/

final class BonjourService: NSObject {

    private var airPlayService: NetService!
    private var airTunesService: NetService!
    private let name: String

    init(name: String) {
        self.name = name

        super.init()
    }
    
    func start() {
        createAirTunesService()
        createAirPlayService()

        airTunesService.publish()
        airPlayService.publish()
    }

    private func createAirTunesService() {
        let airTunesServerName = Constants.hardwareAddress.reduce("", {$0 + String(format: "%02X", $1)}) + "@\(name)"

        airTunesService = NetService(
            domain: "", // Default domain name registry
            type: AirTunesMDNSProperties.type,
            name: airTunesServerName,
            port: Int32(Constants.airTunesPort)
        )

        let recordData = createRecordData(from: AirTunesMDNSProperties.txtFields)
        airTunesService.setTXTRecord(recordData)
    }

    private func createAirPlayService() {
        airPlayService = NetService(
            domain: "", // Default domain name registry
            type: AirPlayMDNSProperties.type,
            name: name,
            port: Int32(Constants.airPlayPort)
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
    static let type = "_raop._tcp."

    static var txtFields: [String: String] = [
        "ch": "2", // Number of audio channels
        "cn": "0,1,2,3", // Audio codecs => Apple Lossless (ALAC)
        "et": "0,3,5", // Encryption types
        "md": "0,1,2", // Metadata types => 0: text, 1: artwork, 2: progress
        "sr": "44100", // Audio sample rate: 44100 Hz
        "ss": "16", // Audio sample size: 16-bit
        "da": "true", // RFC2617 digest auth key
        "sv": "false",
        "ft": "0x5A7FFFF7,0x1E", // Features
        "am": Constants.deviceModel, // Device model
        "pk": Constants.publicKey, // Public key
        "sf": "0x4",  // System flags
        "tp": "UDP", // Transport types
        "vn": "65537",
        "vs": "220.68", // AirPlay version
        "vv": "2", // Vodka version
        "pw": "false" // Password
   ]
}


private enum AirPlayMDNSProperties {
    static let type = "_airplay._tcp."

    /*
    static let features = String(
        format: "0x%llX,0x%llX",
        Constants.FEATURES & 0xffffffff,
        Constants.FEATURES >> 32 & 0xffffffff
    )
    */

    static var txtFields: [String: String] = [
        "deviceid": Constants.hardwareAddress.map({ String(format: "%02X", $0) }).joined(separator: ":"),
        "features": "0x5A7FFFF7,0x1E",
        "flags": "0x4", // System flags
        "model": Constants.deviceModel, // Device model
        "pk": Constants.publicKey, // Public Key
        "pi": Constants.airPlayPairingIdentifier, // PublicCUAirPlayPairingIdentifier
        "srcvers": "220.68", // Receiver version
        "vv": "2", // Vodka version
        "pw": "false" // Password
    ]
}
