import Foundation

class RTSPHeader: NSObject {
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

class RTSPMessage: NSObject {
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

class RTSPParser: NSObject {
    // For convinience
    private let delimSpace = [UInt8](" ".utf8).first! // 32
    private let delimReturn = [UInt8]("\r".utf8).first! // 13
    private let delimBreak = [UInt8]("\n".utf8).first! // 10
    private let delimColon = [UInt8](":".utf8).first! // 58

    let stream: CustomStream

    init(data: Data) {
        self.stream = CustomStream(data: data)
    }

    func parseHeaderFields() -> [String: String] {
        var fieldsCount = 0
        var fields = [String: String]()

        while true {
            // MARK: - Check header termination
            guard let lastByte = stream.readByte() else {
                fatalError("No header termination!")
            }

            if lastByte == delimReturn {
                if !stream.readByteEqual(byte: delimBreak) {
                    fatalError("\\n should preceed a \\r!")
                }

                break
            } else {
                stream.unread()
            }

            // MARK: - Retrieve header key
            if fieldsCount >= Constants.headerMaxFieldsCount {
                fatalError("\(fieldsCount) number of fields, should be a maximum of \(Constants.headerMaxFieldsCount) fields!")
            }

            guard let headerKeyBytes = stream.readBytesDelim(byte: delimColon, n: Constants.headerMaxKeyLength) else {
                fatalError("Invalid header key!")
            }

            let headerKey = String(bytes: headerKeyBytes, encoding: .utf8)!.lowercased()

            // https://tools.ietf.org/html/rfc2616
            // The field value MAY be preceded by any amount of spaces
            stream.skipBytesDelim(byte: delimSpace)

            // MARK: - Retrieve header value
            guard let headerValueBytes = stream.readBytesDelim(byte: delimReturn, n: Constants.headerMaxValueLength) else {
                fatalError("Invalid header value!")
            }

            let headerValue = String(bytes: headerValueBytes, encoding: .utf8)!.lowercased()

            if !stream.readByteEqual(byte: delimBreak) {
                fatalError("\\n should preceed a \\r!")
            }

            fields[headerKey] = headerValue
            fieldsCount += 1
        }

        return fields
    }

    func parseBody(header: RTSPHeader, body: Data) {
        if header.contentType == Constants.bplistContentType {
            var plistFormat = PropertyListSerialization.PropertyListFormat.binary

            guard let propertyList = try? PropertyListSerialization.propertyList(
                    from: body,
                    options: [],
                    format: &plistFormat
            ) else {
                fatalError("Failure to deserialize the binary plist")
            }
        }
    }

    func parse() -> RTSPMessage {
        guard let methodBytes = stream.readBytesDelim(byte: delimSpace, n: Constants.requestMaxMethodLength) else {
            fatalError("No Method found")
        }

        let method = String(bytes: methodBytes, encoding: .utf8)!

        guard let urlBytes = stream.readBytesDelim(byte: delimSpace, n: Constants.requestMaxURLLength) else {
            fatalError("No URL found")
        }

        let url = String(bytes: urlBytes, encoding: .utf8)!

        guard let protocolBytes = stream.readBytesDelim(byte: delimReturn, n: Constants.requestMaxProtocolLength) else {
            fatalError("No Protocol found")
        }

        let proto = String(bytes: protocolBytes, encoding: .utf8)!

        if proto != Constants.rtspProtocol {
            fatalError("Expected Protocol \(Constants.rtspProtocol)")
        }

        if !stream.readByteEqual(byte: delimBreak) {
            fatalError("Expected \\n after \(Constants.rtspProtocol)")
        }

        let fields = parseHeaderFields()

        let header = RTSPHeader(fields: fields)
        let body = Data(stream.getLastBytes())

        if (
            header.contentLength != body.count ||
            header.contentLength > Constants.rtspMaxContentLength
           ) {
            fatalError("Invalid Content Body")
        }

        parseBody(header: header, body: body)

        return RTSPMessage(
            method: method,
            url: url,
            header: header,
            body: body
        )
    }
}
