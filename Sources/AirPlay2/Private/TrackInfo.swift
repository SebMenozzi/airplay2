import Cocoa

class TrackInfo: NSObject {
    var name = ""
    var album = ""
    var artist = ""
    var position = -1.0
    var duration = -1.0
    var artwork = NSImage()

    func reset() {
        name = ""
        album = ""
        artist = ""
        position = -1.0
        duration = -1.0
        artwork = NSImage()
    }

    func update(withKeyedValues keyedValues: [String: AnyHashable]) {
        print(keyedValues)
        setValuesForKeys(keyedValues)
    }

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        return
    }
}
