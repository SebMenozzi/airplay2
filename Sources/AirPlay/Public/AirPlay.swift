import Foundation

public class AirPlay: NSObject {
    private let service: SessionService

    public init(name: String) {
        service = SessionService(name: name)
    }

    public func start() {
        print("Starting...")

        service.start()
    }
}
