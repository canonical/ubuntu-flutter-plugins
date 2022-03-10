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
add_pages (HdyTabView  *view,
           HdyTabPage **pages,
           gint         n,
           gint         n_pinned)
{
  gint i;

  for (i = 0; i < n_pinned; i++)
    pages[i] = hdy_tab_view_append_pinned (view, gtk_button_new ());

  for (i = n_pinned; i < n; i++)
    pages[i] = hdy_tab_view_append (view, gtk_button_new ());
}

static void
assert_page_positions (HdyTabView  *view,
                       HdyTabPage **pages,
                       gint         n,
                       gint         n_pinned,
                       ...)
{
  va_list args;
  gint i;

  va_start (args, n_pinned);

  g_assert_cmpint (hdy_tab_view_get_n_pages (view), ==, n);
  g_assert_cmpint (hdy_tab_view_get_n_pinned_pages (view), ==, n_pinned);

  for (i = 0; i < n; i++) {
    gint index = va_arg (args, gint);

    if (index >= 0)
      g_assert_cmpint (hdy_tab_view_get_page_position (view, pages[index]), ==, i);
  }

  va_end (args);
}

static void
test_hdy_tab_view_n_pages (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  gint n_pages;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  notified = 0;
  g_signal_connect (view, "notify::n-pages", G_CALLBACK (notify_cb), NULL);

  g_object_get (view, "n-pages", &n_pages, NULL);
  g_assert_cmpint (n_pages, ==, 0);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_object_get (view, "n-pages", &n_pages, NULL);
  g_assert_cmpint (n_pages, ==, 1);
  g_assert_cmpint (hdy_tab_view_get_n_pages (view), ==, 1);
  g_assert_cmpint (notified, ==, 1);

  hdy_tab_view_append (view, gtk_button_new ());
  g_assert_cmpint (hdy_tab_view_get_n_pages (view), ==, 2);
  g_assert_cmpint (notified, ==, 2);

  hdy_tab_view_append_pinned (view, gtk_button_new ());
  g_assert_cmpint (hdy_tab_view_get_n_pages (view), ==, 3);
  g_assert_cmpint (notified, ==, 3);

  hdy_tab_view_reorder_forward (view, page);
  g_assert_cmpint (hdy_tab_view_get_n_pages (view), ==, 3);
  g_assert_cmpint (notified, ==, 3);

  hdy_tab_view_close_page (view, page);
  g_assert_cmpint (hdy_tab_view_get_n_pages (view), ==, 2);
  g_assert_cmpint (notified, ==, 4);
}

static void
test_hdy_tab_view_n_pinned_pages (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  gint n_pages;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  notified = 0;
  g_signal_connect (view, "notify::n-pinned-pages", G_CALLBACK (notify_cb), NULL);

  g_object_get (view, "n-pinned-pages", &n_pages, NULL);
  g_assert_cmpint (n_pages, ==, 0);

  hdy_tab_view_append_pinned (view, gtk_button_new ());
  g_object_get (view, "n-pinned-pages", &n_pages, NULL);
  g_assert_cmpint (n_pages, ==, 1);
  g_assert_cmpint (hdy_tab_view_get_n_pinned_pages (view), ==, 1);
  g_assert_cmpint (notified, ==, 1);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_cmpint (hdy_tab_view_get_n_pinned_pages (view), ==, 1);
  g_assert_cmpint (notified, ==, 1);

  hdy_tab_view_set_page_pinned (view, page, TRUE);
  g_assert_cmpint (hdy_tab_view_get_n_pinned_pages (view), ==, 2);
  g_assert_cmpint (notified, ==, 2);

  hdy_tab_view_reorder_backward (view, page);
  g_assert_cmpint (hdy_tab_view_get_n_pinned_pages (view), ==, 2);
  g_assert_cmpint (notified, ==, 2);

  hdy_tab_view_set_page_pinned (view, page, FALSE);
  g_assert_cmpint (hdy_tab_view_get_n_pinned_pages (view), ==, 1);
  g_assert_cmpint (notified, ==, 3);
}

