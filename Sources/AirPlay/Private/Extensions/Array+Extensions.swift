import Foundation

extension Array {
    public static func copy(src: Array, srcPos: Int, dest: Array, destPos: Int, length: Int) {
        var dest = dest
        for i in 0...(length - 1) {
            dest[destPos + i] = src[srcPos + i]
        }
    }
}
