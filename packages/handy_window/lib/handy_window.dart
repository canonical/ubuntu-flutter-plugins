/// # Handy Window
///
/// This package enhances the looks of Flutter applications on Linux by providing
/// modern-looking [Handy](https://gitlab.gnome.org/GNOME/libhandy) windows with
/// rounded bottom corners.
///
/// | Handy window | Flutter window |
/// |---|---|
/// | <image src="https://raw.githubusercontent.com/canonical/ubuntu-flutter-plugins/main/packages/handy_window/images/handy-window.png" width="430"/> | <image src="https://raw.githubusercontent.com/canonical/ubuntu-flutter-plugins/main/packages/handy_window/images/flutter-window.png" width="400"/> |
///
/// ## Usage
///
/// Add the dependency to `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   handy_window:
/// ```
///
/// Modify `linux/my_application.cc` to register plugins before showing the Flutter
/// window and view:
///
/// ```diff
/// diff --git a/linux/my_application.cc b/linux/my_application.cc
/// index fa74baa..3133755 100644
/// --- a/linux/my_application.cc
/// +++ b/linux/my_application.cc
/// @@ -48,17 +48,17 @@ static void my_application_activate(GApplication* application) {
///    }
///
///    gtk_window_set_default_size(window, 1280, 720);
/// -  gtk_widget_show(GTK_WIDGET(window));
///
///    g_autoptr(FlDartProject) project = fl_dart_project_new();
///    fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);
///
///    FlView* view = fl_view_new(project);
/// -  gtk_widget_show(GTK_WIDGET(view));
///    gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));
///
///    fl_register_plugins(FL_PLUGIN_REGISTRY(view));
///
/// +  gtk_widget_show(GTK_WIDGET(window));
/// +  gtk_widget_show(GTK_WIDGET(view));
///    gtk_widget_grab_focus(GTK_WIDGET(view));
///  }
/// ```
library handy_window;
