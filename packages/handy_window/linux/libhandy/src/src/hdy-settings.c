/*
 * Copyright (C) 2021 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#include "config.h"

#include "hdy-settings-private.h"

#include <gio/gio.h>
#include <gtk/gtk.h>

#define PORTAL_BUS_NAME "org.freedesktop.portal.Desktop"
#define PORTAL_OBJECT_PATH "/org/freedesktop/portal/desktop"
#define PORTAL_SETTINGS_INTERFACE "org.freedesktop.portal.Settings"

#define PORTAL_ERROR_NOT_FOUND "org.freedesktop.portal.Error.NotFound"

struct _HdySettings
{
  GObject parent_instance;

  GDBusProxy *settings_portal;
  GSettings *interface_settings;
  GSettings *a11y_settings;

  HdySystemColorScheme color_scheme;
  gboolean high_contrast;

  gboolean has_high_contrast;
  gboolean has_color_scheme;
  gboolean color_scheme_use_fdo_setting;
};

G_DEFINE_TYPE (HdySettings, hdy_settings, G_TYPE_OBJECT);

enum {
  PROP_0,
  PROP_COLOR_SCHEME,
  PROP_HIGH_CONTRAST,
  LAST_PROP,
};

static GParamSpec *props[LAST_PROP];

static HdySettings *default_instance;

static void
set_color_scheme (HdySettings          *self,
                  HdySystemColorScheme  color_scheme)
{
  if (color_scheme == self->color_scheme)
    return;

  self->color_scheme = color_scheme;

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_COLOR_SCHEME]);
}

static void
set_high_contrast (HdySettings *self,
                   gboolean     high_contrast)
{
  if (high_contrast == self->high_contrast)
    return;

  self->high_contrast = high_contrast;

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_HIGH_CONTRAST]);
}

/* Settings portal */

static gboolean
get_disable_portal (void)
{
  const char *disable_portal = g_getenv ("HDY_DISABLE_PORTAL");

  return disable_portal && disable_portal[0] == '1';
}

static gboolean
read_portal_setting (HdySettings  *self,
                     const char   *schema,
                     const char   *name,
                     const char   *type,
                     GVariant    **out)
{
  g_autoptr (GError) error = NULL;
  g_autoptr (GVariant) ret = NULL;
  g_autoptr (GVariant) child = NULL;
  g_autoptr (GVariant) child2 = NULL;
  g_autoptr (GVariantType) out_type = NULL;

  ret = g_dbus_proxy_call_sync (self->settings_portal,
                                "Read",
                                g_variant_new ("(ss)", schema, name),
                                G_DBUS_CALL_FLAGS_NONE,
                                G_MAXINT,
                                NULL,
                                &error);
  if (error) {
    if (error->domain == G_DBUS_ERROR &&
        error->code == G_DBUS_ERROR_SERVICE_UNKNOWN) {
      g_debug ("Portal not found: %s", error->message);

      return FALSE;
    }

    if (error->domain == G_DBUS_ERROR &&
        error->code == G_DBUS_ERROR_UNKNOWN_METHOD) {
      g_debug ("Portal doesn't provide settings: %s", error->message);

      return FALSE;
    }

    if (g_dbus_error_is_remote_error (error)) {
      g_autofree char *remote_error = g_dbus_error_get_remote_error (error);

      if (!g_strcmp0 (remote_error, PORTAL_ERROR_NOT_FOUND)) {
        g_debug ("Setting %s.%s of type %s not found", schema, name, type);

        return FALSE;
      }
    }

    g_critical ("Couldn't read the %s setting: %s", name, error->message);

    return FALSE;
  }

  g_variant_get (ret, "(v)", &child);
  g_variant_get (child, "v", &child2);

  out_type = g_variant_type_new (type);
  if (!g_variant_type_equal (g_variant_get_type (child2), out_type)) {
    g_critical ("Invalid type for %s.%s: expected %s, got %s",
                schema, name, type, g_variant_get_type_string (child2));

    return FALSE;
  }

  *out = g_steal_pointer (&child2);

  return TRUE;
}

static HdySystemColorScheme
get_fdo_color_scheme (GVariant *variant)
{
  guint32 color_scheme = g_variant_get_uint32 (variant);

  if (color_scheme > HDY_SYSTEM_COLOR_SCHEME_PREFER_LIGHT) {
    g_warning ("Invalid color scheme: %u", color_scheme);

    color_scheme = HDY_SYSTEM_COLOR_SCHEME_DEFAULT;
  }

  return color_scheme;
}

static HdySystemColorScheme
get_gnome_color_scheme (GVariant *variant)
{
  const char *str = g_variant_get_string (variant, NULL);

  if (!g_strcmp0 (str, "default"))
    return HDY_SYSTEM_COLOR_SCHEME_DEFAULT;

  if (!g_strcmp0 (str, "prefer-dark"))
    return HDY_SYSTEM_COLOR_SCHEME_PREFER_DARK;

  if (!g_strcmp0 (str, "prefer-light"))
    return HDY_SYSTEM_COLOR_SCHEME_PREFER_LIGHT;

  g_warning ("Invalid color scheme: %s", str);

  return HDY_SYSTEM_COLOR_SCHEME_DEFAULT;
}