static void
test_hdy_tab_view_default_icon (void)
{
  g_autoptr (HdyTabView) view = NULL;
  g_autoptr (GIcon) icon = NULL;
  g_autoptr (GIcon) icon1 = g_themed_icon_new ("go-previous-symbolic");
  g_autoptr (GIcon) icon2 = g_themed_icon_new ("go-next-symbolic");
  g_autofree gchar *icon_str = NULL;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  notified = 0;
  g_signal_connect (view, "notify::default-icon", G_CALLBACK (notify_cb), NULL);

  g_object_get (view, "default-icon", &icon, NULL);
  icon_str = g_icon_to_string (icon);
  g_assert_cmpstr (icon_str, ==, "hdy-tab-icon-missing-symbolic");
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_view_set_default_icon (view, icon1);
  g_assert_true (hdy_tab_view_get_default_icon (view) == icon1);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (view, "default-icon", icon2, NULL);
  g_assert_true (hdy_tab_view_get_default_icon (view) == icon2);
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_view_menu_model (void)
{
  g_autoptr (HdyTabView) view = NULL;
  GMenuModel *model = NULL;
  g_autoptr (GMenuModel) model1 = G_MENU_MODEL (g_menu_new ());
  g_autoptr (GMenuModel) model2 = G_MENU_MODEL (g_menu_new ());

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  notified = 0;
  g_signal_connect (view, "notify::menu-model", G_CALLBACK (notify_cb), NULL);

  g_object_get (view, "menu-model", &model, NULL);
  g_assert_null (model);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_view_set_menu_model (view, model1);
  g_assert_true (hdy_tab_view_get_menu_model (view) == model1);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (view, "menu-model", model2, NULL);
  g_assert_true (hdy_tab_view_get_menu_model (view) == model2);
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_view_shortcut_widget (void)
{
  g_autoptr (HdyTabView) view = NULL;
  GtkWidget *widget = NULL;
  g_autoptr (GtkWidget) widget1 = g_object_ref_sink (gtk_button_new ());
  g_autoptr (GtkWidget) widget2 = g_object_ref_sink (gtk_button_new ());

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  notified = 0;
  g_signal_connect (view, "notify::shortcut-widget", G_CALLBACK (notify_cb), NULL);

  g_object_get (view, "shortcut-widget", &widget, NULL);
  g_assert_null (widget);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_view_set_shortcut_widget (view, widget1);
  g_assert_true (hdy_tab_view_get_shortcut_widget (view) == widget1);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (view, "shortcut-widget", widget2, NULL);
  g_assert_true (hdy_tab_view_get_shortcut_widget (view) == widget2);
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_view_pages (void)
{
  g_autoptr (HdyTabView) view = NULL;
  GtkWidget *child1, *child2, *child3;
  HdyTabPage *page1, *page2, *page3;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  child1 = gtk_button_new ();
  child2 = gtk_button_new ();
  child3 = gtk_button_new ();

  page1 = hdy_tab_view_append_pinned (view, child1);
  page2 = hdy_tab_view_append (view, child2);
  page3 = hdy_tab_view_append (view, child3);

  g_assert_true (hdy_tab_view_get_nth_page (view, 0) == page1);
  g_assert_true (hdy_tab_view_get_nth_page (view, 1) == page2);
  g_assert_true (hdy_tab_view_get_nth_page (view, 2) == page3);

  g_assert_true (hdy_tab_view_get_page (view, child1) == page1);
  g_assert_true (hdy_tab_view_get_page (view, child2) == page2);
  g_assert_true (hdy_tab_view_get_page (view, child3) == page3);

  g_assert_cmpint (hdy_tab_view_get_page_position (view, page1), ==, 0);
  g_assert_cmpint (hdy_tab_view_get_page_position (view, page2), ==, 1);
  g_assert_cmpint (hdy_tab_view_get_page_position (view, page3), ==, 2);

  g_assert_true (hdy_tab_page_get_child (page1) == child1);
  g_assert_true (hdy_tab_page_get_child (page2) == child2);
  g_assert_true (hdy_tab_page_get_child (page3) == child3);
}

static void
test_hdy_tab_view_select (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page1, *page2, *selected_page;
  gboolean ret;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  notified = 0;
  g_signal_connect (view, "notify::selected-page", G_CALLBACK (notify_cb), NULL);

  g_object_get (view, "selected-page", &selected_page, NULL);
  g_assert_null (selected_page);

  page1 = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_true (hdy_tab_view_get_selected_page (view) == page1);
  g_assert_true (hdy_tab_page_get_selected (page1));
  g_assert_cmpint (notified, ==, 1);

  page2 = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_true (hdy_tab_view_get_selected_page (view) == page1);
  g_assert_true (hdy_tab_page_get_selected (page1));
  g_assert_false (hdy_tab_page_get_selected (page2));
  g_assert_cmpint (notified, ==, 1);

  hdy_tab_view_set_selected_page (view, page2);
  g_assert_true (hdy_tab_view_get_selected_page (view) == page2);
  g_assert_cmpint (notified, ==, 2);

  g_object_set (view, "selected-page", page1, NULL);
  g_assert_true (hdy_tab_view_get_selected_page (view) == page1);
  g_assert_cmpint (notified, ==, 3);

  ret = hdy_tab_view_select_previous_page (view);
  g_assert_true (hdy_tab_view_get_selected_page (view) == page1);
  g_assert_false (ret);
  g_assert_cmpint (notified, ==, 3);

  ret = hdy_tab_view_select_next_page (view);
  g_assert_true (hdy_tab_view_get_selected_page (view) == page2);
  g_assert_true (ret);
  g_assert_cmpint (notified, ==, 4);

  ret = hdy_tab_view_select_next_page (view);
  g_assert_true (hdy_tab_view_get_selected_page (view) == page2);
  g_assert_false (ret);
  g_assert_cmpint (notified, ==, 4);

  ret = hdy_tab_view_select_previous_page (view);
  g_assert_true (hdy_tab_view_get_selected_page (view) == page1);
  g_assert_true (ret);
  g_assert_cmpint (notified, ==, 5);
}

static void
test_hdy_tab_view_add_basic (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[6];

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  pages[0] = hdy_tab_view_append (view, gtk_button_new ());
  assert_page_positions (view, pages, 1, 0,
                         0);

  pages[1] = hdy_tab_view_prepend (view, gtk_button_new ());
  assert_page_positions (view, pages, 2, 0,
                         1, 0);

  pages[2] = hdy_tab_view_insert (view, gtk_button_new (), 1);
  assert_page_positions (view, pages, 3, 0,
                         1, 2, 0);

  pages[3] = hdy_tab_view_prepend_pinned (view, gtk_button_new ());
  assert_page_positions (view, pages, 4, 1,
                         3, 1, 2, 0);

  pages[4] = hdy_tab_view_append_pinned (view, gtk_button_new ());
  assert_page_positions (view, pages, 5, 2,
                         3, 4, 1, 2, 0);

  pages[5] = hdy_tab_view_insert_pinned (view, gtk_button_new (), 1);
  assert_page_positions (view, pages, 6, 3,
                         3, 5, 4, 1, 2, 0);
}

static void
test_hdy_tab_view_add_auto (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[17];

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  add_pages (view, pages, 3, 3);
  assert_page_positions (view, pages, 3, 3,
                         0, 1, 2);

  /* No parent */

  pages[3] = hdy_tab_view_add_page (view, gtk_button_new (), NULL);
  g_assert_null (hdy_tab_page_get_parent (pages[3]));
  assert_page_positions (view, pages, 4, 3,
                         0, 1, 2, 3);

  pages[4] = hdy_tab_view_add_page (view, gtk_button_new (), NULL);
  g_assert_null (hdy_tab_page_get_parent (pages[4]));
  assert_page_positions (view, pages, 5, 3,
                         0, 1, 2, 3, 4);

  pages[5] = hdy_tab_view_add_page (view, gtk_button_new (), NULL);
  g_assert_null (hdy_tab_page_get_parent (pages[5]));
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  /* Parent is a regular page */

  pages[6] = hdy_tab_view_add_page (view, gtk_button_new (), pages[4]);
  g_assert_true (hdy_tab_page_get_parent (pages[6]) == pages[4]);
  assert_page_positions (view, pages, 7, 3,
                         0, 1, 2, 3, 4, 6, 5);

  pages[7] = hdy_tab_view_add_page (view, gtk_button_new (), pages[4]);
  g_assert_true (hdy_tab_page_get_parent (pages[7]) == pages[4]);
  assert_page_positions (view, pages, 8, 3,
                         0, 1, 2, 3, 4, 6, 7, 5);

  pages[8] = hdy_tab_view_add_page (view, gtk_button_new (), pages[6]);
  g_assert_true (hdy_tab_page_get_parent (pages[8]) == pages[6]);
  assert_page_positions (view, pages, 9, 3,
                         0, 1, 2, 3, 4, 6, 8, 7, 5);

  pages[9] = hdy_tab_view_add_page (view, gtk_button_new (), pages[6]);
  g_assert_true (hdy_tab_page_get_parent (pages[9]) == pages[6]);
  assert_page_positions (view, pages, 10, 3,
                         0, 1, 2, 3, 4, 6, 8, 9, 7, 5);

  pages[10] = hdy_tab_view_add_page (view, gtk_button_new (), pages[4]);
  g_assert_true (hdy_tab_page_get_parent (pages[10]) == pages[4]);
  assert_page_positions (view, pages, 11, 3,
                         0, 1, 2, 3, 4, 6, 8, 9, 7, 10, 5);

  /* Parent is a pinned page */

  pages[11] = hdy_tab_view_add_page (view, gtk_button_new (), pages[1]);
  g_assert_true (hdy_tab_page_get_parent (pages[11]) == pages[1]);
  assert_page_positions (view, pages, 12, 3,
                         0, 1, 2, 11, 3, 4, 6, 8, 9, 7, 10, 5);

  pages[12] = hdy_tab_view_add_page (view, gtk_button_new (), pages[11]);
  g_assert_true (hdy_tab_page_get_parent (pages[12]) == pages[11]);
  assert_page_positions (view, pages, 13, 3,
                         0, 1, 2, 11, 12, 3, 4, 6, 8, 9, 7, 10, 5);

  pages[13] = hdy_tab_view_add_page (view, gtk_button_new (), pages[1]);
  g_assert_true (hdy_tab_page_get_parent (pages[13]) == pages[1]);
  assert_page_positions (view, pages, 14, 3,
                         0, 1, 2, 11, 12, 13, 3, 4, 6, 8, 9, 7, 10, 5);

  pages[14] = hdy_tab_view_add_page (view, gtk_button_new (), pages[0]);
  g_assert_true (hdy_tab_page_get_parent (pages[14]) == pages[0]);
  assert_page_positions (view, pages, 15, 3,
                         0, 1, 2, 14, 11, 12, 13, 3, 4, 6, 8, 9, 7, 10, 5);

  pages[15] = hdy_tab_view_add_page (view, gtk_button_new (), pages[1]);
  g_assert_true (hdy_tab_page_get_parent (pages[15]) == pages[1]);
  assert_page_positions (view, pages, 16, 3,
                         0, 1, 2, 15, 14, 11, 12, 13, 3, 4, 6, 8, 9, 7, 10, 5);

  /* Parent is the last page */

  pages[16] = hdy_tab_view_add_page (view, gtk_button_new (), pages[5]);
  g_assert_true (hdy_tab_page_get_parent (pages[16]) == pages[5]);
  assert_page_positions (view, pages, 17, 3,
                         0, 1, 2, 15, 14, 11, 12, 13, 3, 4, 6, 8, 9, 7, 10, 5, 16);
}

static void
test_hdy_tab_view_reorder (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[6];
  gboolean ret;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  add_pages (view, pages, 6, 3);

  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_page (view, pages[1], 1);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_page (view, pages[1], 0);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 0, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_page (view, pages[1], 1);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_page (view, pages[5], 5);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_page (view, pages[5], 4);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 5, 4);

  ret = hdy_tab_view_reorder_page (view, pages[5], 5);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);
}

static void
test_hdy_tab_view_reorder_first_last (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[6];
  gboolean ret;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  add_pages (view, pages, 6, 3);

  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_first (view, pages[0]);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_last (view, pages[0]);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 2, 0, 3, 4, 5);

  ret = hdy_tab_view_reorder_last (view, pages[0]);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 2, 0, 3, 4, 5);

  ret = hdy_tab_view_reorder_first (view, pages[0]);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_first (view, pages[3]);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_last (view, pages[3]);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 4, 5, 3);

  ret = hdy_tab_view_reorder_last (view, pages[3]);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 4, 5, 3);

  ret = hdy_tab_view_reorder_first (view, pages[3]);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);
}

