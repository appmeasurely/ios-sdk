# AppMeasurely iOS SDK

Mobile attribution and analytics tracking for iOS apps.

## Requirements
- iOS 13.0+
- Swift 5.0+
- Xcode 13+

## Installation

### Swift Package Manager (recommended)

1. In Xcode, go to **File → Add Packages**
2. Enter the repository URL:
```
https://github.com/appmeasurely/ios-sdk
```
3. Select version `1.0.0` and click **Add Package**

### CocoaPods

Add to your `Podfile`:
```ruby
pod 'AppMeasurely', '~> 1.0.0'
```
Then run:
```bash
pod install
```

### Manual

Download the source files from `Sources/AppMeasurely/` and drag them into your Xcode project.

---

## Quick Start

### Step 1 — Initialize in AppDelegate

**Swift:**
```swift
import AppMeasurely

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppMeasurely.start(appKey: "YOUR_APP_KEY")
        return true
    }
}
```

**Objective-C:**
```objc
#import <AppMeasurely/AppMeasurely-Swift.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AppMeasurely startWithAppKey:@"YOUR_APP_KEY"];
    return YES;
}
```

### Step 2 — Track Custom Events

**Swift:**
```swift
// Simple event
AppMeasurely.trackEvent("level_complete")

// Event with properties
AppMeasurely.trackEvent("purchase_initiated", properties: [
    "product_id": "gold_pack",
    "price": 4.99,
    "currency": "USD"
])
```

**Objective-C:**
```objc
[AppMeasurely trackEvent:@"level_complete"];

[AppMeasurely trackEvent:@"purchase_initiated" properties:@{
    @"product_id": @"gold_pack",
    @"price": @4.99
}];
```

### Step 3 — Track Revenue

```swift
AppMeasurely.trackRevenue(9.99, currency: "USD")
AppMeasurely.trackRevenue(4.99, currency: "USD", eventName: "subscription_monthly", properties: nil)
```

---

## ATT (App Tracking Transparency)

For iOS 14.5+, request ATT permission and pass the status to the SDK:

```swift
import AppTrackingTransparency

ATTrackingManager.requestTrackingAuthorization { status in
    AppMeasurely.setATTStatus(Int(status.rawValue))
}
```

---

## What's Tracked Automatically

| Event | Description |
|-------|-------------|
| `install` | Fired once on first app launch |
| `app_open` | Fired on every subsequent launch |
| `session_start` | When app becomes active |
| `session_end` | When app enters background (includes duration) |

---

## Advanced Configuration

```swift
let config = AMConfig(appKey: "YOUR_APP_KEY")
config.setDebugMode(true)        // Enable logging
config.setTrackSessions(true)    // Auto session tracking
config.setSendInterval(30)       // Send queue every 30 seconds

AppMeasurely.start(config: config)
```

---

## Get Your App Key

1. Log in to your [AppMeasurely dashboard](https://app.appmeasurely.com)
2. Go to **SDK Docs** in the left sidebar
3. Select your app from the dropdown
4. Copy your App Key

---

## Support

- Documentation: [appmeasurely.com/docs](https://appmeasurely.com/docs)
- Email: support@appmeasurely.com
