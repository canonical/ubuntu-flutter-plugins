#ifndef _HANDY_WINDOW_H_
#define _HANDY_WINDOW_H_

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define HANDY_WINDOW_EXPORT __attribute__((visibility("default")))

// Creates a new application window.
//
// The window is HdyApplicationWindow if available, or GtkApplicationWindow
// otherwise.
HANDY_WINDOW_EXPORT GtkWindow* handy_window_new(GtkApplication* application);

// Returns the window title.
HANDY_WINDOW_EXPORT const gchar* handy_window_get_title(GtkWindow* window);

// Sets the window title.
HANDY_WINDOW_EXPORT void handy_window_set_title(GtkWindow* window,
                                                const gchar* title);

// Returns true if the window is closable, or false otherwise.
HANDY_WINDOW_EXPORT gboolean handy_window_is_closable(GtkWindow* window);

// Sets whether the window is closable.
HANDY_WINDOW_EXPORT void handy_window_set_closable(GtkWindow* window,
                                                   gboolean closable);

// Returns the view (FlView).
HANDY_WINDOW_EXPORT GtkWidget* handy_window_get_view(GtkWindow* window);

// Sets the view (FlView).
HANDY_WINDOW_EXPORT void handy_window_set_view(GtkWindow* window,
                                               GtkWidget* view);

G_END_DECLS

#endif  // _HANDY_WINDOW_H_
