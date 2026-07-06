import Foundation
import UIKit

/// Collects device information automatically
class AMDeviceInfo {

    private let userDefaults = UserDefaults.standard
    private let deviceIdKey = "am_device_id"
    private let launchedKey = "am_launched"

    /// Persistent device ID using IDFV with UUID fallback
    var deviceId: String {
        if let stored = userDefaults.string(forKey: deviceIdKey) {
            return stored
        }
        let id = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        userDefaults.set(id, forKey: deviceIdKey)
        return id
    }

    var osVersion: String {
        return UIDevice.current.systemVersion
    }

    var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.isEmpty ? UIDevice.current.model : identifier
    }

    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    var language: String {
        return Locale.current.languageCode ?? "en"
    }

    var screenWidth: Int {
        return Int(UIScreen.main.bounds.width * UIScreen.main.scale)
    }

    var screenHeight: Int {
        return Int(UIScreen.main.bounds.height * UIScreen.main.scale)
    }

    var isFirstLaunch: Bool {
        return !userDefaults.bool(forKey: launchedKey)
    }

    func markLaunched() {
        userDefaults.set(true, forKey: launchedKey)
    }

    var bundleId: String {
        return Bundle.main.bundleIdentifier ?? "unknown"
    }
}
