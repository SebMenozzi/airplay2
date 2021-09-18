import Foundation

class CryptoService {
    private let privateKey: CFData

    init() {
        privateKey = RSAPrivateKey
    }

    func decrypt(_ data: Data) -> Data {
        return transform(data, type: .Decrypt)
    }

    func sign(_ data: Data) -> Data {
        return transform(data, type: .Sign)
    }

    private enum SecTransformType {
        case Sign
        case Decrypt
    }

    private func transform(_ input: Data, type: SecTransformType) -> Data {
        let parameters: [NSString: AnyObject] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ]
        let key = SecKeyCreateFromData(
            parameters as CFDictionary, privateKey, nil)!
        var transform: SecTransform
        if type == .Sign {
            transform = SecSignTransformCreate(key, nil)!
            SecTransformSetAttribute(
                transform, kSecInputIsAttributeName, kSecInputIsRaw, nil)
        }
        else {
            transform = SecDecryptTransformCreate(key, nil)
            SecTransformSetAttribute(
                transform, kSecPaddingKey, kSecPaddingOAEPKey, nil)
        }
        SecTransformSetAttribute(
            transform, kSecTransformInputAttributeName, input as CFTypeRef, nil)
        return SecTransformExecute(transform, nil) as! Data
    }
}

var RSAPrivateKey: CFData! {
    var privateKeyBytes: [UInt8] = [
        48, 130, 4, 165, 2, 1, 0, 2, 130, 1, 1, 0, 231, 215, 68, 242, 162, 226, 120, 139, 108,
        31, 85, 160, 142, 183, 5, 68, 168, 250, 121, 69, 170, 139, 230, 198, 44, 229, 245, 28,
        189, 212, 220, 104, 66, 254, 61, 16, 131, 221, 46, 222, 193, 191, 212, 37, 45, 192,
        46, 111, 57, 139, 223, 14, 97, 72, 234, 132, 133, 94, 46, 68, 45, 166, 214, 38, 100,
        246, 116, 161, 243, 4, 146, 154, 222, 79, 104, 147, 239, 45, 246, 231, 17, 168, 199,
        122, 13, 145, 201, 217, 128, 130, 46, 80, 209, 41, 34, 175, 234, 64, 234, 159, 14, 20,
        192, 247, 105, 56, 197, 243, 136, 47, 192, 50, 61, 217, 254, 85, 21, 95, 81, 187, 89,
        33, 194, 1, 98, 159, 215, 51, 82, 213, 226, 239, 170, 191, 155, 160, 72, 215, 184, 19,
        162, 182, 118, 127, 108, 60, 207, 30, 180, 206, 103, 61, 3, 123, 13, 46, 163, 12, 95,
        255, 235, 6, 248, 208, 138, 221, 228, 9, 87, 26, 156, 104, 159, 239, 16, 114, 136, 85,
        221, 140, 251, 154, 139, 239, 92, 137, 67, 239, 59, 95, 170, 21, 221, 230, 152, 190,
        221, 243, 89, 150, 3, 235, 62, 111, 97, 55, 43, 182, 40, 246, 85, 159, 89, 154, 120,
        191, 80, 6, 135, 170, 127, 73, 118, 192, 86, 45, 65, 41, 86, 248, 152, 158, 24, 166,
        53, 91, 216, 21, 151, 130, 94, 15, 200, 117, 52, 62, 199, 130, 17, 118, 37, 205, 191,
        152, 68, 123, 2, 3, 1, 0, 1, 2, 130, 1, 1, 0, 229, 240, 12, 114, 245, 119, 214, 4,
        185, 164, 206, 65, 34, 170, 132, 176, 23, 67, 236, 153, 90, 207, 204, 127, 74, 178,
        124, 11, 24, 127, 144, 102, 91, 227, 89, 223, 18, 89, 129, 141, 238, 237, 121, 211,
        177, 239, 132, 94, 77, 221, 218, 201, 161, 85, 55, 59, 94, 39, 13, 142, 19, 21, 0, 26,
        46, 82, 125, 84, 205, 249, 0, 10, 87, 104, 188, 152, 212, 68, 107, 55, 187, 189, 0,
        178, 157, 216, 181, 48, 98, 19, 59, 42, 110, 119, 244, 238, 50, 80, 86, 34, 144, 77,
        167, 32, 251, 28, 18, 192, 57, 150, 218, 113, 58, 5, 6, 9, 142, 219, 237, 236, 249,
        54, 208, 250, 156, 189, 89, 41, 171, 176, 237, 163, 87, 153, 80, 47, 152, 148, 220,
        184, 252, 86, 154, 137, 45, 23, 120, 3, 36, 162, 182, 195, 22, 110, 52, 103, 9, 19,
        75, 133, 64, 65, 184, 103, 112, 107, 88, 254, 242, 160, 219, 146, 43, 119, 98, 139,
        104, 230, 150, 147, 199, 175, 67, 191, 42, 115, 208, 183, 50, 55, 122, 11, 161, 123,
        68, 240, 81, 233, 191, 121, 132, 157, 203, 51, 50, 87, 31, 216, 167, 9, 51, 194, 214,
        11, 222, 196, 121, 147, 74, 61, 172, 164, 11, 182, 242, 243, 124, 10, 157, 7, 16,
        110, 173, 200, 179, 105, 160, 63, 47, 65, 200, 128, 9, 142, 138, 221, 70, 36, 13,
        172, 104, 204, 83, 84, 243, 97, 2, 129, 129, 0, 247, 224, 191, 90, 30, 103, 24, 49,
        154, 139, 98, 9, 195, 23, 20, 68, 4, 89, 249, 115, 133, 102, 19, 177, 122, 225, 80,
        139, 179, 230, 49, 110, 107, 127, 70, 45, 47, 125, 100, 65, 43, 132, 183, 107, 194,
        63, 43, 12, 53, 98, 69, 82, 121, 178, 67, 169, 247, 49, 111, 149, 128, 7, 179, 76, 97,
        247, 104, 226, 212, 78, 213, 255, 43, 39, 40, 23, 236, 50, 179, 228, 147, 146, 146,
        40, 250, 231, 142, 119, 76, 160, 247, 94, 189, 105, 213, 146, 2, 121, 143, 17, 110,
        54, 12, 100, 56, 179, 46, 27, 216, 185, 220, 30, 50, 50, 240, 211, 9, 24, 136, 60,
        196, 62, 248, 221, 162, 44, 54, 145, 2, 129, 129, 0, 239, 111, 255, 249, 148, 241,
        229, 100, 65, 170, 0, 53, 253, 25, 160, 200, 214, 240, 35, 120, 199, 5, 128, 217, 196,
        132, 32, 121, 29, 244, 7, 197, 145, 251, 110, 191, 202, 50, 44, 48, 134, 221, 144, 31,
        210, 250, 225, 174, 187, 100, 173, 246, 187, 121, 255, 128, 81, 190, 189, 12, 216, 32,
        171, 137, 135, 64, 6, 1, 167, 178, 254, 147, 144, 202, 204, 154, 202, 184, 237, 43,
        249, 29, 24, 109, 143, 105, 100, 61, 126, 254, 15, 93, 86, 223, 117, 119, 162, 208,
        53, 234, 84, 19, 252, 152, 216, 243, 249, 8, 218, 5, 154, 55, 157, 164, 177, 204, 56,
        241, 93, 86, 10, 131, 204, 49, 113, 83, 200, 75, 2, 129, 129, 0, 208, 235, 175, 188,
        64, 37, 186, 129, 140, 117, 112, 35, 52, 56, 78, 143, 105, 111, 128, 77, 122, 160,
        231, 118, 78, 80, 123, 183, 211, 223, 239, 199, 214, 120, 198, 104, 45, 63, 173, 113,
        52, 65, 190, 234, 231, 36, 160, 158, 192, 155, 220, 59, 192, 112, 156, 145, 51, 212,
        137, 236, 226, 165, 26, 221, 5, 49, 39, 73, 15, 146, 134, 209, 115, 200, 164, 5, 77,
        194, 10, 87, 92, 126, 76, 12, 152, 52, 244, 161, 222, 135, 73, 23, 163, 228, 0, 234,
        248, 133, 6, 45, 181, 203, 126, 52, 54, 137, 231, 17, 247, 95, 231, 131, 215, 225,
        145, 146, 253, 118, 156, 213, 66, 190, 164, 185, 1, 7, 236, 209, 2, 129, 128, 127, 64,
        24, 220, 125, 234, 41, 45, 165, 48, 66, 56, 111, 49, 5, 160, 119, 138, 220, 111, 61,
        230, 144, 218, 43, 116, 197, 5, 89, 131, 237, 245, 116, 102, 26, 47, 215, 183, 222,
        128, 83, 204, 192, 226, 8, 240, 200, 172, 98, 111, 89, 125, 61, 153, 210, 206, 81,
        163, 123, 57, 174, 75, 126, 158, 242, 192, 117, 240, 191, 61, 131, 202, 205, 50, 218,
        150, 145, 146, 194, 137, 146, 53, 130, 92, 7, 209, 205, 50, 89, 161, 144, 108, 220,
        212, 153, 203, 97, 62, 34, 201, 76, 177, 234, 151, 25, 6, 96, 157, 241, 176, 244, 139,
        6, 63, 23, 55, 32, 52, 54, 148, 153, 181, 253, 249, 112, 239, 68, 13, 2, 129, 129, 0,
        144, 78, 233, 32, 249, 68, 239, 90, 175, 124, 148, 32, 160, 15, 94, 155, 72, 8, 44,
        11, 132, 224, 251, 181, 221, 162, 162, 38, 119, 223, 183, 184, 72, 141, 178, 190, 230,
        76, 155, 221, 60, 172, 102, 250, 50, 14, 118, 247, 28, 226, 175, 34, 114, 187, 189,
        118, 202, 185, 78, 8, 74, 12, 65, 217, 176, 119, 29, 198, 51, 64, 193, 172, 207, 90,
        137, 218, 1, 180, 55, 152, 111, 38, 156, 240, 194, 22, 225, 94, 161, 74, 3, 140, 218,
        105, 42, 240, 235, 109, 176, 14, 120, 128, 43, 147, 37, 32, 77, 45, 32, 2, 138, 63,
        140, 177, 52, 104, 232, 15, 100, 24, 142, 16, 70, 186, 27, 228, 88, 166
    ]

    return CFDataCreate(kCFAllocatorDefault, &privateKeyBytes, privateKeyBytes.count)
}