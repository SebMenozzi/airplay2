import Foundation

class ParameterParser: Parser {
    private let parameters: String

    required init?(data: Data) {
        guard let parameters = String(data: data, encoding: .utf8) else {
            return nil
        }

        self.parameters = parameters
    }

    func parse() -> [String: AnyHashable] {
        guard let progress = Progress(parameters: parameters) else {
            return [:]
        }

        return [
            "duration": progress.duration,
            "position": progress.position,
        ]
    }
}

private class Progress {
    private let startTime: Double
    private let currentTime: Double
    private let endTime: Double
    private let sampleRate = 44100.0  // Constant in AirPlay protocol

    init?(parameters: String) {
        guard let progress = parameters.match(
            "(progress: )([\\d\\/]*)", group: 2
        ) else {
            return nil
        }

        let components = progress.components(separatedBy: "/")

        startTime = Double(components[0])!
        currentTime = Double(components[1])!
        endTime = Double(components[2])!
    }

    var duration: TimeInterval {
        return round((endTime - startTime) / sampleRate)
    }
    
    var position: TimeInterval {
        let position = round((currentTime - startTime) / sampleRate)
        // AirPlay-reported position is off to allow for buffering
        let playbackDelay = 2.0

        return position - playbackDelay
    }
}