static void
test_hdy_tab_view_reorder_forward_backward (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[6];
  gboolean ret;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  add_pages (view, pages, 6, 3);

  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_backward (view, pages[0]);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_forward (view, pages[0]);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 0, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_forward (view, pages[2]);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 0, 2, 3, 4, 5);

  ret = hdy_tab_view_reorder_backward (view, pages[2]);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 2, 0, 3, 4, 5);

  ret = hdy_tab_view_reorder_backward (view, pages[3]);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 2, 0, 3, 4, 5);

  ret = hdy_tab_view_reorder_forward (view, pages[3]);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 2, 0, 4, 3, 5);

  ret = hdy_tab_view_reorder_forward (view, pages[5]);
  g_assert_false (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 2, 0, 4, 3, 5);

  ret = hdy_tab_view_reorder_backward (view, pages[5]);
  g_assert_true (ret);
  assert_page_positions (view, pages, 6, 3,
                         1, 2, 0, 4, 5, 3);
}

static void
test_hdy_tab_view_pin (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[4];

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  /* Test specifically pinning with only 1 page */
  pages[0] = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_false (hdy_tab_page_get_pinned (pages[0]));
  assert_page_positions (view, pages, 1, 0,
                         0);

  hdy_tab_view_set_page_pinned (view, pages[0], TRUE);
  g_assert_true (hdy_tab_page_get_pinned (pages[0]));
  assert_page_positions (view, pages, 1, 1,
                         0);

  hdy_tab_view_set_page_pinned (view, pages[0], FALSE);
  g_assert_false (hdy_tab_page_get_pinned (pages[0]));
  assert_page_positions (view, pages, 1, 0,
                         0);

  pages[1] = hdy_tab_view_append (view, gtk_button_new ());
  pages[2] = hdy_tab_view_append (view, gtk_button_new ());
  pages[3] = hdy_tab_view_append (view, gtk_button_new ());
  assert_page_positions (view, pages, 4, 0,
                         0, 1, 2, 3);

  hdy_tab_view_set_page_pinned (view, pages[2], TRUE);
  assert_page_positions (view, pages, 4, 1,
                         2, 0, 1, 3);

  hdy_tab_view_set_page_pinned (view, pages[1], TRUE);
  assert_page_positions (view, pages, 4, 2,
                         2, 1, 0, 3);

  hdy_tab_view_set_page_pinned (view, pages[0], TRUE);
  assert_page_positions (view, pages, 4, 3,
                         2, 1, 0, 3);

  hdy_tab_view_set_page_pinned (view, pages[1], FALSE);
  assert_page_positions (view, pages, 4, 2,
                         2, 0, 1, 3);
}

