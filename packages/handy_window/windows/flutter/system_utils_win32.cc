// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <Windows.h>

#include <sstream>

#include "system_utils.h"

namespace flutter {
std::wstring GetPreferredBrightness() {
  DWORD use_light_theme;
  DWORD use_light_theme_size = sizeof(use_light_theme);
  LONG result = RegGetValue(
      HKEY_CURRENT_USER,
      L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
      L"AppsUseLightTheme", RRF_RT_REG_DWORD, nullptr, &use_light_theme,
      &use_light_theme_size);

  if (result == 0) {
    return use_light_theme ? kPlatformBrightnessLight : kPlatformBrightnessDark;
  } else {
    // The current OS does not support dark mode. (Older Windows 10 or before
    // Windows 10)
    return kPlatformBrightnessLight;
  }
}
}  // namespace flutter
