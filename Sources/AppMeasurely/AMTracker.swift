import Foundation

/// Core tracker — builds payloads and sends events to AppMeasurely
class AMTracker {

    private let config: AMConfig
    private let deviceInfo = AMDeviceInfo()
    private let queue: AMQueue
    private let executor = DispatchQueue(label: "com.appmeasurely.tracker", qos: .background)
    private var userProperties: [String: Any] = [:]
    private var timer: Timer?
    var attStatus: Int = -1 // -1 = not set

    init(config: AMConfig) {
        self.config = config
        self.queue = AMQueue(maxSize: config.maxQueueSize)

        // Start periodic flush
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(
                withTimeInterval: TimeInterval(config.sendIntervalSeconds),
                repeats: true
            ) { [weak self] _ in
                self?.executor.async { self?.flushQueue() }
            }
        }
    }

    func trackInstallOrOpen() {
        let isFirst = deviceInfo.isFirstLaunch
        let eventName = isFirst ? "install" : "app_open"

        var payload = buildBasePayload(eventName: eventName)
        payload["is_first_launch"] = isFirst

        if isFirst {
            deviceInfo.markLaunched()
        }

        sendEvent(payload)
    }

    func trackSessionStart(sessionId: String) {
        var payload = buildBasePayload(eventName: "session_start")
        payload["session_id"] = sessionId
        sendEvent(payload)
    }

    func trackSessionEnd(sessionId: String, duration: TimeInterval) {
        var payload = buildBasePayload(eventName: "session_end")
        payload["session_id"] = sessionId
        payload["session_duration"] = Int(duration)
        sendEvent(payload)
    }

    func trackEvent(_ eventName: String, properties: [String: Any]?) {
        var payload = buildBasePayload(eventName: eventName)

        var mergedProps = userProperties
        if let props = properties {
            mergedProps.merge(props) { _, new in new }
        }
        if !mergedProps.isEmpty {
            payload["properties"] = mergedProps
        }

        sendEvent(payload)
    }

    func trackRevenue(_ amount: Double, currency: String, eventName: String, properties: [String: Any]?) {
        var payload = buildBasePayload(eventName: eventName)
        payload["revenue"] = amount
        payload["currency"] = currency

        if let props = properties, !props.isEmpty {
            payload["properties"] = props
        }

        sendEvent(payload)
    }

    func setUserProperty(_ key: String, value: Any) {
        userProperties[key] = value
    }

    private func buildBasePayload(eventName: String) -> [String: Any] {
        var payload: [String: Any] = [
            "app_key": config.appKey,
            "event_name": eventName,
            "device_id": deviceInfo.deviceId,
            "device_type": "ios",
            "os_version": deviceInfo.osVersion,
            "device_model": deviceInfo.deviceModel,
            "app_version": deviceInfo.appVersion,
            "language": deviceInfo.language,
            "screen_width": deviceInfo.screenWidth,
            "screen_height": deviceInfo.screenHeight,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        if attStatus >= 0 {
            let attStatusString: String
            switch attStatus {
            case 0: attStatusString = "not_determined"
            case 1: attStatusString = "restricted"
            case 2: attStatusString = "denied"
            case 3: attStatusString = "authorized"
            default: attStatusString = "not_determined"
            }
            payload["att_status"] = attStatusString
        }

        return payload
    }

    private func sendEvent(_ event: [String: Any]) {
        queue.add(event)
        executor.async { [weak self] in
            self?.flushQueue()
        }
    }

    func flushQueue() {
        while !queue.isEmpty {
            guard let event = queue.peek() else { break }
            let success = sendWithRetry(event: event, retriesLeft: 3)
            if success {
                _ = queue.poll()
            } else {
                break // Stop flushing, will retry later
            }
        }
    }

    private func sendWithRetry(event: [String: Any], retriesLeft: Int) -> Bool {
        guard let url = URL(string: config.endpoint) else { return false }
        guard let body = try? JSONSerialization.data(withJSONObject: event) else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.appKey, forHTTPHeaderField: "apikey")
        request.httpBody = body
        request.timeoutInterval = 10

        var success = false
        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                self?.log("Event sent: \(event["event_name"] ?? "") → \(httpResponse.statusCode)")

                if httpResponse.statusCode == 429 {
                    // Rate limited
                    success = false
                } else {
                    success = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
                }
            } else if retriesLeft > 0 {
                Thread.sleep(forTimeInterval: 2)
                success = self?.sendWithRetry(event: event, retriesLeft: retriesLeft - 1) ?? false
            }
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return success
    }

    private func log(_ message: String) {
        if config.debugMode {
            print("[AppMeasurely] \(message)")
        }
    }

    deinit {
        timer?.invalidate()
    }
}
