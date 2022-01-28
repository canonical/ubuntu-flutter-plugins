import Cocoa
import FlutterMacOS

public class HandyWindowPlugin: NSObject, NSWindowDelegate, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "handy_window", binaryMessenger: registrar.messenger)
    let instance = HandyWindowPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  let registrar: FlutterPluginRegistrar
  var events: FlutterMethodChannel?

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let window = self.getWindow()
    window.delegate = self
    switch call.method {
    case "getWindowTitle":
      result(window.title)
    case "setWindowTitle":
      window.title = call.arguments as! String
      result(nil)
    case "isWindowClosable":
      result(window.styleMask.contains(.closable))
    case "setWindowClosable":
      if (call.arguments as! Bool) {
        window.styleMask.insert(.closable)
      } else {
        window.styleMask.remove(.closable)
      }
      result(nil)
    case "isWindowVisible":
      result(window.isVisible)
    case "setWindowVisible":
      if (call.arguments as! Bool) {
        window.makeKeyAndOrderFront(nil)
      } else {
        window.orderOut(nil)
      }
      result(nil)
    case "isWindowMinimized":
      result(window.isMiniaturized)
    case "minimizeWindow":
      if (call.arguments as! Bool) {
        window.miniaturize(nil)
      } else {
        window.deminiaturize(nil)
      }
      result(nil)
    case "isWindowMaximized":
      result(window.isZoomed)
    case "maximizeWindow":
      if (call.arguments as! Bool) {
        window.zoom(nil)
      } else {
        // ### TODO
      }
      result(nil)
    case "isWindowFullscreen":
      result(window.styleMask.contains(.fullScreen))
    case "setWindowFullscreen":
      if (window.styleMask.contains(.fullScreen) != call.arguments as! Bool) {
        window.toggleFullScreen(nil)
      }
      result(nil)
    case "getWindowSize":
      let content = window.contentRect(forFrameRect: window.frame)
      result(["width": content.width, "height": content.height])
    case "resizeWindow":
      let size = call.arguments as! [String: Int]
      window.setContentSize(NSSize(width: size["width"]!, height: size["height"]!))
      result(nil)
    case "onWindowResized":
      self.createEventChannel()
      result(nil)
    case "closeWindow":
      self.onWindowClosing()
      result(nil)
    case "onWindowClosing":
      self.createEventChannel()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func windowDidResize(_ notification: Notification) {
    self.onWindowResized()
  }

  public func windowShouldClose(_ sender: NSWindow) -> Bool {
    self.onWindowClosing()
    return false
  }

  private func getWindow() -> NSWindow {
    return registrar.view!.window!
  }

  private func onWindowResized() {
    let window = self.getWindow()
    let size = window.contentRect(forFrameRect: window.frame)
    self.events?.invokeMethod("onWindowResized", arguments: ["width": size.width, "height": size.height])
  }

  private func onWindowClosing() {
    self.events?.invokeMethod("onWindowClosing", arguments: nil, result: { result in
      if (result as! Bool? == true) {
        self.getWindow().close()
      }
    })
  }

  private func createEventChannel() {
    if (self.events == nil) {
      self.events = FlutterMethodChannel(name: "handy_window/events", binaryMessenger: registrar.messenger)
    }
  }
}
