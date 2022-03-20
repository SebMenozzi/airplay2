import Foundation

final class RTSPMessage: NSObject {

    let method: String // POST, GET, SETUP...
    let url: String
    let header: RTSPHeader
    let body: Data

    init(method: String, url: String, header: RTSPHeader, body: Data) {
        self.method = method
        self.url = url
        self.header = header
        self.body = body
    }
}
