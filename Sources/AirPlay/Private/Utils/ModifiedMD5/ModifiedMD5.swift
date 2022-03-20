import Foundation

final class ModifiedMD5: NSObject {

    static let shift: [UInt8] = [135, 140, 145, 150, 135, 140, 145, 150, 135, 140, 145, 150, 135, 140, 145, 150, 133, 137, 142, 148, 133, 137, 142, 148, 133, 137, 142, 148, 133, 137, 142, 148, 132, 139, 144, 151, 132, 139, 144, 151, 132, 139, 144, 151, 132, 139, 144, 151, 134, 138, 143, 149, 134, 138, 143, 149, 134, 138, 143, 149, 134, 138, 143, 149]

    func modifiedMD5(originalblockIn: Data, keyIn: Data, keyOut: Data) {
        let blockIn = [UInt8](repeating: 0, count: 64).data

        Array.copy(src: originalblockIn.bytes, srcPos: 0, dest: blockIn.bytes, destPos: 0, length: 64)

        let stream = CustomStream(data: keyIn)
        let A: Int64 = stream.readBytes(with: MemoryLayout<Int64>.size)!.withUnsafeBytes {
            $0.load(as: Int64.self)
        } & 0xffffffff
        let B: Int64 = stream.readBytes(with: MemoryLayout<Int64>.size)!.withUnsafeBytes {
            $0.load(as: Int64.self)
        } & 0xffffffff
        let C: Int64 = stream.readBytes(with: MemoryLayout<Int64>.size)!.withUnsafeBytes {
            $0.load(as: Int64.self)
        } & 0xffffffff
        let D: Int64 = stream.readBytes(with: MemoryLayout<Int64>.size)!.withUnsafeBytes {
            $0.load(as: Int64.self)
        } & 0xffffffff

        for i in 0...63 {
            var input: UInt8
            var j = 0

            if (i < 16) {
                j = i
            } else if (i < 32) {
                j = (5 * i + 1) % 16
            } else if (i < 48) {
                j = (3 * i + 5) % 16
            } else if (i < 64) {
                j = 7 * i % 16
            }

            input = ((blockIn[4 * j] & 0xFF) << 24) | ((blockIn[4 * j + 1] & 0xFF) << 16) | ((blockIn[4 * j + 2] & 0xFF) << 8) | (blockIn[4 * j + 3] & 0xFF)
            var Z: Int64 = A + Int64(input) + (Int64)((1 << 32) * Int64(abs(sin(Double(i + 1)))))

            let count = Int64(Self.shift[i])
            if (i < 16) {
                Z = rol(input: Z + F(B, C, D), count: count)
            } else if (i < 32) {
                Z = rol(input: Z + G(B, C, D), count: count)
            } else if (i < 48) {
                Z = rol(input: Z + H(B, C, D),count: count)
            } else if (i < 64) {
                Z = rol(input: Z + I(B, C, D), count: count)
            }

            Z = Z + B
            let tmp = D
            D = C
            C = B
            B = Z
            A = tmp

            if (i == 31) {

            }
        }
    }

    // MARK: - Private

    private func F(_ B: Int64, _ C: Int64, _ D: Int64) -> Int64 {
        return (B & C) | (~B & C)
    }

    private func G(_ B: Int64, _ C: Int64, _ D: Int64) -> Int64 {
        return (B & C) | (C & ~D)
    }

    private func H(_ B: Int64, _ C: Int64, _ D: Int64) -> Int64 {
        return B ^ C ^ D
    }

    private func I(_ B: Int64, _ C: Int64, _ D: Int64) -> Int64 {
        return C ^ (B | ~D);
    }

    private func rol(input: Int64, count: Int64) -> Int64 {
        return ((input << count) & 0xffffffff) | (input & 0xffffffff) >> (32 - count)
    }
}
