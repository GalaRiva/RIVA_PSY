import UIKit
import Flutter
import awesome_notifications
import shared_preferences_foundation
import workmanager

import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Must be registered before the app finishes launching — the Dart side
    // (insight_workmanager.dart) only submits requests against these
    // identifiers, it doesn't register the task names themselves on iOS.
    // Identifiers must match Info.plist's BGTaskSchedulerPermittedIdentifiers
    // exactly.
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "com.riva.psy.nightlyInsightAnalysis")
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "com.riva.psy.gratitudeNudge", frequency: NSNumber(value: 48 * 60 * 60))

    GeneratedPluginRegistrant.register(with: self)
      
      if FirebaseApp.app() == nil {
          FirebaseApp.configure()
      }
      SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
                SwiftAwesomeNotificationsPlugin.register(
                  with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
          SharedPreferencesPlugin.register(
                      with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)

            }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override init() {
       // Firebase Init
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}
