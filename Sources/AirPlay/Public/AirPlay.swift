import Foundation

public class AirPlay: NSObject {
    private let service: SessionService

    public init(name: String) {
        // Hard-code a random address to avoid the
        // convoluted lookup process
        let hardwareAddress: [UInt8] = [184, 199, 93, 59, 114, 43]

        service = SessionService(name: name, hardwareAddress: hardwareAddress)
    }

    public func start() {
        service.start()
    }
}
