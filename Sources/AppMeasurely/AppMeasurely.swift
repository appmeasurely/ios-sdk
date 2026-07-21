import Foundation
import UIKit

/// AppMeasurely iOS SDK
/// Mobile attribution and analytics tracking
///
/// Usage:
///   AppMeasurely.start(appKey: "YOUR_APP_KEY")

@objc public class AppMeasurely: NSObject {

    // MARK: - Singleton
    @objc public static let shared = AppMeasurely()

    // MARK: - Private properties
    private var config: AMConfig?
    private var tracker: AMTracker?
    private var session: AMSession?
    private var initialized = false

    private override init() {
        super.init()
    }

    // MARK: - Initialization

    /// Initialize the SDK — call this in AppDelegate.application(_:didFinishLaunchingWithOptions:)
    @objc public static func start(appKey: String) {
        shared.start(config: AMConfig(appKey: appKey))
    }

    /// Initialize with custom config
    @objc public static func start(config: AMConfig) {
        shared.start(config: config)
    }

    private func start(config: AMConfig) {
        self.config = config
        self.tracker = AMTracker(config: config)
        self.session = AMSession(tracker: tracker!)
        self.initialized = true

        // Register for app lifecycle notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )

        // Track install or open
        tracker?.trackInstallOrOpen()
    }

    // MARK: - App Lifecycle

    @objc private func appDidBecomeActive() {
        session?.startSession()
    }

    @objc private func appDidEnterBackground() {
        session?.endSession()
    }

    @objc private func appWillTerminate() {
        session?.endSession()
        tracker?.flushQueue()
    }

    // MARK: - Public API

    /// Track a custom event
    @objc public static func trackEvent(_ eventName: String) {
        trackEvent(eventName, properties: nil)
    }

    /// Track a custom event with properties
    @objc public static func trackEvent(_ eventName: String, properties: [String: Any]?) {
        guard shared.initialized, let tracker = shared.tracker else { return }
        tracker.trackEvent(eventName, properties: properties)
    }

    /// Track revenue
    @objc public static func trackRevenue(_ amount: Double, currency: String) {
        trackRevenue(amount, currency: currency, eventName: "purchase", properties: nil)
    }

    /// Track revenue with event name and properties
    @objc public static func trackRevenue(_ amount: Double, currency: String, eventName: String, properties: [String: Any]?) {
        guard shared.initialized, let tracker = shared.tracker else { return }
        tracker.trackRevenue(amount, currency: currency, eventName: eventName, properties: properties)
    }

    /// Set custom user property
    @objc public static func setUserProperty(_ key: String, value: Any) {
        guard shared.initialized, let tracker = shared.tracker else { return }
        tracker.setUserProperty(key, value: value)
    }

    /// Set customer user ID — links events across devices
    /// Call this after user logs in with your internal user ID
    @objc public static func setCustomUserId(_ userId: String) {
        guard shared.initialized, let tracker = shared.tracker else { return }
        tracker.setCustomUserId(userId)
    }

    /// Set ATT status (call after requesting ATT permission)
    @objc public static func setATTStatus(_ status: Int) {
        guard shared.initialized, let tracker = shared.tracker else { return }
        tracker.attStatus = status
    }

    /// Stop tracking
    @objc public static func stop() {
        shared.initialized = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
