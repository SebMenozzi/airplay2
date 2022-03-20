import Foundation

final class RTSPHeader: NSObject {

    // https://emanuelecozzi.net/docs/airplay2/rtsp/
    let contentType: String? // Type of content
    let contentLength: Int // Length of the content/body after the headers
    let activeRemote: String // Authentication token for the DACP server
    let cseq: Int // Specifies the sequence number for an RTSP request
    let dacpID: String // 64-bit value identifying the DACP server

    init(fields: [String: String]) {
        self.contentType = fields["content-type"]
        self.contentLength = Int(fields["content-length"] ?? "0") ?? 0
        self.activeRemote = fields["active-remote"]!
        self.cseq = Int(fields["cseq"]!)!
        self.dacpID = fields["dacp-id"]!
    }
}
