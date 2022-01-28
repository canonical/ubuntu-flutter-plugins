#include "include/handy_window/handy_window_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include "handy_window.h"

namespace {
typedef std::function<void(const flutter::EncodableValue *result)>
    OnHandyWindowSuccess;
typedef std::function<void(const std::string &error_code,
                           const std::string &error_message,
                           const flutter::EncodableValue *error_details)>
    OnHandyWindowError;

typedef std::function<void()> OnHandyWindowNotImplemented;

class HandyWindowResponse
    : public flutter::MethodResult<flutter::EncodableValue> {
 public:
  HandyWindowResponse(OnHandyWindowSuccess on_success,
                      OnHandyWindowError on_error = nullptr,
                      OnHandyWindowNotImplemented on_not_implemented = nullptr)
      : _on_success(on_success),
        _on_error(on_error),
        _on_not_implemented(on_not_implemented) {}

 protected:
  void SuccessInternal(const flutter::EncodableValue *result) override {
    if (_on_success) {
      _on_success(result);
    }
  }

  void ErrorInternal(const std::string &error_code,
                     const std::string &error_message,
                     const flutter::EncodableValue *error_details) override {
    if (_on_error) {
      _on_error(error_code, error_message, error_details);
    }
  }

  void NotImplementedInternal() override {
    if (_on_not_implemented) {
      _on_not_implemented();
    }
  }

 private:
  OnHandyWindowSuccess _on_success;
  OnHandyWindowError _on_error;
  OnHandyWindowNotImplemented _on_not_implemented;
};

class HandyWindowPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  HandyWindowPlugin(flutter::PluginRegistrarWindows *registrar);

 protected:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  void CreateHandyWindow();
  void CreateEventChannel();
  void SendCloseEvent();
  void SendResizeEvent(int width, int height);
  void RegisterWindowProcDelegate();
  std::optional<HRESULT> ProcessMsg(HWND hwnd, UINT message, WPARAM wparam,
                                    LPARAM lparam);

  int _delegate = -1;
  std::unique_ptr<HandyWindow> _window;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      _event_channel;
  flutter::PluginRegistrarWindows *_registrar = nullptr;
};

void HandyWindowPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<HandyWindowPlugin>(registrar);
  auto method_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "handy_window",
          &flutter::StandardMethodCodec::GetInstance());
  method_channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
  registrar->AddPlugin(std::move(plugin));
}

HandyWindowPlugin::HandyWindowPlugin(flutter::PluginRegistrarWindows *registrar)
    : _registrar(registrar) {}

void HandyWindowPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string method = method_call.method_name();
  CreateHandyWindow();
  if (method.compare("getWindowTitle") == 0) {
    const std::string title = _window->GetTitle();
    result->Success(flutter::EncodableValue(title));
  } else if (method.compare("setWindowTitle") == 0) {
    const std::string title = std::get<std::string>(*method_call.arguments());
    _window->SetTitle(title);
    result->Success();
  } else if (method.compare("isWindowClosable") == 0) {
    bool closable = _window->IsClosable();
    result->Success(flutter::EncodableValue(closable));
  } else if (method.compare("setWindowClosable") == 0) {
    bool closable = std::get<bool>(*method_call.arguments());
    _window->SetClosable(closable);
    result->Success();
  } else if (method.compare("isWindowVisible") == 0) {
    bool visible = _window->IsVisible();
    result->Success(flutter::EncodableValue(visible));
  } else if (method.compare("setWindowVisible") == 0) {
    bool visible = std::get<bool>(*method_call.arguments());
    _window->SetVisible(visible);
    result->Success();
  } else if (method.compare("isWindowMinimized") == 0) {
    bool minimized = _window->IsMinimized();
    result->Success(flutter::EncodableValue(minimized));
  } else if (method.compare("minimizeWindow") == 0) {
    bool minimize = std::get<bool>(*method_call.arguments());
    _window->Minimize(minimize);
    result->Success();
  } else if (method.compare("isWindowMaximized") == 0) {
    bool maximized = _window->IsMaximized();
    result->Success(flutter::EncodableValue(maximized));
  } else if (method.compare("maximizeWindow") == 0) {
    bool maximize = std::get<bool>(*method_call.arguments());
    _window->Maximize(maximize);
    result->Success();
  } else if (method.compare("isWindowFullscreen") == 0) {
    bool fullscreen = _window->IsFullscreen();
    result->Success(flutter::EncodableValue(fullscreen));
  } else if (method.compare("setWindowFullscreen") == 0) {
    bool fullscreen = std::get<bool>(*method_call.arguments());
    _window->SetFullscreen(fullscreen);
    result->Success();
  } else if (method.compare("getWindowSize") == 0) {
    result->Success(flutter::EncodableMap({
        {"width", _window->GetWidth()},
        {"height", _window->GetHeight()},
    }));
  } else if (method.compare("resizeWindow") == 0) {
    const flutter::EncodableMap &size =
        std::get<flutter::EncodableMap>(*method_call.arguments());
    int width = std::get<int>(size.at(flutter::EncodableValue("width")));
    int height = std::get<int>(size.at(flutter::EncodableValue("height")));
    _window->Resize(width, height);
    result->Success();
  } else if (method.compare("onWindowResized") == 0) {
    RegisterWindowProcDelegate();
    result->Success();
  } else if (method.compare("closeWindow") == 0) {
    _window->Close();
    result->Success();
  } else if (method.compare("onWindowClosing") == 0) {
    RegisterWindowProcDelegate();
    result->Success();
  } else {
    result->NotImplemented();
  }
}

