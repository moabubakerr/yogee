import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Push (docs/fcm-push-plan.md, Step 5).
    //
    // Claim the notification centre delegate so a notification arriving while
    // the app is foregrounded is handed to the plugins instead of being
    // swallowed by iOS. FlutterAppDelegate already implements the delegate
    // methods and forwards them, so assigning `self` is the whole wiring --
    // do NOT implement willPresent/didReceive here, or the forwarding breaks
    // and firebase_messaging stops seeing foreground messages.
    //
    // Permission is deliberately NOT requested here: iOS shows that prompt
    // exactly once per install, and a decline at launch kills push for good.
    // firebase_messaging requests it from Dart at a moment the user
    // understands (Step 6).
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
