/*
 * Copyright (C) 2020 Alexander Mikhaylenko <alexm@gnome.org>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "config.h"

#include "hdy-window.h"
#include "hdy-window-mixin-private.h"

/**
 * HdyWindow:
 *
 * A freeform window.
 *
 * The `HdyWindow` widget is a subclass of [class@Gtk.Window] which has no
 * titlebar area and provides rounded corners on all sides, ensuring they can
 * never be overlapped by the content. This makes it safe to use headerbars in
 * the content area as follows:
 *
 * ```xml
 * <object class="HdyWindow"/>
 *   <child>
 *     <object class="GtkBox">
 *       <property name="visible">True</property>
 *       <property name="orientation">vertical</property>
 *       <child>
 *         <object class="HdyHeaderBar">
 *           <property name="visible">True</property>
 *           <property name="show-close-button">True</property>
 *         </object>
 *       </child>
 *       <child>
 *         <!-- ... -->
 *       </child>
 *     </object>
 *   </child>
 * </object>
 * ```
 *
 * It's recommended to use [class@HeaderBar] with `HdyWindow`, as unlike
 * [class@Gtk.HeaderBar] it remains draggable inside the window. Otherwise,
 * [class@WindowHandle] can be used.
 *
 * `HdyWindow` allows to easily implement titlebar autohiding by putting the
 * headerbar inside a [class@Gtk.Revealer], and to show titlebar above content
 * by putting it into a [class@Gtk.Overlay] instead of [class@Gtk.Box].
 *
 * If the window has a [class@Gtk.GLArea], it may bring a slight performance
 * regression when the window is not fullscreen, tiled or maximized.
 *
 * Using [method@Gtk.Window.get_titlebar] and [method@Gtk.Window.set_titlebar]
 * is not supported and will result in a crash.
 *
 * ## CSS nodes
 *
 * `HdyWindow` has a main CSS node with the name `window` and style classes
 * `.background`, `.csd` and `.unified`.
 *
 * The `.solid-csd` style class on the main node is used for client-side
 * decorations without invisible borders.
 *
 * `HdyWindow` also represents window states with the following style classes on
 * the main node: `.tiled`, `.maximized`, `.fullscreen`.
 *
 * It contains the subnodes decoration for window shadow and/or border,
 * decoration-overlay for the sheen on top of the window, `widget.titlebar`, and
 * deck, which contains the child inside the window.
 *
 * Since: 1.0
 */

typedef struct
{
  HdyWindowMixin *mixin;
} HdyWindowPrivate;

static void hdy_window_buildable_init (GtkBuildableIface *iface);

G_DEFINE_TYPE_WITH_CODE (HdyWindow, hdy_window, GTK_TYPE_WINDOW,
                         G_ADD_PRIVATE (HdyWindow)
                         G_IMPLEMENT_INTERFACE (GTK_TYPE_BUILDABLE, hdy_window_buildable_init))

#define HDY_GET_WINDOW_MIXIN(obj) (((HdyWindowPrivate *) hdy_window_get_instance_private (HDY_WINDOW (obj)))->mixin)

static void
hdy_window_add (GtkContainer *container,
                GtkWidget    *widget)
{
  hdy_window_mixin_add (HDY_GET_WINDOW_MIXIN (container), widget);
}

static void
hdy_window_remove (GtkContainer *container,
                   GtkWidget    *widget)
{
  hdy_window_mixin_remove (HDY_GET_WINDOW_MIXIN (container), widget);
}

static void
hdy_window_forall (GtkContainer *container,
                   gboolean      include_internals,
                   GtkCallback   callback,
                   gpointer      callback_data)
{
  hdy_window_mixin_forall (HDY_GET_WINDOW_MIXIN (container),
                           include_internals,
                           callback,
                           callback_data);
}

static gboolean
hdy_window_draw (GtkWidget *widget,
                 cairo_t   *cr)
{
  return hdy_window_mixin_draw (HDY_GET_WINDOW_MIXIN (widget), cr);
}

static void
hdy_window_destroy (GtkWidget *widget)
{
  hdy_window_mixin_destroy (HDY_GET_WINDOW_MIXIN (widget));
}

static void
hdy_window_finalize (GObject *object)
{
  HdyWindow *self = (HdyWindow *)object;
  HdyWindowPrivate *priv = hdy_window_get_instance_private (self);

  g_clear_object (&priv->mixin);

  G_OBJECT_CLASS (hdy_window_parent_class)->finalize (object);
}

static void
hdy_window_class_init (HdyWindowClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
  GtkContainerClass *container_class = GTK_CONTAINER_CLASS (klass);

  object_class->finalize = hdy_window_finalize;
  widget_class->draw = hdy_window_draw;
  widget_class->destroy = hdy_window_destroy;
  container_class->add = hdy_window_add;
  container_class->remove = hdy_window_remove;
  container_class->forall = hdy_window_forall;
}

static void
hdy_window_init (HdyWindow *self)
{
  HdyWindowPrivate *priv = hdy_window_get_instance_private (self);

  priv->mixin = hdy_window_mixin_new (GTK_WINDOW (self),
                                      GTK_WINDOW_CLASS (hdy_window_parent_class));
}

static void
hdy_window_buildable_add_child (GtkBuildable *buildable,
                                GtkBuilder   *builder,
                                GObject      *child,
                                const gchar  *type)
{
  hdy_window_mixin_buildable_add_child (HDY_GET_WINDOW_MIXIN (buildable),
                                        builder,
                                        child,
                                        type);
}

static void
hdy_window_buildable_init (GtkBuildableIface *iface)
{
  iface->add_child = hdy_window_buildable_add_child;
}

/**
 * hdy_window_new:
 *
 * Creates a new `HdyWindow`.
 *
 * Returns: the newly created `HdyWindow`
 *
 * Since: 1.0
 */
GtkWidget *
hdy_window_new (void)
{
  return g_object_new (HDY_TYPE_WINDOW,
                       "type", GTK_WINDOW_TOPLEVEL,
                       NULL);
}
