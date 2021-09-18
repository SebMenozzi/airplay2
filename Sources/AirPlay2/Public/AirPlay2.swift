import Foundation

public class AirPlay2: NSObject {
    private let manager: SessionManager

    /// Creates an `AirTunes` instance with the specified delegate.
    ///
    /// - Parameter name: The name by which the service is identified to the 
    /// network.
    /// - Parameter delegate: The object to be notified of changes to the
    /// player or track info. Defaults to `nil`.
    public init(name: String) {
        self.manager = SessionManager(name: name)
    }

    /// Starts the server and listens for client connections.
    public func start() {
        manager.start()

        observeTrackInfoChanges(for: manager.trackInfo)
        observePlayerInfoChanges(for: manager.playerInfo)
    }

    public func play() {
        manager.play()
    }

    public func pause() {
        manager.pause()
    }

    public func next() {
        manager.next()
    }

    public func previous() {
        manager.previous()
    }

    private func observeTrackInfoChanges(for trackInfo: TrackInfo) {
        ["name", "album", "artist", "position", "duration", "artwork"].forEach() {
            trackInfo.addObserver(self, forKeyPath: $0, options: [], context: nil)
        }
    }

    private func observePlayerInfoChanges(for playerInfo: PlayerInfo) {
        ["isPlaying", "volume"].forEach() {
            playerInfo.addObserver(self, forKeyPath: $0, options: [], context: nil)
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let object = object as? TrackInfo {
            print(object.duration)
        }

    }
}