void HandyWindowPlugin::CreateHandyWindow() {
  if (!_window) {
    flutter::FlutterView *view = _registrar->GetView();
    HWND hwnd = ::GetAncestor(view->GetNativeWindow(), GA_ROOT);
    _window = std::make_unique<HandyWindow>(hwnd);
    _window->SetBrightness(HandyWindow::GetPreferredBrightness());
  }
}

void HandyWindowPlugin::CreateEventChannel() {
  if (!_event_channel) {
    _event_channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            _registrar->messenger(), "handy_window/events",
            &flutter::StandardMethodCodec::GetInstance());
  }
}

void HandyWindowPlugin::SendResizeEvent(int width, int height) {
  CreateEventChannel();
  const flutter::EncodableMap size{
      {flutter::EncodableValue("width"), flutter::EncodableValue(width)},
      {flutter::EncodableValue("height"), flutter::EncodableValue(height)}};
  std::unique_ptr<flutter::EncodableValue> event =
      std::make_unique<flutter::EncodableValue>(size);
  _event_channel->InvokeMethod("onWindowResized", std::move(event));
}

void HandyWindowPlugin::SendCloseEvent() {
  CreateHandyWindow();
  CreateEventChannel();
  std::unique_ptr<HandyWindowResponse> response =
      std::make_unique<HandyWindowResponse>(
          [this](const flutter::EncodableValue *result) {
            const bool *close = std::get_if<bool>(result);
            if (close && *close) {
              _window->Destroy();
            }
          },
          [](const std::string &error_code, const std::string &error_message,
             const flutter::EncodableValue *error_details) {
            std::cerr << "onWindowClosing response: " << error_code << " ("
                      << error_message << ")" << std::endl;
          });
  _event_channel->InvokeMethod("onWindowClosing", nullptr, std::move(response));
}

void HandyWindowPlugin::RegisterWindowProcDelegate() {
  if (_delegate == -1) {
    _delegate = _registrar->RegisterTopLevelWindowProcDelegate(
        [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
          return ProcessMsg(hwnd, message, wparam, lparam);
        });
  }
}

std::optional<HRESULT> HandyWindowPlugin::ProcessMsg(HWND hwnd, UINT message,
                                                     WPARAM wparam,
                                                     LPARAM lparam) {
  switch (message) {
    case WM_CLOSE:
      SendCloseEvent();
      return 0;
    case WM_SYSCOMMAND:
      if (wparam == SC_CLOSE) {
        CreateHandyWindow();
        if (!_window->IsClosable()) {
          return 0;  // ignore alt+f4
        }
      }
      return std::nullopt;
    case WM_SIZE:
      SendResizeEvent(LOWORD(lparam), HIWORD(lparam));
      return std::nullopt;
    case WM_DESTROY:
      PostQuitMessage(0);
      return 0;
    default:
      return std::nullopt;
  }
}
}  // namespace

void HandyWindowPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  HandyWindowPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
