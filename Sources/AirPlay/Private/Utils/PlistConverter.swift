import Foundation

/**
 PlistConverter is an utility class to handle plist and binary plist. Taken here:
 https://gist.github.com/ngbaanh/7c437d99bea75161a59f5af25be99de4
 */
final class PlistConverter {
    public struct PlistMimeType {
        static let xmlPlist    = "text/x-apple-plist+xml"
        static let binaryPlist = "application/x-apple-binary-plist"
    }

    // MARK: - Public

    convenience init?(binaryData: Data) {
        self.init(binaryData, format: .binaryFormat_v1_0)
    }

    convenience init?(xml: String) {
        guard let xmlData = xml.data(using: .utf8) else {
            return nil
        }

        self.init(xmlData, format: .xmlFormat_v1_0)
    }

    func convertToXML() -> String? {
        guard let xmlData = convert(to: .xmlFormat_v1_0) else {
            return nil
        }

        return String.init(data: xmlData, encoding: .utf8)
    }

    func convertToBinary() -> Data? {
        return convert(to: .binaryFormat_v1_0)
    }

    // MARK: - Private

    var plist: CFPropertyList?

    private init?(_ data: Data, format: CFPropertyListFormat) {
        var dataBytes = Array(data)
        let plistCoreData = CFDataCreate(kCFAllocatorDefault, &dataBytes, dataBytes.count)

        var error: Unmanaged<CFError>?
        var inputFormat = format
        let options = CFPropertyListMutabilityOptions.mutableContainersAndLeaves.rawValue
        plist = CFPropertyListCreateWithData(
            kCFAllocatorDefault,
            plistCoreData,
            options,
            &inputFormat,
            &error
        )?.takeUnretainedValue()

        guard plist != nil, nil == error else {
            print(
                "Error on CFPropertyListCreateWithData : ",
                error!.takeUnretainedValue(),
                "Return nil"
            )
            error?.release()
            return nil
        }

        error?.release()
    }

    private func convert(to format: CFPropertyListFormat) -> Data? {
        var error: Unmanaged<CFError>?
        let binary = CFPropertyListCreateData(
            kCFAllocatorDefault,
            plist,
            format,
            0,
            &error
        )?.takeUnretainedValue()

        let data = Data(bytes: CFDataGetBytePtr(binary), count: CFDataGetLength(binary))
        error?.release()

        return data
    }
}
