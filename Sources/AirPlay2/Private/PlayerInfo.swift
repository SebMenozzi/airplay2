import Foundation

class PlayerInfo: NSObject {
    dynamic var isPlaying = false
    dynamic var volume = -30.0

    func update(withKeyedValues keyedValues: [String: AnyHashable]) {
        setValuesForKeys(keyedValues)
    }

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        return
    }
}
