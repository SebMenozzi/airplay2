import Foundation

final class SessionService {

    private let bonjourService: BonjourService
    private let airTunesService: AirTunesService

    init(name: String) {
        self.bonjourService = BonjourService(name: name)
        self.airTunesService = AirTunesService()
    }

    func start() {
        bonjourService.start()
        airTunesService.start()
    }
}
