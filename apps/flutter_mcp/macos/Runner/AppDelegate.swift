import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    if let window = mainFlutterWindow,
       let controller = window.contentViewController as? FlutterViewController {

        let channel = FlutterMethodChannel(name: "com.example.flutter_mcp",
                                           binaryMessenger: controller.engine.binaryMessenger)

        channel.setMethodCallHandler { [weak self] (call, result) in
          if call.method == "adjustTrafficLights" {
            DispatchQueue.main.async {
              window.adjustTrafficLightPadding(padding: 12)
            }
            result(nil)
          } else {
            result(FlutterMethodNotImplemented)
          }
        }
    }


    super.applicationDidFinishLaunching(notification)
  }
}
