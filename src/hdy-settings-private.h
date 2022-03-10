/*
 * Copyright (C) 2021 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include <glib-object.h>
#include "hdy-enums-private.h"

G_BEGIN_DECLS

typedef enum {
  HDY_SYSTEM_COLOR_SCHEME_DEFAULT,
  HDY_SYSTEM_COLOR_SCHEME_PREFER_DARK,
  HDY_SYSTEM_COLOR_SCHEME_PREFER_LIGHT,
} HdySystemColorScheme;

#define HDY_TYPE_SETTINGS (hdy_settings_get_type())

G_DECLARE_FINAL_TYPE (HdySettings, hdy_settings, HDY, SETTINGS, GObject)

HdySettings *hdy_settings_get_default (void);

gboolean             hdy_settings_has_color_scheme (HdySettings *self);
HdySystemColorScheme hdy_settings_get_color_scheme (HdySettings *self);

gboolean hdy_settings_get_high_contrast (HdySettings *self);

G_END_DECLS