static void
test_hdy_tab_view_close (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[3];

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  add_pages (view, pages, 3, 0);

  hdy_tab_view_set_selected_page (view, pages[1]);

  assert_page_positions (view, pages, 3, 0,
                         0, 1, 2);

  hdy_tab_view_close_page (view, pages[1]);
  assert_page_positions (view, pages, 2, 0,
                         0, 2);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[2]);

  hdy_tab_view_close_page (view, pages[2]);
  assert_page_positions (view, pages, 1, 0,
                         0);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[0]);

  hdy_tab_view_close_page (view, pages[0]);
  assert_page_positions (view, pages, 0, 0);
  g_assert_null (hdy_tab_view_get_selected_page (view));
}

static void
test_hdy_tab_view_close_other (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[6];

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  add_pages (view, pages, 6, 3);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 3, 4, 5);

  hdy_tab_view_close_other_pages (view, pages[4]);
  assert_page_positions (view, pages, 4, 3,
                         0, 1, 2, 4);

  hdy_tab_view_close_other_pages (view, pages[2]);
  assert_page_positions (view, pages, 3, 3,
                         0, 1, 2);
}

static void
test_hdy_tab_view_close_before_after (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[10];

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  add_pages (view, pages, 10, 3);
  assert_page_positions (view, pages, 10, 3,
                         0, 1, 2, 3, 4, 5, 6, 7, 8, 9);

  hdy_tab_view_close_pages_before (view, pages[3]);
  assert_page_positions (view, pages, 10, 3,
                         0, 1, 2, 3, 4, 5, 6, 7, 8, 9);

  hdy_tab_view_close_pages_before (view, pages[5]);
  assert_page_positions (view, pages, 8, 3,
                         0, 1, 2, 5, 6, 7, 8, 9);

  hdy_tab_view_close_pages_after (view, pages[7]);
  assert_page_positions (view, pages, 6, 3,
                         0, 1, 2, 5, 6, 7);

  hdy_tab_view_close_pages_after (view, pages[0]);
  assert_page_positions (view, pages, 3, 3,
                         0, 1, 2);
}

