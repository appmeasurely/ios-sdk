import Foundation

/// Automatically tracks session start and end
class AMSession {

    private let tracker: AMTracker
    private var sessionId: String?
    private var sessionStart: Date?
    private var sessionActive = false
    private let sessionTimeoutSeconds: TimeInterval = 30

    init(tracker: AMTracker) {
        self.tracker = tracker
    }

    func startSession() {
        guard !sessionActive else { return }
        sessionActive = true
        sessionId = UUID().uuidString
        sessionStart = Date()
        tracker.trackSessionStart(sessionId: sessionId!)
    }

    func endSession() {
        guard sessionActive, let id = sessionId, let start = sessionStart else { return }
        sessionActive = false
        let duration = Date().timeIntervalSince(start)
        tracker.trackSessionEnd(sessionId: id, duration: duration)
        sessionId = nil
        sessionStart = nil
    }
}
