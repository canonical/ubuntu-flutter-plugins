#include <gtk/gtk.h>
#include <handy.h>

#include "hdy-demo-preferences-window.h"
#include "hdy-demo-window.h"

static void
show_preferences (GSimpleAction *action,
                  GVariant      *state,
                  gpointer       user_data)
{
  GtkApplication *app = GTK_APPLICATION (user_data);
  GtkWindow *window = gtk_application_get_active_window (app);
  HdyDemoPreferencesWindow *preferences = hdy_demo_preferences_window_new ();

  gtk_window_set_transient_for (GTK_WINDOW (preferences), window);
  gtk_widget_show (GTK_WIDGET (preferences));
}

static void
setup_accels (GtkApplication *app)
{
  const char *const new_tab_accels[] = { "<Primary>T", NULL };
  const char *const new_window_accels[] = { "<Primary>N", NULL };
  const char *const tab_close_accels[] = { "<Primary>W", NULL };

  gtk_application_set_accels_for_action (app, "win.tab-new", new_tab_accels);
  gtk_application_set_accels_for_action (app, "win.window-new", new_window_accels);
  gtk_application_set_accels_for_action (app, "tab.close", tab_close_accels);
}

static void
startup (GtkApplication *app)
{
  GtkCssProvider *css_provider = gtk_css_provider_new ();

  hdy_init ();

  setup_accels (app);

  gtk_css_provider_load_from_resource (css_provider, "/sm/puri/Handy/Demo/ui/style.css");
  gtk_style_context_add_provider_for_screen (gdk_screen_get_default (),
                                             GTK_STYLE_PROVIDER (css_provider),
                                             GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

  hdy_style_manager_set_color_scheme (hdy_style_manager_get_default (),
                                      HDY_COLOR_SCHEME_PREFER_LIGHT);

  g_object_unref (css_provider);
}

static void
show_window (GtkApplication *app)
{
  HdyDemoWindow *window;

  window = hdy_demo_window_new (app);

  gtk_widget_show (GTK_WIDGET (window));
}

int
main (int    argc,
      char **argv)
{
  GtkApplication *app;
  int status;
  static GActionEntry app_entries[] = {
    { "preferences", show_preferences, NULL, NULL, NULL },
  };

  app = gtk_application_new ("sm.puri.Handy.Demo", G_APPLICATION_FLAGS_NONE);
  g_action_map_add_action_entries (G_ACTION_MAP (app),
                                   app_entries, G_N_ELEMENTS (app_entries),
                                   app);
  g_signal_connect (app, "startup", G_CALLBACK (startup), NULL);
  g_signal_connect (app, "activate", G_CALLBACK (show_window), NULL);
  status = g_application_run (G_APPLICATION (app), argc, argv);
  g_object_unref (app);

  return status;
}
