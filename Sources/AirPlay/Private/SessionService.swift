import Foundation

final class SessionService {
    private let bonjourService: BonjourService
    private let airTunesService: AirTunesService
    private let mirrorService: MirrorService

    init(name: String, airTunesPort: UInt16 = 5001, airPlayPort: UInt16 = 7001, hardwareAddress: [UInt8]) {
        self.bonjourService = BonjourService(
            name: name,
            airTunesPort: airTunesPort,
            airPlayPort: airPlayPort,
            hardwareAddress: hardwareAddress
        )

        self.airTunesService = AirTunesService(port: airTunesPort)
        self.mirrorService = MirrorService(port: airPlayPort)
    }

    func start() {
        bonjourService.publish()
        airTunesService.start()

        mirrorService.start()
    }
}
