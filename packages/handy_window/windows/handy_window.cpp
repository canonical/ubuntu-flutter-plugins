#include "handy_window.h"

#include <dwmapi.h>

#include <codecvt>
#include <locale>

#include "flutter/system_utils.h"

#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif

namespace {
static std::string from_wstr(const std::wstring &wstr) {
  return std::wstring_convert<std::codecvt_utf8<wchar_t>>().to_bytes(
      wstr.c_str());
}

static std::wstring to_wstr(const std::string &str) {
  return std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>, wchar_t>{}
      .from_bytes(str.c_str());
}
}  // namespace

HandyWindow::HandyWindow(HWND hwnd) : hwnd(hwnd) {}

Brightness HandyWindow::GetPreferredBrightness() {
  if (flutter::GetPreferredBrightness() == flutter::kPlatformBrightnessDark) {
    return Brightness::Dark;
  } else {
    return Brightness::Light;
  }
}

Brightness HandyWindow::GetBrightness() const {
  BOOL value = FALSE;
  ::DwmGetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &value,
                          sizeof(BOOL));
  return value ? Brightness::Dark : Brightness::Light;
}

void HandyWindow::SetBrightness(Brightness brightness) {
  BOOL value = brightness == Brightness::Dark;
  ::DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &value,
                          sizeof(BOOL));
}

std::string HandyWindow::GetTitle() const {
  int length = ::GetWindowTextLength(hwnd) + 1;
  std::wstring title;
  title.resize(length);
  ::GetWindowText(hwnd, &title[0], length);
  title.resize(length - 1);
  return from_wstr(title);
}

void HandyWindow::SetTitle(const std::string &title) {
  ::SetWindowText(hwnd, to_wstr(title).c_str());
}

bool HandyWindow::IsClosable() const {
  HMENU menu = ::GetSystemMenu(hwnd, FALSE);
  MENUITEMINFO info;
  info.cbSize = sizeof(MENUITEMINFO);
  info.fMask = MIIM_STATE;
  ::GetMenuItemInfo(menu, SC_CLOSE, FALSE, &info);
  return !(info.fState & MFS_DISABLED);
}

void HandyWindow::SetClosable(bool closable) {
  HMENU menu = ::GetSystemMenu(hwnd, FALSE);
  UINT flags = closable ? MF_ENABLED : MF_DISABLED | MF_GRAYED;
  ::EnableMenuItem(menu, SC_CLOSE, MF_BYCOMMAND | flags);
}

bool HandyWindow::IsVisible() const { return ::IsWindowVisible(hwnd); }

void HandyWindow::SetVisible(bool visible) {
  ::ShowWindow(hwnd, visible ? SW_SHOW : SW_HIDE);
}

bool HandyWindow::IsMinimized() const {
  return ::GetWindowLong(hwnd, GWL_STYLE) & WS_MINIMIZE;
}

void HandyWindow::Minimize(bool minimize) {
  ::ShowWindow(hwnd, minimize ? SW_MINIMIZE : SW_RESTORE);
}

bool HandyWindow::IsMaximized() const {
  return ::GetWindowLong(hwnd, GWL_STYLE) & WS_MAXIMIZE;
}

void HandyWindow::Maximize(bool maximize) {
  ::ShowWindow(hwnd, maximize ? SW_MAXIMIZE : SW_RESTORE);
}

bool HandyWindow::IsFullscreen() const {
  DWORD style = ::GetWindowLong(hwnd, GWL_STYLE);
  return !(style & WS_OVERLAPPEDWINDOW);
}

void HandyWindow::SetFullscreen(bool fullscreen) {
  DWORD style = ::GetWindowLong(hwnd, GWL_STYLE);
  if (style & WS_OVERLAPPEDWINDOW) {
    MONITORINFO mi = {sizeof(mi)};
    if (::GetWindowPlacement(hwnd, &placement) &&
        ::GetMonitorInfo(MonitorFromWindow(hwnd, MONITOR_DEFAULTTOPRIMARY),
                         &mi)) {
      ::SetWindowLong(hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
      ::SetWindowPos(hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
                     mi.rcMonitor.right - mi.rcMonitor.left,
                     mi.rcMonitor.bottom - mi.rcMonitor.top,
                     SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
    }
  } else {
    ::SetWindowLong(hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
    ::SetWindowPlacement(hwnd, &placement);
    ::SetWindowPos(hwnd, NULL, 0, 0, 0, 0,
                   SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOOWNERZORDER |
                       SWP_FRAMECHANGED);
  }
}

int HandyWindow::GetWidth() const {
  RECT rect;
  ::GetWindowRect(hwnd, &rect);
  return rect.right - rect.left;
}

int HandyWindow::GetHeight() const {
  RECT rect;
  ::GetWindowRect(hwnd, &rect);
  return rect.bottom - rect.top;
}

void HandyWindow::Resize(int width, int height) {
  ::SetWindowPos(hwnd, nullptr, 0, 0, width, height,
                 SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOZORDER);
}

void HandyWindow::Close() { ::SendMessage(hwnd, WM_CLOSE, 0, 0); }

void HandyWindow::Destroy() { ::DestroyWindow(hwnd); }
