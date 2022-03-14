/*
 * Copyright (C) 2020 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include <handy.h>

#define TEST_ICON_NAME "avatar-default-symbolic"
#define TEST_STRING "Mario Rossi"
#define TEST_SIZE 128


gint load_image_func_count;

static gboolean
is_surface_empty (cairo_surface_t *surface)
{
  unsigned char * data;
  guint length;

  cairo_surface_flush (surface);
  data = cairo_image_surface_get_data (surface);
  length = cairo_image_surface_get_width (surface) * cairo_image_surface_get_height (surface);

  for (int i = 0; i < length; i++) {
    if (data[i] != 0)
      return FALSE;
  }
  return TRUE;
}

static GdkPixbuf *
load_null_image_func (gint size,
                      gpointer data)
{
  load_image_func_count++;
  return NULL;
}

static GdkPixbuf *
load_image_func (gint size,
                 GdkRGBA *color)
{
  GdkPixbuf *pixbuf;
  cairo_surface_t *surface;
  cairo_t *cr;

  load_image_func_count++;

  surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, size, size);
  cr = cairo_create (surface);
  if (color != NULL) {
    gdk_cairo_set_source_rgba (cr, color);
    cairo_paint (cr);
  }
  pixbuf = gdk_pixbuf_get_from_surface (surface, 0, 0, size, size);

  cairo_surface_destroy (surface);
  cairo_destroy (cr);
  return pixbuf;
}


static void
map_event_cb (GtkWidget *widget, GdkEvent *event, cairo_surface_t **surface)
{
  cairo_t *cr;

  g_assert (surface != NULL);

  *surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, TEST_SIZE, TEST_SIZE);
  cr = cairo_create (*surface);
  gtk_widget_draw (widget, cr);
  cairo_destroy (cr);
  gtk_main_quit ();
}


static gboolean
did_draw_something (GtkWidget *widget)
{
  GtkWidget *window;
  gboolean empty;
  cairo_surface_t *surface;

  window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

  gtk_widget_set_events (widget, GDK_STRUCTURE_MASK);
  g_signal_connect (widget, "map-event", G_CALLBACK (map_event_cb), &surface);

  gtk_window_resize (GTK_WINDOW (window), TEST_SIZE, TEST_SIZE);
  gtk_container_add (GTK_CONTAINER (window), widget);

  gtk_widget_show (widget);
  gtk_widget_show (window);

  gtk_main ();

  g_assert (surface);
  g_assert (cairo_surface_status (surface) == CAIRO_STATUS_SUCCESS);
  empty =  is_surface_empty (surface);

  cairo_surface_destroy (surface);
  gtk_widget_destroy (window);

  return !empty;
}


static void
test_hdy_avatar_generate (void)
{
  g_autoptr (GtkWidget) avatar = g_object_ref_sink (hdy_avatar_new (TEST_SIZE, "", TRUE));
  g_assert (HDY_IS_AVATAR (avatar));

  g_assert_true (did_draw_something (GTK_WIDGET (avatar)));
}


static void
test_hdy_avatar_icon_name (void)
{
  g_autoptr (HdyAvatar) avatar = g_object_ref_sink (HDY_AVATAR (hdy_avatar_new (128, NULL, TRUE)));

  g_assert_null (hdy_avatar_get_icon_name (avatar));
  hdy_avatar_set_icon_name (avatar, TEST_ICON_NAME);
  g_assert_cmpstr (hdy_avatar_get_icon_name (avatar), ==, TEST_ICON_NAME);

  g_assert_true (did_draw_something (GTK_WIDGET (avatar)));
}

static void
test_hdy_avatar_text (void)
{
  g_autoptr (HdyAvatar) avatar = g_object_ref_sink (HDY_AVATAR (hdy_avatar_new (128, NULL, TRUE)));

  g_assert_null (hdy_avatar_get_text (avatar));
  hdy_avatar_set_text (avatar, TEST_STRING);
  g_assert_cmpstr (hdy_avatar_get_text (avatar), ==, TEST_STRING);

  g_assert_true (did_draw_something (GTK_WIDGET (avatar)));
}

static void
test_hdy_avatar_size (void)
{
  g_autoptr (HdyAvatar) avatar = g_object_ref_sink (HDY_AVATAR (hdy_avatar_new (TEST_SIZE, NULL, TRUE)));

  g_assert_cmpint (hdy_avatar_get_size (avatar), ==, TEST_SIZE);
  hdy_avatar_set_size (avatar, TEST_SIZE / 2);
  g_assert_cmpint (hdy_avatar_get_size (avatar), ==, TEST_SIZE / 2);

  g_assert_true (did_draw_something (GTK_WIDGET (avatar)));
}

static void
test_hdy_avatar_custom_image (void)
{
  GtkWidget *avatar;
  GdkRGBA color;

  avatar = hdy_avatar_new (TEST_SIZE, NULL, TRUE);

  g_assert (HDY_IS_AVATAR (avatar));

  load_image_func_count = 0;

  hdy_avatar_set_image_load_func (HDY_AVATAR (avatar),
                                  (HdyAvatarImageLoadFunc) load_image_func,
                                  NULL,
                                  NULL);

  g_object_ref (avatar);
  g_assert_false (did_draw_something (avatar));

  hdy_avatar_set_image_load_func (HDY_AVATAR (avatar),
                                  NULL,
                                  NULL,
                                  NULL);

  g_assert_true (did_draw_something (avatar));

  gdk_rgba_parse (&color, "#F00");
  hdy_avatar_set_image_load_func (HDY_AVATAR (avatar),
                                  (HdyAvatarImageLoadFunc) load_image_func,
                                  &color,
                                  NULL);

  g_assert_true (did_draw_something (avatar));

  hdy_avatar_set_image_load_func (HDY_AVATAR (avatar),
                                  (HdyAvatarImageLoadFunc) load_null_image_func,
                                  NULL,
                                  NULL);

  g_assert_true (did_draw_something (avatar));

  g_assert_cmpint (load_image_func_count, ==, 3);

  g_object_unref (avatar);
}

static void
test_hdy_avatar_draw_to_pixbuf (void)
{
  g_autoptr (HdyAvatar) avatar = NULL;
  g_autoptr (GdkPixbuf) pixbuf = NULL;

  avatar = g_object_ref_sink (HDY_AVATAR (hdy_avatar_new (TEST_SIZE, NULL, TRUE)));

  pixbuf = hdy_avatar_draw_to_pixbuf (avatar, TEST_SIZE * 2, 1);

  g_assert_cmpint (gdk_pixbuf_get_width (pixbuf), ==, TEST_SIZE * 2);
  g_assert_cmpint (gdk_pixbuf_get_height (pixbuf), ==, TEST_SIZE * 2);
}

static void
draw_to_pixbuf_async (HdyAvatar    *avatar,
                      GAsyncResult *res,
                      gpointer      user_data)
{
  g_autoptr (GdkPixbuf) pixbuf = hdy_avatar_draw_to_pixbuf_finish (avatar, res);

  g_assert_cmpint (gdk_pixbuf_get_width (pixbuf), ==, TEST_SIZE * 2);
  g_assert_cmpint (gdk_pixbuf_get_height (pixbuf), ==, TEST_SIZE * 2);
}

static void
test_hdy_avatar_draw_to_pixbuf_async (void)
{
  g_autoptr (HdyAvatar) avatar = g_object_ref_sink (HDY_AVATAR (hdy_avatar_new (TEST_SIZE, NULL, TRUE)));

  hdy_avatar_draw_to_pixbuf_async (avatar,
                                   TEST_SIZE * 2,
                                   1,
                                   NULL,
                                   (GAsyncReadyCallback) draw_to_pixbuf_async,
                                   NULL);
}

static void
test_hdy_avatar_loadable_icon (void)
{
  GtkWidget* avatar = NULL;
  g_autoptr (GdkPixbuf) pixbuf = NULL;

  avatar = hdy_avatar_new (TEST_SIZE, NULL, TRUE);
  g_assert_nonnull (avatar);

  g_assert_null (hdy_avatar_get_loadable_icon (HDY_AVATAR (avatar)));
  hdy_avatar_set_loadable_icon (HDY_AVATAR (avatar), NULL);
  g_assert_null (hdy_avatar_get_loadable_icon (HDY_AVATAR (avatar)));

  g_object_ref (avatar);
  g_assert_true (did_draw_something (avatar));

  pixbuf = gdk_pixbuf_new (GDK_COLORSPACE_RGB, TRUE, 8, TEST_SIZE, TEST_SIZE);
  gdk_pixbuf_fill (pixbuf, 0);
  hdy_avatar_set_loadable_icon (HDY_AVATAR (avatar), G_LOADABLE_ICON (pixbuf));
  g_assert_false (did_draw_something (avatar));
  g_object_unref (avatar);
}

gint
main (gint argc,
      gchar *argv[])
{
  gtk_test_init (&argc, &argv, NULL);
  hdy_init ();

  g_test_add_func ("/Handy/Avatar/generate", test_hdy_avatar_generate);
  g_test_add_func ("/Handy/Avatar/custom_image", test_hdy_avatar_custom_image);
  g_test_add_func ("/Handy/Avatar/icon_name", test_hdy_avatar_icon_name);
  g_test_add_func ("/Handy/Avatar/text", test_hdy_avatar_text);
  g_test_add_func ("/Handy/Avatar/size", test_hdy_avatar_size);
  g_test_add_func ("/Handy/Avatar/draw_to_pixbuf", test_hdy_avatar_draw_to_pixbuf);
  g_test_add_func ("/Handy/Avatar/draw_to_pixbuf_async", test_hdy_avatar_draw_to_pixbuf_async);
  g_test_add_func ("/Handy/Avatar/loadable_icon", test_hdy_avatar_loadable_icon);

  return g_test_run ();
}
