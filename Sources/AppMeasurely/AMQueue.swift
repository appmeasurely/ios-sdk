import Foundation

/// Offline event queue — stores events locally and sends when network is available
class AMQueue {

    private let userDefaultsKey = "am_event_queue"
    private let maxSize: Int
    private var queue: [[String: Any]] = []
    private let lock = NSLock()

    init(maxSize: Int) {
        self.maxSize = maxSize
        loadFromDisk()
    }

    func add(_ event: [String: Any]) {
        lock.lock()
        defer { lock.unlock() }

        if queue.count >= maxSize {
            queue.removeFirst()
        }
        queue.append(event)
        saveToDisk()
    }

    func poll() -> [String: Any]? {
        lock.lock()
        defer { lock.unlock() }

        guard !queue.isEmpty else { return nil }
        let event = queue.removeFirst()
        saveToDisk()
        return event
    }

    func peek() -> [String: Any]? {
        lock.lock()
        defer { lock.unlock() }
        return queue.first
    }

    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return queue.isEmpty
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return queue.count
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        queue.removeAll()
        saveToDisk()
    }

    private func saveToDisk() {
        if let data = try? JSONSerialization.data(withJSONObject: queue) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    private func loadFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let stored = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return
        }
        queue = stored
    }
}
