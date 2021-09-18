import Foundation

class RTSPResponse {
    private var response: [String]
    private var body = Data()

    init() {
        response = ["RTSP/1.0 200 OK"]
    }

    func addSetupResponse(serverPort: Int = 6010, controlPort: Int = 6011) {
        response.append(
            "Transport: RTP/AVP/UDP;" +
            "server_port=\(serverPort);control_port=\(controlPort)"
        )
        response.append("Session: 1")
    }

    func addSequenceNumber(_ number: Int) {
        response.append("CSeq: \(number)")
    }

    func addContentType(type: String) {
        response.append("Content-Type: \(type)")
    }

    func addBody(body: Data) {
        self.body = body

        response.append("Content-Length: \(body.count)")
    }

    func build() -> Data {
        response.append("\r\n")

        let responseStr = response.joined(separator: "\r\n")
        let responseData = responseStr.data(using: .utf8)!

        return responseData + body
    }
}