static gboolean
close_page_position_cb (HdyTabView *view,
                        HdyTabPage *page)
{
  gint position = hdy_tab_view_get_page_position (view, page);

  hdy_tab_view_close_page_finish (view, page, (position % 2) > 0);

  return GDK_EVENT_STOP;
}

static void
test_hdy_tab_view_close_signal (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[10];
  gulong handler;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  /* Allow closing pages with odd positions, including pinned */
  handler = g_signal_connect (view, "close-page",
                              G_CALLBACK (close_page_position_cb), NULL);

  add_pages (view, pages, 10, 3);
  assert_page_positions (view, pages, 10, 3,
                         0, 1, 2, 3, 4, 5, 6, 7, 8, 9);

  hdy_tab_view_close_other_pages (view, pages[5]);
  assert_page_positions (view, pages, 6, 2,
                         0, 2, 4, 5, 6, 8);

  g_signal_handler_disconnect (view, handler);

  /* Defer closing */
  handler = g_signal_connect (view, "close-page", G_CALLBACK (gtk_true), NULL);

  hdy_tab_view_close_page (view, pages[0]);
  assert_page_positions (view, pages, 6, 2,
                         0, 2, 4, 5, 6, 8);

  hdy_tab_view_close_page_finish (view, pages[0], FALSE);
  assert_page_positions (view, pages, 6, 2,
                         0, 2, 4, 5, 6, 8);

  hdy_tab_view_close_page (view, pages[0]);
  assert_page_positions (view, pages, 6, 2,
                         0, 2, 4, 5, 6, 8);

  hdy_tab_view_close_page_finish (view, pages[0], TRUE);
  assert_page_positions (view, pages, 5, 1,
                         2, 4, 5, 6, 8);

  g_signal_handler_disconnect (view, handler);
}

