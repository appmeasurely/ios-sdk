import Foundation

/// Configuration for AppMeasurely iOS SDK
@objc public class AMConfig: NSObject {

    static let defaultEndpoint = "https://uqvknwgcpptxnbmsubkc.supabase.co/functions/v1/track-mobile"

    @objc public var appKey: String
    @objc public var endpoint: String
    @objc public var debugMode: Bool
    @objc public var trackSessions: Bool
    @objc public var trackInstalls: Bool
    @objc public var sendIntervalSeconds: Int
    @objc public var maxQueueSize: Int

    /// Basic config with just app key
    @objc public init(appKey: String) {
        self.appKey = appKey
        self.endpoint = AMConfig.defaultEndpoint
        self.debugMode = false
        self.trackSessions = true
        self.trackInstalls = true
        self.sendIntervalSeconds = 30
        self.maxQueueSize = 100
    }

    /// Builder-style setters
    @discardableResult
    public func setEndpoint(_ endpoint: String) -> AMConfig {
        self.endpoint = endpoint
        return self
    }

    @discardableResult
    public func setDebugMode(_ enabled: Bool) -> AMConfig {
        self.debugMode = enabled
        return self
    }

    @discardableResult
    public func setTrackSessions(_ enabled: Bool) -> AMConfig {
        self.trackSessions = enabled
        return self
    }

    @objc @discardableResult
    public func setSendInterval(_ seconds: Int) -> AMConfig {
        self.sendIntervalSeconds = seconds
        return self
    }
}
