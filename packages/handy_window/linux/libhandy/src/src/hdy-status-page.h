/*
 * Copyright (C) 2020 Andrei Lișiță <andreii.lisita@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include "hdy-version.h"

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define HDY_TYPE_STATUS_PAGE (hdy_status_page_get_type())

HDY_AVAILABLE_IN_1_2
G_DECLARE_FINAL_TYPE (HdyStatusPage, hdy_status_page, HDY, STATUS_PAGE, GtkBin)

HDY_AVAILABLE_IN_1_2
GtkWidget       *hdy_status_page_new (void);

HDY_AVAILABLE_IN_1_2
const gchar     *hdy_status_page_get_icon_name (HdyStatusPage *self);
HDY_AVAILABLE_IN_1_2
void             hdy_status_page_set_icon_name (HdyStatusPage *self,
                                                const gchar   *icon_name);

HDY_AVAILABLE_IN_1_2
const gchar     *hdy_status_page_get_title (HdyStatusPage *self);
HDY_AVAILABLE_IN_1_2
void             hdy_status_page_set_title (HdyStatusPage *self,
                                            const gchar   *title);

HDY_AVAILABLE_IN_1_2
const gchar     *hdy_status_page_get_description (HdyStatusPage *self);
HDY_AVAILABLE_IN_1_2
void             hdy_status_page_set_description (HdyStatusPage *self,
                                                  const gchar   *description);

G_END_DECLS