static void
settings_portal_changed_cb (GDBusProxy  *proxy,
                            const char  *sender_name,
                            const char  *signal_name,
                            GVariant    *parameters,
                            HdySettings *self)
{
  const char *namespace;
  const char *name;
  g_autoptr (GVariant) value = NULL;

  if (g_strcmp0 (signal_name, "SettingChanged"))
    return;

  g_variant_get (parameters, "(&s&sv)", &namespace, &name, &value);

  if (!g_strcmp0 (namespace, "org.freedesktop.appearance") &&
      !g_strcmp0 (name, "color-scheme") &&
      self->color_scheme_use_fdo_setting) {
    set_color_scheme (self, get_fdo_color_scheme (value));

    return;
  }

  if (!g_strcmp0 (namespace, "org.gnome.desktop.interface") &&
      !g_strcmp0 (name, "color-scheme") &&
      !self->color_scheme_use_fdo_setting) {
    set_color_scheme (self, get_gnome_color_scheme (value));

    return;
  }

  if (!g_strcmp0 (namespace, "org.gnome.desktop.a11y.interface") &&
      !g_strcmp0 (name, "high-contrast")) {
    set_high_contrast (self, g_variant_get_boolean (value));

    return;
  }
}

static void
init_portal (HdySettings *self)
{
  g_autoptr (GError) error = NULL;
  g_autoptr (GVariant) color_scheme_variant = NULL;
  g_autoptr (GVariant) high_contrast_variant = NULL;

  if (get_disable_portal ())
    return;

  self->settings_portal = g_dbus_proxy_new_for_bus_sync (G_BUS_TYPE_SESSION,
                                                         G_DBUS_PROXY_FLAGS_NONE,
                                                         NULL,
                                                         PORTAL_BUS_NAME,
                                                         PORTAL_OBJECT_PATH,
                                                         PORTAL_SETTINGS_INTERFACE,
                                                         NULL,
                                                         &error);
  if (error) {
    g_debug ("Settings portal not found: %s", error->message);

    return;
  }

  if (read_portal_setting (self, "org.freedesktop.appearance",
                           "color-scheme", "u", &color_scheme_variant)) {
    self->has_color_scheme = TRUE;
    self->color_scheme_use_fdo_setting = TRUE;
    self->color_scheme = get_fdo_color_scheme (color_scheme_variant);
  }

  if (!self->has_color_scheme &&
      read_portal_setting (self, "org.gnome.desktop.interface",
                           "color-scheme", "s", &color_scheme_variant)) {
    self->has_color_scheme = TRUE;
    self->color_scheme = get_gnome_color_scheme (color_scheme_variant);
  }

  if (read_portal_setting (self, "org.gnome.desktop.a11y.interface",
                           "high-contrast", "b", &high_contrast_variant)) {
    self->has_high_contrast = TRUE;
    self->high_contrast = g_variant_get_boolean (high_contrast_variant);
  }

  if (!self->has_color_scheme && !self->has_high_contrast)
    return;

  g_signal_connect (self->settings_portal, "g-signal",
                    G_CALLBACK (settings_portal_changed_cb), self);
}

/* GSettings */

static gboolean
is_running_in_flatpak (void)
{
  return g_file_test ("/.flatpak-info", G_FILE_TEST_EXISTS);
}

static void
gsettings_color_scheme_changed_cb (HdySettings *self)
{
  set_color_scheme (self, g_settings_get_enum (self->interface_settings, "color-scheme"));
}

static void
gsettings_high_contrast_changed_cb (HdySettings *self)
{
  set_high_contrast (self, g_settings_get_boolean (self->a11y_settings, "high-contrast"));
}

static void
init_gsettings (HdySettings *self)
{
  GSettingsSchemaSource *source;
  g_autoptr (GSettingsSchema) schema = NULL;
  g_autoptr (GSettingsSchema) a11y_schema = NULL;

  /* While we can access gsettings in flatpak, we can't do anything useful with
   * them as they aren't propagated from the system. */
  if (is_running_in_flatpak ())
    return;

  source = g_settings_schema_source_get_default ();

  schema = g_settings_schema_source_lookup (source, "org.gnome.desktop.interface", TRUE);
  if (schema &&
      !self->has_color_scheme &&
      g_settings_schema_has_key (schema, "color-scheme")) {
    self->has_color_scheme = TRUE;
    self->interface_settings = g_settings_new ("org.gnome.desktop.interface");
    self->color_scheme = g_settings_get_enum (self->interface_settings, "color-scheme");

    g_signal_connect_swapped (self->interface_settings,
                              "changed::color-scheme",
                              G_CALLBACK (gsettings_color_scheme_changed_cb),
                              self);
  }

  a11y_schema = g_settings_schema_source_lookup (source, "org.gnome.desktop.a11y.interface", TRUE);
  if (a11y_schema &&
      !self->has_high_contrast &&
      g_settings_schema_has_key (a11y_schema, "high-contrast")) {
    self->has_high_contrast = TRUE;
    self->a11y_settings = g_settings_new ("org.gnome.desktop.a11y.interface");
    self->high_contrast = g_settings_get_boolean (self->a11y_settings, "high-contrast");

    g_signal_connect_swapped (self->a11y_settings,
                              "changed::high-contrast",
                              G_CALLBACK (gsettings_high_contrast_changed_cb),
                              self);
  }
}

