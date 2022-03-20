import Foundation

final class RTSPResponse {

    private var response: [String]
    private var body = Data()

    init() {
        response = ["RTSP/1.0 200 OK"]
    }

    func addSequenceNumber(_ number: Int) {
        response.append("CSeq: \(number)")
    }

    func addHeader(key: String, value: String) {
        response.append("\(key): \(value)")
    }

    func addContentType(type: String) {
        response.append("Content-Type: \(type)")
    }

    func addBody(body: Data) {
        self.body = body

        response.append("Content-Length: \(body.count)")
    }

    func replaceUnauthorized() {
        response = ["RTSP/1.0 401 Unauthorized"]
    }

    func replaceBadRequest() {
        response = ["RTSP/1.0 400 Bad Request"]
    }

    func build() -> Data {
        response.append("\r\n")

        let responseStr = response.joined(separator: "\r\n")
        let responseData = responseStr.data(using: .utf8)!

        return responseData + body
    }
}
