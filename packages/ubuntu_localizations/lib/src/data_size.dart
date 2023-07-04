// Adapted from https://github.com/synw/filesize/pull/9
//
// Copyright 2019 synw
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google LLC nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'localizations.dart';

/// Localized data size formatting.
extension UbuntuDataSizeLocalizations on UbuntuLocalizations {
  /// Formats [bytes] as a localized human readable string.
  String formatByteSize(num bytes, {int? precision}) {
    const divider = 1000;
    final units = [byte, kilobyte, megabyte, gigabyte, terabyte, petabyte];
    final idx = bytes == 0
        ? 0
        : (math.log(bytes.abs()) ~/ math.log(divider))
            .clamp(0, units.length - 1);
    final p = precision == null && (bytes < divider || bytes % divider == 0)
        ? 0
        : precision;
    final sz =
        (bytes / math.pow(divider, idx)).toStringAsFixed(p ?? idx.clamp(0, 2));
    return '$sz ${units[idx]}';
  }
}

/// Localized data size formatting.
extension UbuntuDataSizeContext on BuildContext {
  /// Formats [bytes] as a localized human readable string.
  String formatByteSize(num bytes, {int? precision}) {
    return UbuntuLocalizations.of(this)
        .formatByteSize(bytes, precision: precision);
  }
}
