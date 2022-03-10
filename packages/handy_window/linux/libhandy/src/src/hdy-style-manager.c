/*
 * Copyright (C) 2021 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#include "config.h"
#include <glib/gi18n-lib.h>

#include "hdy-style-manager.h"

#include "hdy-settings-private.h"
#include <gtk/gtk.h>

#define SWITCH_DURATION 250

/**
 * HdyColorScheme:
 * @HDY_COLOR_SCHEME_DEFAULT: Inherit the parent color-scheme. When set on the
 *   [class@StyleManager] returned by [func@StyleManager.get_default], it's
 *   equivalent to `HDY_COLOR_SCHEME_FORCE_LIGHT`.
 * @HDY_COLOR_SCHEME_FORCE_LIGHT: Always use light appearance.
 * @HDY_COLOR_SCHEME_PREFER_LIGHT: Use light appearance unless the system
 *   prefers dark colors.
 * @HDY_COLOR_SCHEME_PREFER_DARK: Use dark appearance unless the system prefers
 *   light colors.
 * @HDY_COLOR_SCHEME_FORCE_DARK: Always use dark appearance.
 *
 * Application color schemes for [property@StyleManager:color-scheme].
 *
 * Since: 1.6
 */

/**
 * HdyStyleManager:
 *
 * A class for managing application-wide styling.
 *
 * `HdyStyleManager` provides a way to query and influence the application
 * styles, such as whether to use dark or high contrast appearance.
 *
 * It allows to set the color scheme via the
 * [property@StyleManager:color-scheme] property, and to query the current
 * appearance, as well as whether a system-wide color scheme preference exists.
 *
 * Important: [property@Gtk.Settings:gtk-application-prefer-dark-theme] should
 * not be used together with `HdyStyleManager` and will result in a warning.
 * Color schemes should be used instead.
 *
 * Since: 1.6
 */

struct _HdyStyleManager
{
  GObject parent_instance;

  GdkDisplay *display;
  HdySettings *settings;

  HdyColorScheme color_scheme;
  gboolean dark;

  GtkCssProvider *animations_provider;
  guint animation_timeout_id;
};

G_DEFINE_TYPE (HdyStyleManager, hdy_style_manager, G_TYPE_OBJECT);

enum {
  PROP_0,
  PROP_DISPLAY,
  PROP_COLOR_SCHEME,
  PROP_SYSTEM_SUPPORTS_COLOR_SCHEMES,
  PROP_DARK,
  PROP_HIGH_CONTRAST,
  LAST_PROP,
};

static GParamSpec *props[LAST_PROP];

static GHashTable *display_style_managers = NULL;
static HdyStyleManager *default_instance = NULL;

/* Copied from gtkcssprovider.c */

static gchar *
get_theme_dir (void)
{
  const gchar *var;

  var = g_getenv ("GTK_DATA_PREFIX");
  if (var == NULL)
    var = PREFIX;

  return g_build_filename (var, "share", "themes", NULL);
}

#if (GTK_MINOR_VERSION % 2)
#define MINOR (GTK_MINOR_VERSION + 1)
#else
#define MINOR GTK_MINOR_VERSION
#endif

static gchar *
find_theme_dir (const gchar *dir,
                const gchar *subdir,
                const gchar *name,
                const gchar *variant)
{
  g_autofree gchar *file = NULL;
  g_autofree gchar *base = NULL;
  gchar *path;
  gint i;

  if (variant)
    file = g_strconcat ("gtk-", variant, ".css", NULL);
  else
    file = g_strdup ("gtk.css");

  if (subdir)
    base = g_build_filename (dir, subdir, name, NULL);
  else
    base = g_build_filename (dir, name, NULL);

  for (i = MINOR; i >= 0; i = i - 2) {
    g_autofree gchar *subsubdir = NULL;

    if (i < 14)
      i = 0;

    subsubdir = g_strdup_printf ("gtk-3.%d", i);
    path = g_build_filename (base, subsubdir, file, NULL);

    if (g_file_test (path, G_FILE_TEST_EXISTS))
      break;

    g_free (path);
    path = NULL;
  }

  return path;
}

#undef MINOR

