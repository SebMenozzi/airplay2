import Foundation

let dateFormatter = DateFormatter()..{
    $0.dateFormat = "MM-dd-yyyy HH:mm:ss"
    $0.timeZone = .current
}
let dateString = dateFormatter.string(from: Date())

let airplay = AirPlay(name: dateString)
airplay.start()

while true {}