static void
test_hdy_tab_view_close_select (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *pages[14];

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  add_pages (view, pages, 9, 3);
  pages[9] = hdy_tab_view_add_page (view, gtk_button_new (), pages[4]);
  pages[10] = hdy_tab_view_add_page (view, gtk_button_new (), pages[4]);
  pages[11] = hdy_tab_view_add_page (view, gtk_button_new (), pages[9]);
  pages[12] = hdy_tab_view_add_page (view, gtk_button_new (), pages[1]);
  pages[13] = hdy_tab_view_add_page (view, gtk_button_new (), pages[1]);

  assert_page_positions (view, pages, 14, 3,
                         0, 1, 2, 12, 13, 3, 4, 9, 11, 10, 5, 6, 7, 8);

  /* Nothing happens when closing unselected pages */

  hdy_tab_view_set_selected_page (view, pages[0]);

  hdy_tab_view_close_page (view, pages[8]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[0]);

  /* No parent */

  assert_page_positions (view, pages, 13, 3,
                         0, 1, 2, 12, 13, 3, 4, 9, 11, 10, 5, 6, 7);

  hdy_tab_view_set_selected_page (view, pages[6]);

  hdy_tab_view_close_page (view, pages[6]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[7]);

  hdy_tab_view_close_page (view, pages[7]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[5]);

  /* Regular parent */

  assert_page_positions (view, pages, 11, 3,
                         0, 1, 2, 12, 13, 3, 4, 9, 11, 10, 5);

  hdy_tab_view_set_selected_page (view, pages[10]);

  hdy_tab_view_close_page (view, pages[10]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[11]);

  hdy_tab_view_close_page (view, pages[11]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[9]);

  hdy_tab_view_close_page (view, pages[9]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[4]);

  hdy_tab_view_close_page (view, pages[4]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[5]);

  /* Pinned parent */

  assert_page_positions (view, pages, 7, 3,
                         0, 1, 2, 12, 13, 3, 5);

  hdy_tab_view_set_selected_page (view, pages[13]);

  hdy_tab_view_close_page (view, pages[13]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[12]);

  hdy_tab_view_close_page (view, pages[12]);
  g_assert_true (hdy_tab_view_get_selected_page (view) == pages[1]);
}

