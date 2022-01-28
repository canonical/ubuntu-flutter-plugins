#include "include/handy_window/handy_window_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include "include/handy_window/handy_window.h"

#define HANDY_WINDOW_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), handy_window_plugin_get_type(), \
                              HandyWindowPlugin))

struct _HandyWindowPlugin {
  GObject parent_instance;
  gulong delete_event_handler;
  gboolean has_event_channel;
  FlPluginRegistrar* registrar;
  FlMethodChannel* method_channel;
  FlMethodChannel* event_channel;
};

G_DEFINE_TYPE(HandyWindowPlugin, handy_window_plugin, g_object_get_type())

static GdkWindowState get_window_state(GtkWidget* widget) {
  GdkWindow* window = gtk_widget_get_window(widget);
  return gdk_window_get_state(window);
}

static gboolean is_window_minimized(GtkWindow* window) {
  return get_window_state(GTK_WIDGET(window)) & GDK_WINDOW_STATE_ICONIFIED;
}

static gboolean is_window_fullscreen(GtkWindow* window) {
  return get_window_state(GTK_WIDGET(window)) & GDK_WINDOW_STATE_FULLSCREEN;
}

// Called when a method call is received from Flutter.
static void handy_window_plugin_handle_method_call(HandyWindowPlugin* self,
                                                   FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  GtkWidget* window = gtk_widget_get_toplevel(GTK_WIDGET(view));

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "getWindowTitle") == 0) {
    const gchar* title = handy_window_get_title(GTK_WINDOW(window));
    g_autoptr(FlValue) value = fl_value_new_string(title);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "setWindowTitle") == 0) {
    const gchar* title = fl_value_get_string(args);
    handy_window_set_title(GTK_WINDOW(window), title);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "isWindowClosable") == 0) {
    gboolean closable = handy_window_is_closable(GTK_WINDOW(window));
    g_autoptr(FlValue) value = fl_value_new_bool(closable);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "setWindowClosable") == 0) {
    gboolean closable = fl_value_get_bool(args);
    handy_window_set_closable(GTK_WINDOW(window), closable);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "isWindowVisible") == 0) {
    gboolean visible = gtk_widget_is_visible(window);
    g_autoptr(FlValue) value = fl_value_new_bool(visible);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "setWindowVisible") == 0) {
    gboolean visible = fl_value_get_bool(args);
    gtk_widget_set_visible(window, visible);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "isWindowMinimized") == 0) {
    gboolean minimized = is_window_minimized(GTK_WINDOW(window));
    g_autoptr(FlValue) value = fl_value_new_bool(minimized);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "minimizeWindow") == 0) {
    gboolean minimize = fl_value_get_bool(args);
    if (minimize) {
      gtk_window_iconify(GTK_WINDOW(window));
    } else {
      gtk_window_deiconify(GTK_WINDOW(window));
    }
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "isWindowMaximized") == 0) {
    gboolean maximized = gtk_window_is_maximized(GTK_WINDOW(window));
    g_autoptr(FlValue) value = fl_value_new_bool(maximized);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "maximizeWindow") == 0) {
    gboolean maximize = fl_value_get_bool(args);
    if (maximize) {
      gtk_window_maximize(GTK_WINDOW(window));
    } else {
      gtk_window_unmaximize(GTK_WINDOW(window));
    }
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "isWindowFullscreen") == 0) {
    gboolean fullscreen = is_window_fullscreen(GTK_WINDOW(window));
    g_autoptr(FlValue) value = fl_value_new_bool(fullscreen);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "setWindowFullscreen") == 0) {
    gboolean fullscreen = fl_value_get_bool(args);
    if (fullscreen) {
      gtk_window_fullscreen(GTK_WINDOW(window));
    } else {
      gtk_window_unfullscreen(GTK_WINDOW(window));
    }
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "getWindowSize") == 0) {
    gint width = 0, height = 0;
    gtk_window_get_size(GTK_WINDOW(window), &width, &height);
    g_autoptr(FlValue) size = fl_value_new_map();
    fl_value_set_string_take(size, "width", fl_value_new_int(width));
    fl_value_set_string_take(size, "height", fl_value_new_int(height));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(size));
  } else if (strcmp(method, "resizeWindow") == 0) {
    FlValue* width = fl_value_lookup_string(args, "width");
    FlValue* height = fl_value_lookup_string(args, "height");
    gtk_window_resize(GTK_WINDOW(window), fl_value_get_int(width),
                      fl_value_get_int(height));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "onWindowResized") == 0) {
    self->has_event_channel = TRUE;
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "closeWindow") == 0) {
    gtk_window_close(GTK_WINDOW(window));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "onWindowClosing") == 0) {
    self->has_event_channel = TRUE;
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void handy_window_plugin_dispose(GObject* object) {
  HandyWindowPlugin* self = HANDY_WINDOW_PLUGIN(object);
  g_object_unref(self->registrar);
  g_object_unref(self->method_channel);
  g_object_unref(self->event_channel);
  G_OBJECT_CLASS(handy_window_plugin_parent_class)->dispose(object);
}

static void handy_window_plugin_class_init(HandyWindowPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = handy_window_plugin_dispose;
}

static void handy_window_plugin_init(HandyWindowPlugin* self) {
  self->delete_event_handler = 0;
  self->has_event_channel = FALSE;
}

static void on_method_call(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  HandyWindowPlugin* plugin = HANDY_WINDOW_PLUGIN(user_data);
  handy_window_plugin_handle_method_call(plugin, method_call);
}

static void on_delete_response(GObject* object, GAsyncResult* result,
                               gpointer user_data) {
  g_autoptr(GError) error = NULL;
  g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(
      FL_METHOD_CHANNEL(object), result, &error);
  if (!response) {
    g_warning("onWindowClosing response: %s", error->message);
    return;
  }

  FlValue* value = fl_method_response_get_result(response, &error);
  if (value && fl_value_get_type(value) == FL_VALUE_TYPE_BOOL &&
      !fl_value_get_bool(value)) {
    return;
  }

  HandyWindowPlugin* plugin = HANDY_WINDOW_PLUGIN(user_data);
  FlView* view = fl_plugin_registrar_get_view(plugin->registrar);
  GtkWidget* window = gtk_widget_get_toplevel(GTK_WIDGET(view));

  g_signal_handler_disconnect(G_OBJECT(window), plugin->delete_event_handler);
  gtk_window_close(GTK_WINDOW(window));
}

static gboolean on_delete_event(GtkWidget* window, GdkEvent* /*event*/,
                                gpointer user_data) {
  HandyWindowPlugin* plugin = HANDY_WINDOW_PLUGIN(user_data);
  if (!plugin->has_event_channel) {
    return FALSE;
  }
  if (handy_window_is_closable(GTK_WINDOW(window))) {
    fl_method_channel_invoke_method(plugin->event_channel, "onWindowClosing",
                                    nullptr, nullptr, on_delete_response,
                                    plugin);
  }
  return TRUE;
}

static void on_size_allocate(GtkWidget* widget, GtkAllocation* allocation,
                             gpointer user_data) {
  HandyWindowPlugin* plugin = HANDY_WINDOW_PLUGIN(user_data);
  if (!plugin->has_event_channel) {
    return;
  }

  gint width = 0;
  gint height = 0;
  gtk_window_get_size(GTK_WINDOW(widget), &width, &height);

  g_autoptr(FlValue) size = fl_value_new_map();
  fl_value_set_string_take(size, "width", fl_value_new_int(width));
  fl_value_set_string_take(size, "height", fl_value_new_int(height));
  fl_method_channel_invoke_method(plugin->event_channel, "onWindowResized",
                                  size, nullptr, nullptr, plugin);
}

void handy_window_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  HandyWindowPlugin* plugin = HANDY_WINDOW_PLUGIN(
      g_object_new(handy_window_plugin_get_type(), nullptr));
  plugin->registrar = g_object_ref(registrar);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);

  g_autoptr(FlMethodChannel) method_channel =
      fl_method_channel_new(messenger, "handy_window", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(method_channel, on_method_call,
                                            plugin, g_object_unref);
  plugin->method_channel = g_object_ref(method_channel);

  g_autoptr(FlMethodChannel) event_channel = fl_method_channel_new(
      messenger, "handy_window/events", FL_METHOD_CODEC(codec));
  plugin->event_channel = g_object_ref(event_channel);

  FlView* view = fl_plugin_registrar_get_view(registrar);
  GtkWidget* window = gtk_widget_get_toplevel(GTK_WIDGET(view));

  plugin->delete_event_handler = g_signal_connect(
      G_OBJECT(window), "delete-event", G_CALLBACK(on_delete_event), plugin);

  g_signal_connect(G_OBJECT(window), "size-allocate",
                   G_CALLBACK(on_size_allocate), plugin);
}
