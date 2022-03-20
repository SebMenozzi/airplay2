import Foundation

final class RTSPParser: NSObject {

    /// For clarity
    private let delimSpace = [UInt8](" ".utf8).first! // 32
    private let delimReturn = [UInt8]("\r".utf8).first! // 13
    private let delimBreak = [UInt8]("\n".utf8).first! // 10
    private let delimColon = [UInt8](":".utf8).first! // 58

    let stream: CustomStream

    init(data: Data) {
        self.stream = CustomStream(data: data)
    }

    // MARK: - Public

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

            guard let headerKeyBytes = stream.readBytes(with: delimColon, and: Constants.headerMaxKeyLength) else {
                fatalError("Invalid header key!")
            }

            let headerKey = String(bytes: headerKeyBytes, encoding: .utf8)!.lowercased()

            // https://tools.ietf.org/html/rfc2616
            // The field value MAY be preceded by any amount of spaces
            stream.skipBytesDelim(byte: delimSpace)

            // MARK: - Retrieve header value
            guard let headerValueBytes = stream.readBytes(with: delimReturn, and: Constants.headerMaxValueLength) else {
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

    func parse() -> RTSPMessage? {
        guard let methodBytes = stream.readBytes(with: delimSpace, and: Constants.requestMaxMethodLength),
              let method = String(bytes: methodBytes, encoding: .utf8),
              let urlBytes = stream.readBytes(with: delimSpace, and: Constants.requestMaxURLLength),
              let url = String(bytes: urlBytes, encoding: .utf8),
              let protocolBytes = stream.readBytes(with: delimReturn, and: Constants.requestMaxProtocolLength),
              let proto = String(bytes: protocolBytes, encoding: .utf8) else {
            return nil
        }

        if proto != Constants.rtspProtocol {
            return nil
        }

        if !stream.readByteEqual(byte: delimBreak) {
            return nil
        }

        let fields = parseHeaderFields()

        let header = RTSPHeader(fields: fields)
        let body = Data(stream.getLastBytes())

        if (
            header.contentLength != body.count ||
            header.contentLength > Constants.rtspMaxContentLength
           ) {
            return nil
        }

        return RTSPMessage(
            method: method,
            url: url,
            header: header,
            body: body
        )
    }
}
