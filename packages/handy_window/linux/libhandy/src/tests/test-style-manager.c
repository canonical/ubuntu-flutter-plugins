/*
 * Copyright (C) 2021 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#include <handy.h>

int notified;

static void
notify_cb (GtkWidget *widget, gpointer data)
{
  notified++;
}

static void
test_hdy_style_manager_color_scheme (void)
{
  HdyStyleManager *manager = hdy_style_manager_get_default ();
  HdyColorScheme color_scheme;

  notified = 0;
  g_signal_connect (manager, "notify::color-scheme", G_CALLBACK (notify_cb), NULL);

  g_object_get (manager, "color-scheme", &color_scheme, NULL);
  g_assert_cmpint (color_scheme, ==, HDY_COLOR_SCHEME_DEFAULT);
  g_assert_cmpint (notified, ==, 0);

  hdy_style_manager_set_color_scheme (manager, HDY_COLOR_SCHEME_DEFAULT);
  g_assert_cmpint (notified, ==, 0);

  hdy_style_manager_set_color_scheme (manager, HDY_COLOR_SCHEME_PREFER_DARK);
  g_object_get (manager, "color-scheme", &color_scheme, NULL);
  g_assert_cmpint (color_scheme, ==, HDY_COLOR_SCHEME_PREFER_DARK);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (manager, "color-scheme", HDY_COLOR_SCHEME_PREFER_LIGHT, NULL);
  g_assert_cmpint (hdy_style_manager_get_color_scheme (manager), ==, HDY_COLOR_SCHEME_PREFER_LIGHT);
  g_assert_cmpint (notified, ==, 2);
}

int
main (int   argc,
      char *argv[])
{
  gtk_test_init (&argc, &argv, NULL);
  hdy_init ();

  g_test_add_func("/Hdyaita/StyleManager/color_scheme", test_hdy_style_manager_color_scheme);

  return g_test_run();
}
