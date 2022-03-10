/*
 * Copyright (C) 2020 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include "hdy-version.h"

#include <gdk-pixbuf/gdk-pixbuf.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

#define HDY_TYPE_AVATAR (hdy_avatar_get_type())

HDY_AVAILABLE_IN_ALL
G_DECLARE_FINAL_TYPE (HdyAvatar, hdy_avatar, HDY, AVATAR, GtkDrawingArea)

/**
 * HdyAvatarImageLoadFunc:
 * @size: the required size of the avatar
 * @user_data: (closure): user data
 *
 * Callback for loading an [class@Avatar]'s image.
 *
 * The returned [class@GdkPixbuf.Pixbuf] is expected to be square with width and
 * height set to @size. The image is cropped to a circle without any scaling or
 * transformation.
 *
 * Returns: (nullable) (transfer full): the pixbuf to use as a custom avatar or
 *   `NULL` to fallback to the generated avatar
 *
 * Since: 1.0
 *
 * Deprecated: 1.2: use [method@Avatar.set_loadable_icon] instead.
 */
HDY_DEPRECATED_TYPE_IN_1_2_FOR (hdy_avatar_set_loadable_icon)
typedef GdkPixbuf *(*HdyAvatarImageLoadFunc) (gint     size,
                                              gpointer user_data);


HDY_AVAILABLE_IN_ALL
GtkWidget   *hdy_avatar_new                 (gint                    size,
                                             const gchar            *text,
                                             gboolean                show_initials);
HDY_AVAILABLE_IN_ALL
const gchar *hdy_avatar_get_icon_name       (HdyAvatar              *self);
HDY_AVAILABLE_IN_ALL
void         hdy_avatar_set_icon_name       (HdyAvatar              *self,
                                             const gchar            *icon_name);
HDY_AVAILABLE_IN_ALL
const gchar *hdy_avatar_get_text            (HdyAvatar              *self);
HDY_AVAILABLE_IN_ALL
void         hdy_avatar_set_text            (HdyAvatar              *self,
                                             const gchar            *text);
HDY_AVAILABLE_IN_ALL
gboolean     hdy_avatar_get_show_initials   (HdyAvatar              *self);
HDY_AVAILABLE_IN_ALL
void         hdy_avatar_set_show_initials   (HdyAvatar              *self,
                                             gboolean                show_initials);

G_GNUC_BEGIN_IGNORE_DEPRECATIONS
HDY_DEPRECATED_IN_1_2_FOR (hdy_avatar_set_loadable_icon)
void         hdy_avatar_set_image_load_func (HdyAvatar              *self,
                                             HdyAvatarImageLoadFunc  load_image,
                                             gpointer                user_data,
                                             GDestroyNotify          destroy);
G_GNUC_END_IGNORE_DEPRECATIONS

HDY_AVAILABLE_IN_ALL
gint         hdy_avatar_get_size            (HdyAvatar              *self);
HDY_AVAILABLE_IN_ALL
void         hdy_avatar_set_size            (HdyAvatar              *self,
                                             gint                    size);
HDY_AVAILABLE_IN_ALL
GdkPixbuf   *hdy_avatar_draw_to_pixbuf      (HdyAvatar              *self,
                                             gint                    size,
                                             gint                    scale_factor);
HDY_AVAILABLE_IN_1_2
void hdy_avatar_draw_to_pixbuf_async        (HdyAvatar              *self,
                                             gint                    size,
                                             gint                    scale_factor,
                                             GCancellable           *cancellable,
                                             GAsyncReadyCallback     callback,
                                             gpointer                user_data);
HDY_AVAILABLE_IN_1_2
GdkPixbuf *hdy_avatar_draw_to_pixbuf_finish (HdyAvatar              *self,
                                             GAsyncResult           *async_result);
HDY_AVAILABLE_IN_1_2
GLoadableIcon *hdy_avatar_get_loadable_icon (HdyAvatar              *self);
HDY_AVAILABLE_IN_1_2
void           hdy_avatar_set_loadable_icon (HdyAvatar              *self,
                                             GLoadableIcon          *icon);

G_END_DECLS
