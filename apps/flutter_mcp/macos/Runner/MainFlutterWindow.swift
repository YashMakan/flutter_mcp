import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

    override func setFrame(_ frameRect: NSRect, display flag: Bool) {
      super.setFrame(frameRect, display: flag)
      self.adjustTrafficLightPadding(padding: 12)
    }
}

extension NSWindow {
  func adjustTrafficLightPadding(padding: CGFloat) {
    if let close = standardWindowButton(.closeButton),
       let mini = standardWindowButton(.miniaturizeButton),
       let zoom = standardWindowButton(.zoomButton) {

      let buttons = [close, mini, zoom]
      for button in buttons {
        var frame = button.frame
        frame.origin.y -= padding
        button.setFrameOrigin(frame.origin)
      }
    }
  }
}