static gchar *
find_theme (const gchar *name,
            const gchar *variant)
{
  g_autofree gchar *dir = NULL;
  const gchar *const *dirs;
  gchar *path;
  gint i;

  /* First look in the user's data directory */
  path = find_theme_dir (g_get_user_data_dir (), "themes", name, variant);
  if (path)
    return path;

  /* Next look in the user's home directory */
  path = find_theme_dir (g_get_home_dir (), ".themes", name, variant);
  if (path)
    return path;

  /* Look in system data directories */
  dirs = g_get_system_data_dirs ();
  for (i = 0; dirs[i]; i++) {
    path = find_theme_dir (dirs[i], "themes", name, variant);
    if (path)
      return path;
  }

  /* Finally, try in the default theme directory */
  dir = get_theme_dir ();
  path = find_theme_dir (dir, NULL, name, variant);

  return path;
}

static gboolean
check_theme_exists (const gchar *name,
                    const gchar *variant)
{
  g_autofree gchar *resource_path = NULL;
  g_autofree gchar *path = NULL;

  /* try loading the resource for the theme. This is mostly meant for built-in
   * themes.
   */
  if (variant)
    resource_path = g_strdup_printf ("/org/gtk/libgtk/theme/%s/gtk-%s.css", name, variant);
  else
    resource_path = g_strdup_printf ("/org/gtk/libgtk/theme/%s/gtk.css", name);

  if (g_resources_get_info (resource_path, 0, NULL, NULL, NULL))
    return TRUE;

  /* Next try looking for files in the various theme directories. */
  path = find_theme (name, variant);

  return path != NULL;
}

static gchar *
get_system_theme_name (void)
{
  GdkScreen *screen = gdk_screen_get_default ();
  g_auto (GValue) value = G_VALUE_INIT;

  g_value_init (&value, G_TYPE_STRING);
  if (!gdk_screen_get_setting (screen, "gtk-theme-name", &value))
    return g_strdup ("Adwaita");

  return g_value_dup_string (&value);
}

static gboolean
check_current_theme_exists (gboolean dark)
{
  g_autofree gchar *theme_name = get_system_theme_name ();

  return check_theme_exists (theme_name, dark ? "dark" : NULL);
}

static void
warn_prefer_dark_theme (HdyStyleManager *self)
{
  g_warning ("Using GtkSettings:gtk-application-prefer-dark-theme together "
             "with HdyStyleManager is unsupported. Please use "
             "HdyStyleManager:color-scheme instead.");
}

static void
unregister_display (GdkDisplay *display)
{
  g_assert (!g_hash_table_contains (display_style_managers, display));

  g_hash_table_remove (display_style_managers, display);
}

static void
register_display (GdkDisplayManager *display_manager,
                  GdkDisplay        *display)
{
  HdyStyleManager *style_manager;

  style_manager = g_object_new (HDY_TYPE_STYLE_MANAGER,
                                "display", display,
                                NULL);

  g_assert (!g_hash_table_contains (display_style_managers, display));

  g_hash_table_insert (display_style_managers, display, style_manager);

  g_signal_connect (display,
                    "closed",
                    G_CALLBACK (unregister_display),
                    NULL);
}

static gboolean
enable_animations_cb (HdyStyleManager *self)
{
  GdkScreen *screen = gdk_display_get_default_screen (self->display);

  gtk_style_context_remove_provider_for_screen (screen,
                                                GTK_STYLE_PROVIDER (self->animations_provider));

  self->animation_timeout_id = 0;

  return G_SOURCE_REMOVE;
}

static void update_stylesheet (HdyStyleManager *self);

static gboolean
unblock_theme_name_changed_cb (HdyStyleManager *self)
{
  GdkScreen *screen;
  GtkSettings *gtk_settings;

  screen = gdk_display_get_default_screen (self->display);
  gtk_settings = gtk_settings_get_for_screen (screen);

  g_signal_handlers_unblock_by_func (gtk_settings,
                                     G_CALLBACK (update_stylesheet),
                                     self);

  return G_SOURCE_REMOVE;
}

