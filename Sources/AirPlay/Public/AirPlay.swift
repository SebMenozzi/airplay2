import Foundation

public class AirPlay: NSObject {
    private let sessionService: SessionService
    private let bonjourService: BonjourService
    private let airTunesService: AirTunesService
    private let mirroringService: MirroringService

    public init(name: String) {
        sessionService = SessionService()
        bonjourService = BonjourService(name: name)
        airTunesService = AirTunesService(sessionService: sessionService)
        mirroringService = MirroringService(sessionService: sessionService)
    }

    public func start() {
        print("Starting...")

        bonjourService.start()
        airTunesService.start()
        mirroringService.start()
    }
}
