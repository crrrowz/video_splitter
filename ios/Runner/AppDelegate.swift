import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let iconChannel = FlutterMethodChannel(name: "com.example.video_splitter/icons",
                                              binaryMessenger: controller.binaryMessenger)
    iconChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "changeIcon" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.changeAppIcon(to: call.arguments as? String)
      result(nil)
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func changeAppIcon(to iconName: String?) {
    if #available(iOS 10.3, *) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Error setting alternate icon: \(error.localizedDescription)")
            }
        }
    }
  }
}
