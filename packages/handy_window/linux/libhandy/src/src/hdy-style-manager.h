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

#include "hdy-version.h"

#include <gtk/gtk.h>
#include "hdy-enums.h"

G_BEGIN_DECLS

#define HDY_TYPE_STYLE_MANAGER (hdy_style_manager_get_type())

typedef enum {
  HDY_COLOR_SCHEME_DEFAULT,
  HDY_COLOR_SCHEME_FORCE_LIGHT,
  HDY_COLOR_SCHEME_PREFER_LIGHT,
  HDY_COLOR_SCHEME_PREFER_DARK,
  HDY_COLOR_SCHEME_FORCE_DARK,
} HdyColorScheme;

HDY_AVAILABLE_IN_1_6
G_DECLARE_FINAL_TYPE (HdyStyleManager, hdy_style_manager, HDY, STYLE_MANAGER, GObject)

HDY_AVAILABLE_IN_1_6
HdyStyleManager *hdy_style_manager_get_default (void);
HDY_AVAILABLE_IN_1_6
HdyStyleManager *hdy_style_manager_get_for_display (GdkDisplay *display);

HDY_AVAILABLE_IN_1_6
GdkDisplay *hdy_style_manager_get_display (HdyStyleManager *self);

HDY_AVAILABLE_IN_1_6
HdyColorScheme hdy_style_manager_get_color_scheme (HdyStyleManager *self);
HDY_AVAILABLE_IN_1_6
void           hdy_style_manager_set_color_scheme (HdyStyleManager *self,
                                                   HdyColorScheme   color_scheme);

HDY_AVAILABLE_IN_1_6
gboolean hdy_style_manager_get_system_supports_color_schemes (HdyStyleManager *self);

HDY_AVAILABLE_IN_1_6
gboolean hdy_style_manager_get_dark          (HdyStyleManager *self);
HDY_AVAILABLE_IN_1_6
gboolean hdy_style_manager_get_high_contrast (HdyStyleManager *self);

G_END_DECLS
