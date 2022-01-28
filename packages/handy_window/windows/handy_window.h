#ifndef _HANDY_WINDOW_H_
#define _HANDY_WINDOW_H_

#include <windows.h>

#include <string>

enum Brightness { Light, Dark };

class HandyWindow {
 public:
  HandyWindow(HWND hwnd);

  static Brightness GetPreferredBrightness();

  Brightness GetBrightness() const;
  void SetBrightness(Brightness brightness);

  std::string GetTitle() const;
  void SetTitle(const std::string &title);

  bool IsClosable() const;
  void SetClosable(bool closable);

  bool IsVisible() const;
  void SetVisible(bool visible);

  bool IsMinimized() const;
  void Minimize(bool minimize);

  bool IsMaximized() const;
  void Maximize(bool maximize);

  bool IsFullscreen() const;
  void SetFullscreen(bool fullscreen);

  int GetWidth() const;
  int GetHeight() const;
  void Resize(int width, int height);

  void Close();
  void Destroy();

 private:
  HWND hwnd = nullptr;
  WINDOWPLACEMENT placement = {sizeof(WINDOWPLACEMENT)};
};

#endif  // _HANDY_WINDOW_H_