static void
test_hdy_tab_view_transfer (void)
{
  g_autoptr (HdyTabView) view1 = NULL;
  g_autoptr (HdyTabView) view2 = NULL;
  HdyTabPage *pages1[4], *pages2[4];

  view1 = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view1);

  view2 = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view2);

  add_pages (view1, pages1, 4, 2);
  assert_page_positions (view1, pages1, 4, 2,
                         0, 1, 2, 3);

  add_pages (view2, pages2, 4, 2);
  assert_page_positions (view2, pages2, 4, 2,
                         0, 1, 2, 3);

  hdy_tab_view_transfer_page (view1, pages1[1], view2, 1);
  assert_page_positions (view1, pages1, 3, 1,
                         0, 2, 3);
  assert_page_positions (view2, pages2, 5, 3,
                         0, -1, 1, 2, 3);
  g_assert_true (hdy_tab_view_get_nth_page (view2, 1) == pages1[1]);

  hdy_tab_view_transfer_page (view2, pages2[3], view1, 2);
  assert_page_positions (view1, pages1, 4, 1,
                         0, 2, -1, 3);
  assert_page_positions (view2, pages2, 4, 3,
                         0, -1, 1, 2);
  g_assert_true (hdy_tab_view_get_nth_page (view1, 2) == pages2[3]);
}