static void
update_stylesheet (HdyStyleManager *self)
{
  GdkScreen *screen;
  GtkSettings *gtk_settings;

  if (!self->display)
    return;

  screen = gdk_display_get_default_screen (self->display);
  gtk_settings = gtk_settings_get_for_screen (screen);

  g_signal_handlers_block_by_func (gtk_settings,
                                   G_CALLBACK (warn_prefer_dark_theme),
                                   self);
  g_signal_handlers_block_by_func (gtk_settings,
                                   G_CALLBACK (update_stylesheet),
                                   self);

  if (self->animation_timeout_id)
    g_clear_handle_id (&self->animation_timeout_id, g_source_remove);

  gtk_style_context_add_provider_for_screen (screen,
                                             GTK_STYLE_PROVIDER (self->animations_provider),
                                             10000);

  g_object_set (gtk_settings,
                "gtk-application-prefer-dark-theme", self->dark,
                NULL);

  if (hdy_settings_get_high_contrast (self->settings))
    g_object_set (gtk_settings,
                  "gtk-theme-name",
                  self->dark ? "HighContrastInverse" : "HighContrast",
                  NULL);
  else if (check_current_theme_exists (self->dark))
    gtk_settings_reset_property (gtk_settings, "gtk-theme-name");
  else
    g_object_set (gtk_settings, "gtk-theme-name", "Adwaita", NULL);

  g_signal_handlers_unblock_by_func (gtk_settings,
                                     G_CALLBACK (warn_prefer_dark_theme),
                                     self);

  self->animation_timeout_id =
    g_timeout_add (SWITCH_DURATION,
                   G_SOURCE_FUNC (enable_animations_cb),
                   self);

  g_idle_add (G_SOURCE_FUNC (unblock_theme_name_changed_cb), self);
}

static inline gboolean
get_is_dark (HdyStyleManager *self)
{
  HdySystemColorScheme system_scheme = hdy_settings_get_color_scheme (self->settings);

  switch (self->color_scheme) {
  case HDY_COLOR_SCHEME_DEFAULT:
    if (self->display)
      return get_is_dark (default_instance);
    return FALSE;
  case HDY_COLOR_SCHEME_FORCE_LIGHT:
    return FALSE;
  case HDY_COLOR_SCHEME_PREFER_LIGHT:
    return system_scheme == HDY_SYSTEM_COLOR_SCHEME_PREFER_DARK;
  case HDY_COLOR_SCHEME_PREFER_DARK:
    return system_scheme != HDY_SYSTEM_COLOR_SCHEME_PREFER_LIGHT;
  case HDY_COLOR_SCHEME_FORCE_DARK:
    return TRUE;
  default:
    g_assert_not_reached ();
  }
}

static void
update_dark (HdyStyleManager *self)
{
  gboolean dark = get_is_dark (self);

  if (dark == self->dark)
    return;

  self->dark = dark;

  update_stylesheet (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_DARK]);
}

static void
notify_high_contrast_cb (HdyStyleManager *self)
{
  update_stylesheet (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_HIGH_CONTRAST]);
}

