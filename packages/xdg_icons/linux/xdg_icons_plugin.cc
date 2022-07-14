#include "include/xdg_icons/xdg_icons_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define XDG_ICONS_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), xdg_icons_plugin_get_type(), \
                              XdgIconsPlugin))

struct _XdgIconsPlugin {
  GObject parent_instance;
  FlEventChannel* event_channel;
  gulong theme_changed_id;
};

G_DEFINE_TYPE(XdgIconsPlugin, xdg_icons_plugin, g_object_get_type())

static FlValue* lookup_icon(FlValue* args) {
  FlValue* name = fl_value_lookup_string(args, "name");
  FlValue* size = fl_value_lookup_string(args, "size");
  FlValue* scale = fl_value_lookup_string(args, "scale");
  FlValue* theme = fl_value_lookup_string(args, "theme");

  g_autoptr(GtkIconTheme) icon_theme = gtk_icon_theme_get_default();
  if (theme != nullptr) {
    icon_theme = gtk_icon_theme_new();
    gtk_icon_theme_set_custom_theme(icon_theme, fl_value_get_string(theme));
  } else {
    g_object_ref(icon_theme);
  }

  g_autoptr(GtkIconInfo) icon_info =
      scale != nullptr
          ? gtk_icon_theme_lookup_icon_for_scale(
                icon_theme, fl_value_get_string(name), fl_value_get_int(size),
                fl_value_get_int(scale), GTK_ICON_LOOKUP_USE_BUILTIN)
          : gtk_icon_theme_lookup_icon(icon_theme, fl_value_get_string(name),
                                       fl_value_get_int(size),
                                       GTK_ICON_LOOKUP_USE_BUILTIN);

  if (icon_info == nullptr) {
    return nullptr;
  }

  FlValue* result = fl_value_new_map();
  fl_value_set_string_take(
      result, "baseScale",
      fl_value_new_int(gtk_icon_info_get_base_scale(icon_info)));
  fl_value_set_string_take(
      result, "baseSize",
      fl_value_new_int(gtk_icon_info_get_base_size(icon_info)));
  fl_value_set_string_take(
      result, "fileName",
      fl_value_new_string(gtk_icon_info_get_filename(icon_info)));
  fl_value_set_string_take(
      result, "isSymbolic",
      fl_value_new_bool(gtk_icon_info_is_symbolic(icon_info)));
  g_autoptr(GBytes) bytes =
      g_resources_lookup_data(gtk_icon_info_get_filename(icon_info),
                              G_RESOURCE_LOOKUP_FLAGS_NONE, nullptr);
  if (bytes != nullptr) {
    gsize size = 0;
    gconstpointer data = g_bytes_get_data(bytes, &size);
    fl_value_set_string_take(
        result, "data",
        fl_value_new_uint8_list(reinterpret_cast<const uint8_t*>(data), size));
  }
  return result;
}

// Called when a method call is received from Flutter.
static void xdg_icons_plugin_handle_method_call(XdgIconsPlugin* self,
                                                FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "lookupIcon") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    g_autoptr(FlValue) icon = lookup_icon(args);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(icon));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void xdg_icons_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(xdg_icons_plugin_parent_class)->dispose(object);
}

static void xdg_icons_plugin_class_init(XdgIconsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = xdg_icons_plugin_dispose;
}

static void xdg_icons_plugin_init(XdgIconsPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  XdgIconsPlugin* plugin = XDG_ICONS_PLUGIN(user_data);
  xdg_icons_plugin_handle_method_call(plugin, method_call);
}

static void icon_theme_changed_cb(GtkIconTheme* theme, gpointer user_data) {
  FlEventChannel* channel = FL_EVENT_CHANNEL(user_data);
  g_autoptr(FlValue) event = fl_value_new_null();
  fl_event_channel_send(channel, event, nullptr, nullptr);
}

static FlMethodErrorResponse* listen_events_cb(FlEventChannel* channel,
                                               FlValue* args,
                                               gpointer user_data) {
  XdgIconsPlugin* plugin = XDG_ICONS_PLUGIN(user_data);
  if (plugin->theme_changed_id == 0) {
    plugin->theme_changed_id =
        g_signal_connect(gtk_icon_theme_get_default(), "changed",
                         G_CALLBACK(icon_theme_changed_cb), channel);
  }
  return nullptr;
}

static FlMethodErrorResponse* cancel_events_cb(FlEventChannel* channel,
                                               FlValue* args,
                                               gpointer user_data) {
  XdgIconsPlugin* plugin = XDG_ICONS_PLUGIN(user_data);
  if (plugin->theme_changed_id != 0) {
    g_signal_handler_disconnect(gtk_icon_theme_get_default(),
                                plugin->theme_changed_id);
    plugin->theme_changed_id = 0;
  }
  return nullptr;
}

void xdg_icons_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  XdgIconsPlugin* plugin =
      XDG_ICONS_PLUGIN(g_object_new(xdg_icons_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);

  g_autoptr(FlMethodChannel) method_channel =
      fl_method_channel_new(messenger, "xdg_icons", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      method_channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_autoptr(FlEventChannel) event_channel = fl_event_channel_new(
      messenger, "xdg_icons/events", FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(event_channel, listen_events_cb,
                                       cancel_events_cb, g_object_ref(plugin),
                                       g_object_unref);
}
