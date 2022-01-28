// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file contains utilities for system-level information/settings.

#ifndef FLUTTER_SHELL_PLATFORM_WINDOWS_SYSTEM_UTILS_H_
#define FLUTTER_SHELL_PLATFORM_WINDOWS_SYSTEM_UTILS_H_

#include <string>
#include <vector>

namespace flutter {

namespace {
static constexpr wchar_t kPlatformBrightnessLight[] = L"light";
static constexpr wchar_t kPlatformBrightnessDark[] = L"dark";
}  // namespace

// Returns the user-preferred brightness.
std::wstring GetPreferredBrightness();

}  // namespace flutter

#endif  // FLUTTER_SHELL_PLATFORM_WINDOWS_SYSTEM_UTILS_H_
