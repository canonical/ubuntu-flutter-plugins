/*
 * Copyright (C) 2020 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#include <handy.h>

gint notified;

static void
notify_cb (GtkWidget *widget, gpointer data)
{
  notified++;
}

static void
test_hdy_tab_bar_view (void)
{
  g_autoptr (HdyTabBar) bar = NULL;
  g_autoptr (HdyTabView) view = NULL;

  bar = g_object_ref_sink (HDY_TAB_BAR (hdy_tab_bar_new ()));
  g_assert_nonnull (bar);

  notified = 0;
  g_signal_connect (bar, "notify::view", G_CALLBACK (notify_cb), NULL);

  g_object_get (bar, "view", &view, NULL);
  g_assert_null (view);

  hdy_tab_bar_set_view (bar, NULL);
  g_assert_cmpint (notified, ==, 0);

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  hdy_tab_bar_set_view (bar, view);
  g_assert_true (hdy_tab_bar_get_view (bar) == view);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (bar, "view", NULL, NULL);
  g_assert_null (hdy_tab_bar_get_view (bar));
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_bar_start_action_widget (void)
{
  g_autoptr (HdyTabBar) bar = NULL;
  GtkWidget *widget = NULL;

  bar = g_object_ref_sink (HDY_TAB_BAR (hdy_tab_bar_new ()));
  g_assert_nonnull (bar);

  notified = 0;
  g_signal_connect (bar, "notify::start-action-widget", G_CALLBACK (notify_cb), NULL);

  g_object_get (bar, "start-action-widget", &widget, NULL);
  g_assert_null (widget);

  hdy_tab_bar_set_start_action_widget (bar, NULL);
  g_assert_cmpint (notified, ==, 0);

  widget = gtk_button_new ();
  hdy_tab_bar_set_start_action_widget (bar, widget);
  g_assert_true (hdy_tab_bar_get_start_action_widget (bar) == widget);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (bar, "start-action-widget", NULL, NULL);
  g_assert_null (hdy_tab_bar_get_start_action_widget (bar));
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_bar_end_action_widget (void)
{
  g_autoptr (HdyTabBar) bar = NULL;
  GtkWidget *widget = NULL;

  bar = g_object_ref_sink (HDY_TAB_BAR (hdy_tab_bar_new ()));
  g_assert_nonnull (bar);

  notified = 0;
  g_signal_connect (bar, "notify::end-action-widget", G_CALLBACK (notify_cb), NULL);

  g_object_get (bar, "end-action-widget", &widget, NULL);
  g_assert_null (widget);

  hdy_tab_bar_set_end_action_widget (bar, NULL);
  g_assert_cmpint (notified, ==, 0);

  widget = gtk_button_new ();
  hdy_tab_bar_set_end_action_widget (bar, widget);
  g_assert_true (hdy_tab_bar_get_end_action_widget (bar) == widget);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (bar, "end-action-widget", NULL, NULL);
  g_assert_null (hdy_tab_bar_get_end_action_widget (bar));
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_bar_autohide (void)
{
  g_autoptr (HdyTabBar) bar = NULL;
  gboolean autohide = FALSE;

  bar = g_object_ref_sink (HDY_TAB_BAR (hdy_tab_bar_new ()));
  g_assert_nonnull (bar);

  notified = 0;
  g_signal_connect (bar, "notify::autohide", G_CALLBACK (notify_cb), NULL);

  g_object_get (bar, "autohide", &autohide, NULL);
  g_assert_true (autohide);

  hdy_tab_bar_set_autohide (bar, TRUE);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_bar_set_autohide (bar, FALSE);
  g_assert_false (hdy_tab_bar_get_autohide (bar));
  g_assert_cmpint (notified, ==, 1);

  g_object_set (bar, "autohide", TRUE, NULL);
  g_assert_true (hdy_tab_bar_get_autohide (bar));
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_bar_tabs_revealed (void)
{
  g_autoptr (HdyTabBar) bar = NULL;
  g_autoptr (HdyTabView) view = NULL;
  gboolean tabs_revealed = FALSE;
  HdyTabPage *page;

  bar = g_object_ref_sink (HDY_TAB_BAR (hdy_tab_bar_new ()));
  g_assert_nonnull (bar);

  notified = 0;
  g_signal_connect (bar, "notify::tabs-revealed", G_CALLBACK (notify_cb), NULL);

  g_object_get (bar, "tabs-revealed", &tabs_revealed, NULL);
  g_assert_false (tabs_revealed);
  g_assert_false (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_bar_set_autohide (bar, FALSE);
  g_assert_false (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 0);

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  hdy_tab_bar_set_view (bar, view);
  g_assert_true (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 1);

  hdy_tab_bar_set_autohide (bar, TRUE);
  g_assert_false (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 2);

  page = hdy_tab_view_append_pinned (view, gtk_button_new ());
  g_assert_true (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 3);

  hdy_tab_view_set_page_pinned (view, page, FALSE);
  g_assert_false (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 4);

  hdy_tab_view_append (view, gtk_button_new ());
  g_assert_true (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 5);

  hdy_tab_view_close_page (view, page);
  g_assert_false (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 6);

  hdy_tab_bar_set_autohide (bar, FALSE);
  g_assert_true (hdy_tab_bar_get_tabs_revealed (bar));
  g_assert_cmpint (notified, ==, 7);
}

static void
test_hdy_tab_bar_expand_tabs (void)
{
  g_autoptr (HdyTabBar) bar = NULL;
  gboolean expand_tabs = FALSE;

  bar = g_object_ref_sink (HDY_TAB_BAR (hdy_tab_bar_new ()));
  g_assert_nonnull (bar);

  notified = 0;
  g_signal_connect (bar, "notify::expand-tabs", G_CALLBACK (notify_cb), NULL);

  g_object_get (bar, "expand-tabs", &expand_tabs, NULL);
  g_assert_true (expand_tabs);

  hdy_tab_bar_set_expand_tabs (bar, TRUE);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_bar_set_expand_tabs (bar, FALSE);
  g_assert_false (hdy_tab_bar_get_expand_tabs (bar));
  g_assert_cmpint (notified, ==, 1);

  g_object_set (bar, "expand-tabs", TRUE, NULL);
  g_assert_true (hdy_tab_bar_get_expand_tabs (bar));
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_bar_inverted (void)
{
  g_autoptr (HdyTabBar) bar = NULL;
  gboolean inverted = FALSE;

  bar = g_object_ref_sink (HDY_TAB_BAR (hdy_tab_bar_new ()));
  g_assert_nonnull (bar);

  notified = 0;
  g_signal_connect (bar, "notify::inverted", G_CALLBACK (notify_cb), NULL);

  g_object_get (bar, "inverted", &inverted, NULL);
  g_assert_false (inverted);

  hdy_tab_bar_set_inverted (bar, FALSE);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_bar_set_inverted (bar, TRUE);
  g_assert_true (hdy_tab_bar_get_inverted (bar));
  g_assert_cmpint (notified, ==, 1);

  g_object_set (bar, "inverted", FALSE, NULL);
  g_assert_false (hdy_tab_bar_get_inverted (bar));
  g_assert_cmpint (notified, ==, 2);
}

gint
main (gint argc,
      gchar *argv[])
{
  gtk_test_init (&argc, &argv, NULL);
  hdy_init ();

  g_test_add_func ("/Handy/TabBar/view", test_hdy_tab_bar_view);
  g_test_add_func ("/Handy/TabBar/start_action_widget", test_hdy_tab_bar_start_action_widget);
  g_test_add_func ("/Handy/TabBar/end_action_widget", test_hdy_tab_bar_end_action_widget);
  g_test_add_func ("/Handy/TabBar/autohide", test_hdy_tab_bar_autohide);
  g_test_add_func ("/Handy/TabBar/tabs_revealed", test_hdy_tab_bar_tabs_revealed);
  g_test_add_func ("/Handy/TabBar/expand_tabs", test_hdy_tab_bar_expand_tabs);
  g_test_add_func ("/Handy/TabBar/inverted", test_hdy_tab_bar_inverted);

  return g_test_run ();
}