static void
hdy_style_manager_constructed (GObject *object)
{
  HdyStyleManager *self = HDY_STYLE_MANAGER (object);

  G_OBJECT_CLASS (hdy_style_manager_parent_class)->constructed (object);

  if (self->display) {
    GdkScreen *screen = gdk_display_get_default_screen (self->display);
    GtkSettings *settings = gtk_settings_get_for_screen (screen);
    gboolean prefer_dark_theme;

    g_object_get (settings,
                  "gtk-application-prefer-dark-theme", &prefer_dark_theme,
                  NULL);

    if (prefer_dark_theme)
      warn_prefer_dark_theme (self);

    g_signal_connect_object (settings,
                             "notify::gtk-application-prefer-dark-theme",
                             G_CALLBACK (warn_prefer_dark_theme),
                             self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (settings,
                             "notify::gtk-theme-name",
                             G_CALLBACK (update_stylesheet),
                             self,
                             G_CONNECT_SWAPPED);

    self->animations_provider = gtk_css_provider_new ();
    gtk_css_provider_load_from_data (self->animations_provider,
                                     "* { transition: none; }",
                                     -1,
                                     NULL);
  }

  self->settings = hdy_settings_get_default ();

  g_signal_connect_object (self->settings,
                           "notify::color-scheme",
                           G_CALLBACK (update_dark),
                           self,
                           G_CONNECT_SWAPPED);
  g_signal_connect_object (self->settings,
                           "notify::high-contrast",
                           G_CALLBACK (notify_high_contrast_cb),
                           self,
                           G_CONNECT_SWAPPED);

  update_dark (self);
  update_stylesheet (self);
}

static void
hdy_style_manager_dispose (GObject *object)
{
  HdyStyleManager *self = HDY_STYLE_MANAGER (object);

  g_clear_handle_id (&self->animation_timeout_id, g_source_remove);
  g_clear_object (&self->animations_provider);

  G_OBJECT_CLASS (hdy_style_manager_parent_class)->dispose (object);
}

static void
hdy_style_manager_get_property (GObject    *object,
                                guint       prop_id,
                                GValue     *value,
                                GParamSpec *pspec)
{
  HdyStyleManager *self = HDY_STYLE_MANAGER (object);

  switch (prop_id) {
  case PROP_DISPLAY:
    g_value_set_object (value, hdy_style_manager_get_display (self));
    break;

  case PROP_COLOR_SCHEME:
    g_value_set_enum (value, hdy_style_manager_get_color_scheme (self));
    break;

  case PROP_SYSTEM_SUPPORTS_COLOR_SCHEMES:
    g_value_set_boolean (value, hdy_style_manager_get_system_supports_color_schemes (self));
    break;

  case PROP_DARK:
    g_value_set_boolean (value, hdy_style_manager_get_dark (self));
    break;

    case PROP_HIGH_CONTRAST:
    g_value_set_boolean (value, hdy_style_manager_get_high_contrast (self));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_style_manager_set_property (GObject      *object,
                                guint         prop_id,
                                const GValue *value,
                                GParamSpec   *pspec)
{
  HdyStyleManager *self = HDY_STYLE_MANAGER (object);

  switch (prop_id) {
  case PROP_DISPLAY:
    self->display = g_value_get_object (value);
    break;

  case PROP_COLOR_SCHEME:
    hdy_style_manager_set_color_scheme (self, g_value_get_enum (value));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_style_manager_class_init (HdyStyleManagerClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);

  object_class->constructed = hdy_style_manager_constructed;
  object_class->dispose = hdy_style_manager_dispose;
  object_class->get_property = hdy_style_manager_get_property;
  object_class->set_property = hdy_style_manager_set_property;

  /**
   * HdyStyleManager:display: (attributes org.gtk.Property.get=hdy_style_manager_get_display)
   *
   * The display the style manager is associated with.
   *
   * The display will be `NULL` for the style manager returned by
   * [func@StyleManager.get_default].
   *
   * Since: 1.6
   */
  props[PROP_DISPLAY] =
    g_param_spec_object ("display",
                         "Display",
                         "Display",
                         GDK_TYPE_DISPLAY,
                         G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY);

  /**
   * HdyStyleManager:color-scheme: (attributes org.gtk.Property.get=hdy_style_manager_get_color_scheme org.gtk.Property.set=hdy_style_manager_set_color_scheme)
   *
   * The requested application color scheme.
   *
   * The effective appearance will be decided based on the application color
   * scheme and the system preferred color scheme. The
   * [property@StyleManager:dark] property can be used to query the current
   * effective appearance.
   *
   * The `HDY_COLOR_SCHEME_PREFER_LIGHT` color scheme results in the application
   * using light appearance unless the system prefers dark colors. This is the
   * default value.
   *
   * The `HDY_COLOR_SCHEME_PREFER_DARK` color scheme results in the application
   * using dark appearance, but can still switch to the light appearance if the
   * system can prefers it, for example, when the high contrast preference is
   * enabled.
   *
   * The `HDY_COLOR_SCHEME_FORCE_LIGHT` and `HDY_COLOR_SCHEME_FORCE_DARK` values
   * ignore the system preference entirely, they are useful if the application
   * wants to match its UI to its content or to provide a separate color scheme
   * switcher.
   *
   * If a per-[class@Gdk.Display] style manager has its color scheme set to
   * `HDY_COLOR_SCHEME_DEFAULT`, it will inherit the color scheme from the
   * default style manager.
   *
   * For the default style manager, `HDY_COLOR_SCHEME_DEFAULT` is equivalent to
   * `HDY_COLOR_SCHEME_FORCE_LIGHT`.
   *
   * The [property@StyleManager:system-supports-color-schemes] property can be
   * used to check if the current environment provides a color scheme
   * dddpreference.
   *
   * Since: 1.6
   */
  props[PROP_COLOR_SCHEME] =
    g_param_spec_enum ("color-scheme",
                       _("Color Scheme"),
                       _("The current color scheme"),
                       HDY_TYPE_COLOR_SCHEME,
                       HDY_COLOR_SCHEME_DEFAULT,
                       G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyStyleManager:system-supports-color-schemes: (attributes org.gtk.Property.get=hdy_style_manager_get_system_supports_color_schemes)
   *
   * Whether the system supports color schemes.
   *
   * This property can be used to check if the current environment provides a
   * color scheme preference. For example, applications might want to show a
   * separate appearance switcher if it's set to `FALSE`.
   *
   * It's only set at startup and cannot change its value later.
   *
   * See [property@StyleManager:color-scheme].
   *
   * Since: 1.6
   */
  props[PROP_SYSTEM_SUPPORTS_COLOR_SCHEMES] =
    g_param_spec_boolean ("system-supports-color-schemes",
                          _("System supports color schemes"),
                          _("Whether the system supports color schemes"),
                          FALSE,
                          G_PARAM_READABLE);

  /**
   * HdyStyleManager:dark: (attributes org.gtk.Property.get=hdy_style_manager_get_dark)
   *
   * Whether the application is using dark appearance.
   *
   * This property can be used to query the current appearance, as requested via
   * [property@StyleManager:color-scheme].
   *
   * Since: 1.6
   */
  props[PROP_DARK] =
    g_param_spec_boolean ("dark",
                          _("Dark"),
                          _("Whether the application is using dark appearance"),
                          FALSE,
                          G_PARAM_READABLE);

  /**
   * HdyStyleManager:high-contrast: (attributes org.gtk.Property.get=hdy_style_manager_get_high_contrast)
   *
   * Whether the application is using high contrast appearance.
   *
   * This cannot be overridden by applications.
   *
   * Since: 1.6
   */
  props[PROP_HIGH_CONTRAST] =
    g_param_spec_boolean ("high-contrast",
                          _("High Contrast"),
                          _("Whether the application is using high contrast appearance"),
                          FALSE,
                          G_PARAM_READABLE);

  g_object_class_install_properties (object_class, LAST_PROP, props);
}

static void
hdy_style_manager_init (HdyStyleManager *self)
{
  self->color_scheme = HDY_COLOR_SCHEME_DEFAULT;
}

static void
hdy_style_manager_ensure (void)
{
  GdkDisplayManager *display_manager = gdk_display_manager_get ();
  g_autoptr (GSList) displays = NULL;
  GSList *l;

  if (display_style_managers)
    return;

  default_instance = g_object_new (HDY_TYPE_STYLE_MANAGER, NULL);
  display_style_managers = g_hash_table_new_full (g_direct_hash,
                                                  g_direct_equal,
                                                  NULL,
                                                  g_object_unref);

  displays = gdk_display_manager_list_displays (display_manager);

  for (l = displays; l; l = l->next)
    register_display (display_manager, l->data);

  g_signal_connect (display_manager,
                    "display-opened",
                    G_CALLBACK (register_display),
                    NULL);
}

/**
 * hdy_style_manager_get_default:
 *
 * Gets the default [class@StyleManager] instance.
 *
 * It manages all [class@Gdk.Display] instances unless the style manager for
 * that display has an override.
 *
 * See [func@StyleManager.get_for_display].
 *
 * Returns: (transfer none): the default style manager
 *
 * Since: 1.6
 */
HdyStyleManager *
hdy_style_manager_get_default (void)
{
  if (!default_instance)
    hdy_style_manager_ensure ();

  return default_instance;
}

/**
 * hdy_style_manager_get_for_display:
 * @display: a display
 *
 * Gets the [class@StyleManager] instance managing @display.
 *
 * It can be used to override styles for that specific display instead of the
 * whole application.
 *
 * Most applications should use [func@StyleManager.get_default] instead.
 *
 * Returns: (transfer none): the style manager for @display
 *
 * Since: 1.6
 */
HdyStyleManager *
hdy_style_manager_get_for_display (GdkDisplay *display)
{
  g_return_val_if_fail (GDK_IS_DISPLAY (display), NULL);

  if (!display_style_managers)
    hdy_style_manager_ensure ();

  g_return_val_if_fail (g_hash_table_contains (display_style_managers, display), NULL);

  return g_hash_table_lookup (display_style_managers, display);
}

/**
 * hdy_style_manager_get_display: (attributes org.gtk.Method.get_property=display)
 * @self: a style manager
 *
 * Gets the display the style manager is associated with.
 *
 * The display will be `NULL` for the style manager returned by
 * [func@StyleManager.get_default].
 *
 * Returns: (transfer none): (nullable): the display
 *
 * Since: 1.6
 */
GdkDisplay *
hdy_style_manager_get_display (HdyStyleManager *self)
{
  g_return_val_if_fail (HDY_IS_STYLE_MANAGER (self), NULL);

  return self->display;
}

/**
 * hdy_style_manager_get_color_scheme: (attributes org.gtk.Method.get_property=color-scheme)
 * @self: a style manager
 *
 * Gets the requested application color scheme.
 *
 * Returns: the color scheme
 *
 * Since: 1.6
 */
HdyColorScheme
hdy_style_manager_get_color_scheme (HdyStyleManager *self)
{
  g_return_val_if_fail (HDY_IS_STYLE_MANAGER (self), HDY_COLOR_SCHEME_DEFAULT);

  return self->color_scheme;
}

/**
 * hdy_style_manager_set_color_scheme: (attributes org.gtk.Method.set_property=color-scheme)
 * @self: a style manager
 * @color_scheme: the color scheme
 *
 * Sets the requested application color scheme.
 *
 * The effective appearance will be decided based on the application color
 * scheme and the system preferred color scheme. The
 * [property@StyleManager:dark] property can be used to query the current
 * effective appearance.
 *
 * Since: 1.6
 */
void
hdy_style_manager_set_color_scheme (HdyStyleManager *self,
                                    HdyColorScheme   color_scheme)
{
  g_return_if_fail (HDY_IS_STYLE_MANAGER (self));

  if (color_scheme == self->color_scheme)
    return;

  self->color_scheme = color_scheme;

  g_object_freeze_notify (G_OBJECT (self));

  update_dark (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_COLOR_SCHEME]);

  g_object_thaw_notify (G_OBJECT (self));

  if (!self->display) {
    GHashTableIter iter;
    HdyStyleManager *manager;

    g_hash_table_iter_init (&iter, display_style_managers);

    while (g_hash_table_iter_next (&iter, NULL, (gpointer) &manager))
      if (manager->color_scheme == HDY_COLOR_SCHEME_DEFAULT)
        update_dark (manager);
  }
}

/**
 * hdy_style_manager_get_system_supports_color_schemes: (attributes org.gtk.Method.get_property=system-supports-color-schemes)
 * @self: a style manager
 *
 * Gets whether the system supports color schemes.
 *
 * Returns: whether the system supports color schemes
 *
 * Since: 1.6
 */
gboolean
hdy_style_manager_get_system_supports_color_schemes (HdyStyleManager *self)
{
  g_return_val_if_fail (HDY_IS_STYLE_MANAGER (self), FALSE);

  return hdy_settings_has_color_scheme (self->settings);
}

/**
 * hdy_style_manager_get_dark: (attributes org.gtk.Method.get_property=dark)
 * @self: a style manager
 *
 * Gets whether the application is using dark appearance.
 *
 * Returns: whether the application is using dark appearance
 *
 * Since: 1.6
 */
gboolean
hdy_style_manager_get_high_contrast (HdyStyleManager *self)
{
  g_return_val_if_fail (HDY_IS_STYLE_MANAGER (self), FALSE);

  return hdy_settings_get_high_contrast (self->settings);
}

/**
 * hdy_style_manager_get_high_contrast: (attributes org.gtk.Method.get_property=high-contrast)
 * @self: a style manager
 *
 * Gets whether the application is using high contrast appearance.
 *
 * Returns: whether the application is using high contrast appearance
 *
 * Since: 1.6
 */
gboolean
hdy_style_manager_get_dark (HdyStyleManager *self)
{
  g_return_val_if_fail (HDY_IS_STYLE_MANAGER (self), FALSE);

  return self->dark;
}