/* Legacy */

static gboolean
is_theme_high_contrast (void)
{
  g_autofree gchar *icon_theme_name = NULL;

  /* We're using icon theme here as we control gtk-theme-name and it
   * interferes with the notifications. */
  g_object_get (gtk_settings_get_default (),
                "gtk-icon-theme-name", &icon_theme_name,
                NULL);

  return !g_strcmp0 (icon_theme_name, "HighContrast") ||
         !g_strcmp0 (icon_theme_name, "HighContrastInverse");
}

static void
theme_name_changed_cb (HdySettings *self)
{
  set_high_contrast (self, is_theme_high_contrast ());
}

static void
init_legacy (HdySettings *self)
{
  GdkDisplay *display = gdk_display_get_default ();
  GdkScreen *screen;

  if (!display)
    return;

  screen = gdk_display_get_default_screen (display);

  if (!screen)
    return;

  self->has_high_contrast = TRUE;
  self->high_contrast = is_theme_high_contrast ();

  g_signal_connect_swapped (gtk_settings_get_default (),
                            "notify::gtk-icon-theme-name",
                            G_CALLBACK (theme_name_changed_cb),
                            self);
}

static void
hdy_settings_constructed (GObject *object)
{
  HdySettings *self = HDY_SETTINGS (object);

  G_OBJECT_CLASS (hdy_settings_parent_class)->constructed (object);

  g_debug ("Trying to initialize portal");

  init_portal (self);

  if (!self->has_color_scheme || !self->has_high_contrast)
    init_gsettings (self);

  if (!self->has_high_contrast)
    init_legacy (self);
}

static void
hdy_settings_dispose (GObject *object)
{
  HdySettings *self = HDY_SETTINGS (object);

  g_clear_object (&self->settings_portal);
  g_clear_object (&self->interface_settings);
  g_clear_object (&self->a11y_settings);

  G_OBJECT_CLASS (hdy_settings_parent_class)->dispose (object);
}

static void
hdy_settings_get_property (GObject    *object,
                           guint       prop_id,
                           GValue     *value,
                           GParamSpec *pspec)
{
  HdySettings *self = HDY_SETTINGS (object);

  switch (prop_id) {
  case PROP_COLOR_SCHEME:
    g_value_set_enum (value, hdy_settings_get_color_scheme (self));
    break;

  case PROP_HIGH_CONTRAST:
    g_value_set_boolean (value, hdy_settings_get_high_contrast (self));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_settings_class_init (HdySettingsClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);

  object_class->constructed = hdy_settings_constructed;
  object_class->dispose = hdy_settings_dispose;
  object_class->get_property = hdy_settings_get_property;

  props[PROP_COLOR_SCHEME] =
    g_param_spec_enum ("color-scheme",
                       "Color Scheme",
                       "Color Scheme",
                       HDY_TYPE_SYSTEM_COLOR_SCHEME,
                       HDY_SYSTEM_COLOR_SCHEME_DEFAULT,
                       G_PARAM_READABLE);

  props[PROP_HIGH_CONTRAST] =
    g_param_spec_boolean ("high-contrast",
                          "High Contrast",
                          "High Contrast",
                          FALSE,
                          G_PARAM_READABLE);

  g_object_class_install_properties (object_class, LAST_PROP, props);
}

static void
hdy_settings_init (HdySettings *self)
{
}

HdySettings *
hdy_settings_get_default (void)
{
  if (!default_instance)
    default_instance = g_object_new (HDY_TYPE_SETTINGS, NULL);

  return default_instance;
}

gboolean
hdy_settings_has_color_scheme (HdySettings *self)
{
  g_return_val_if_fail (HDY_IS_SETTINGS (self), FALSE);

  return self->has_color_scheme;
}

HdySystemColorScheme
hdy_settings_get_color_scheme (HdySettings *self)
{
  g_return_val_if_fail (HDY_IS_SETTINGS (self), HDY_SYSTEM_COLOR_SCHEME_DEFAULT);

  return self->color_scheme;
}

gboolean
hdy_settings_get_high_contrast (HdySettings *self)
{
  g_return_val_if_fail (HDY_IS_SETTINGS (self), FALSE);

  return self->high_contrast;
}