static void
test_hdy_tab_page_title (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  const gchar *title;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_nonnull (page);

  notified = 0;
  g_signal_connect (page, "notify::title", G_CALLBACK (notify_cb), NULL);

  g_object_get (page, "title", &title, NULL);
  g_assert_null (title);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_page_set_title (page, "Some title");
  g_assert_cmpstr (hdy_tab_page_get_title (page), ==, "Some title");
  g_assert_cmpint (notified, ==, 1);

  g_object_set (page, "title", "Some other title", NULL);
  g_assert_cmpstr (hdy_tab_page_get_title (page), ==, "Some other title");
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_page_tooltip (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  const gchar *tooltip;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_nonnull (page);

  notified = 0;
  g_signal_connect (page, "notify::tooltip", G_CALLBACK (notify_cb), NULL);

  g_object_get (page, "tooltip", &tooltip, NULL);
  g_assert_null (tooltip);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_page_set_tooltip (page, "Some tooltip");
  g_assert_cmpstr (hdy_tab_page_get_tooltip (page), ==, "Some tooltip");
  g_assert_cmpint (notified, ==, 1);

  g_object_set (page, "tooltip", "Some other tooltip", NULL);
  g_assert_cmpstr (hdy_tab_page_get_tooltip (page), ==, "Some other tooltip");
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_page_icon (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  GIcon *icon = NULL;
  g_autoptr (GIcon) icon1 = g_themed_icon_new ("go-previous-symbolic");
  g_autoptr (GIcon) icon2 = g_themed_icon_new ("go-next-symbolic");

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_nonnull (page);

  notified = 0;
  g_signal_connect (page, "notify::icon", G_CALLBACK (notify_cb), NULL);

  g_object_get (page, "icon", &icon, NULL);
  g_assert_null (icon);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_page_set_icon (page, icon1);
  g_assert_true (hdy_tab_page_get_icon (page) == icon1);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (page, "icon", icon2, NULL);
  g_assert_true (hdy_tab_page_get_icon (page) == icon2);
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_page_loading (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  gboolean loading;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_nonnull (page);

  notified = 0;
  g_signal_connect (page, "notify::loading", G_CALLBACK (notify_cb), NULL);

  g_object_get (page, "loading", &loading, NULL);
  g_assert_false (loading);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_page_set_loading (page, TRUE);
  g_object_get (page, "loading", &loading, NULL);
  g_assert_true (loading);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (page, "loading", FALSE, NULL);
  g_assert_false (hdy_tab_page_get_loading (page));
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_page_indicator_icon (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  GIcon *icon = NULL;
  g_autoptr (GIcon) icon1 = g_themed_icon_new ("go-previous-symbolic");
  g_autoptr (GIcon) icon2 = g_themed_icon_new ("go-next-symbolic");

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_nonnull (page);

  notified = 0;
  g_signal_connect (page, "notify::indicator-icon", G_CALLBACK (notify_cb), NULL);

  g_object_get (page, "indicator-icon", &icon, NULL);
  g_assert_null (icon);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_page_set_indicator_icon (page, icon1);
  g_assert_true (hdy_tab_page_get_indicator_icon (page) == icon1);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (page, "indicator-icon", icon2, NULL);
  g_assert_true (hdy_tab_page_get_indicator_icon (page) == icon2);
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_page_indicator_activatable (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  gboolean activatable;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_nonnull (page);

  notified = 0;
  g_signal_connect (page, "notify::indicator-activatable", G_CALLBACK (notify_cb), NULL);

  g_object_get (page, "indicator-activatable", &activatable, NULL);
  g_assert_false (activatable);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_page_set_indicator_activatable (page, TRUE);
  g_object_get (page, "indicator-activatable", &activatable, NULL);
  g_assert_true (activatable);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (page, "indicator-activatable", FALSE, NULL);
  g_assert_false (hdy_tab_page_get_indicator_activatable (page));
  g_assert_cmpint (notified, ==, 2);
}

static void
test_hdy_tab_page_needs_attention (void)
{
  g_autoptr (HdyTabView) view = NULL;
  HdyTabPage *page;
  gboolean needs_attention;

  view = g_object_ref_sink (HDY_TAB_VIEW (hdy_tab_view_new ()));
  g_assert_nonnull (view);

  page = hdy_tab_view_append (view, gtk_button_new ());
  g_assert_nonnull (page);

  notified = 0;
  g_signal_connect (page, "notify::needs-attention", G_CALLBACK (notify_cb), NULL);

  g_object_get (page, "needs-attention", &needs_attention, NULL);
  g_assert_false (needs_attention);
  g_assert_cmpint (notified, ==, 0);

  hdy_tab_page_set_needs_attention (page, TRUE);
  g_object_get (page, "needs-attention", &needs_attention, NULL);
  g_assert_true (needs_attention);
  g_assert_cmpint (notified, ==, 1);

  g_object_set (page, "needs-attention", FALSE, NULL);
  g_assert_false (hdy_tab_page_get_needs_attention (page));
  g_assert_cmpint (notified, ==, 2);
}

gint
main (gint argc,
      gchar *argv[])
{
  gtk_test_init (&argc, &argv, NULL);
  hdy_init ();

  g_test_add_func ("/Handy/TabView/n_pages", test_hdy_tab_view_n_pages);
  g_test_add_func ("/Handy/TabView/n_pinned_pages", test_hdy_tab_view_n_pinned_pages);
  g_test_add_func ("/Handy/TabView/default_icon", test_hdy_tab_view_default_icon);
  g_test_add_func ("/Handy/TabView/menu_model", test_hdy_tab_view_menu_model);
  g_test_add_func ("/Handy/TabView/shortcut_widget", test_hdy_tab_view_shortcut_widget);
  g_test_add_func ("/Handy/TabView/pages", test_hdy_tab_view_pages);
  g_test_add_func ("/Handy/TabView/select", test_hdy_tab_view_select);
  g_test_add_func ("/Handy/TabView/add_basic", test_hdy_tab_view_add_basic);
  g_test_add_func ("/Handy/TabView/add_auto", test_hdy_tab_view_add_auto);
  g_test_add_func ("/Handy/TabView/reorder", test_hdy_tab_view_reorder);
  g_test_add_func ("/Handy/TabView/reorder_first_last", test_hdy_tab_view_reorder_first_last);
  g_test_add_func ("/Handy/TabView/reorder_forward_backward", test_hdy_tab_view_reorder_forward_backward);
  g_test_add_func ("/Handy/TabView/pin", test_hdy_tab_view_pin);
  g_test_add_func ("/Handy/TabView/close", test_hdy_tab_view_close);
  g_test_add_func ("/Handy/TabView/close_other", test_hdy_tab_view_close_other);
  g_test_add_func ("/Handy/TabView/close_before_after", test_hdy_tab_view_close_before_after);
  g_test_add_func ("/Handy/TabView/close_signal", test_hdy_tab_view_close_signal);
  g_test_add_func ("/Handy/TabView/close_select", test_hdy_tab_view_close_select);
  g_test_add_func ("/Handy/TabView/transfer", test_hdy_tab_view_transfer);
  g_test_add_func ("/Handy/TabPage/title", test_hdy_tab_page_title);
  g_test_add_func ("/Handy/TabPage/tooltip", test_hdy_tab_page_tooltip);
  g_test_add_func ("/Handy/TabPage/icon", test_hdy_tab_page_icon);
  g_test_add_func ("/Handy/TabPage/loading", test_hdy_tab_page_loading);
  g_test_add_func ("/Handy/TabPage/indicator_icon", test_hdy_tab_page_indicator_icon);
  g_test_add_func ("/Handy/TabPage/indicator_activatable", test_hdy_tab_page_indicator_activatable);
  g_test_add_func ("/Handy/TabPage/needs_attention", test_hdy_tab_page_needs_attention);

  return g_test_run ();
}
