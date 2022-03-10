/*
 * Copyright (C) 2018 Purism SPC
 * Copyright (C) 2019 Alexander Mikhaylenko <exalm7659@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "config.h"
#include <glib/gi18n-lib.h>

#include "hdy-leaflet.h"
#include "hdy-stackable-box-private.h"
#include "hdy-swipeable.h"

/**
 * HdyLeaflet:
 *
 * An adaptive container acting like a box or a stack.
 *
 * The `HdyLeaflet` widget can display its children like a [class@Gtk.Box] does
 * or like a [class@Gtk.Stack] does, adapting to size changes by switching
 * between the two modes.
 *
 * When there is enough space the children are displayed side by side, otherwise
 * only one is displayed and the leaflet is said to be “folded”. The threshold
 * is dictated by the preferred minimum sizes of the children. When a leaflet is
 * folded, the children can be navigated using swipe gestures.
 *
 * The “over” and “under” transition types stack the children one on top of the
 * other, while the “slide” transition puts the children side by side. While
 * navigating to a child on the side or below can be performed by swiping the
 * current child away, navigating to an upper child requires dragging it from
 * the edge where it resides. This doesn't affect non-dragging swipes.
 *
 * The “over” and “under” transitions can draw their shadow on top of the
 * window's transparent areas, like the rounded corners. This is a side-effect
 * of allowing shadows to be drawn on top of OpenGL areas. It can be mitigated
 * by using [class@Window] or [class@ApplicationWindow] as they will crop
 * anything drawn beyond the rounded corners.
 *
 * The child property `navigatable` can be set on `HdyLeaflet` children to
 * determine whether they can be navigated to when folded. If `FALSE`, the child
 * will be ignored by [method@Leaflet.get_adjacent_child],
 * [method@Leaflet.navigate], and swipe gestures. This can be used used to
 * prevent switching to widgets like separators.
 *
 * ## CSS nodes
 *
 * `HdyLeaflet` has a single CSS node with name `leaflet`. The node will get the
 * style classes `.folded` when it is folded, `.unfolded` when it's not, or none
 * if it didn't compute its fold yet.
 *
 * Since: 1.0
 */

/**
 * HdyLeafletTransitionType:
 * @HDY_LEAFLET_TRANSITION_TYPE_OVER: Cover the old page or uncover the new
 *   page, sliding from or towards the end according to orientation, text
 *   direction and children order
 * @HDY_LEAFLET_TRANSITION_TYPE_UNDER: Uncover the new page or cover the old
 *   page, sliding from or towards the start according to orientation, text
 *   direction and children order
 * @HDY_LEAFLET_TRANSITION_TYPE_SLIDE: Slide from left, right, up or down
 *   according to the orientation, text direction and the children order
 *
 * Describes the possible transitions in a [class@Leaflet] widget.
 *
 * New values may be added to this enumeration over time.
 *
 * Since: 1.0
 */

enum {
  PROP_0,
  PROP_FOLDED,
  PROP_HHOMOGENEOUS_FOLDED,
  PROP_VHOMOGENEOUS_FOLDED,
  PROP_HHOMOGENEOUS_UNFOLDED,
  PROP_VHOMOGENEOUS_UNFOLDED,
  PROP_VISIBLE_CHILD,
  PROP_VISIBLE_CHILD_NAME,
  PROP_TRANSITION_TYPE,
  PROP_MODE_TRANSITION_DURATION,
  PROP_CHILD_TRANSITION_DURATION,
  PROP_CHILD_TRANSITION_RUNNING,
  PROP_INTERPOLATE_SIZE,
  PROP_CAN_SWIPE_BACK,
  PROP_CAN_SWIPE_FORWARD,

  /* orientable */
  PROP_ORIENTATION,
  LAST_PROP = PROP_ORIENTATION,
};

enum {
  CHILD_PROP_0,
  CHILD_PROP_NAME,
  CHILD_PROP_NAVIGATABLE,
  LAST_CHILD_PROP,
};

typedef struct
{
  HdyStackableBox *box;
} HdyLeafletPrivate;

static GParamSpec *props[LAST_PROP];
static GParamSpec *child_props[LAST_CHILD_PROP];

static void hdy_leaflet_swipeable_init (HdySwipeableInterface *iface);

G_DEFINE_TYPE_WITH_CODE (HdyLeaflet, hdy_leaflet, GTK_TYPE_CONTAINER,
                         G_ADD_PRIVATE (HdyLeaflet)
                         G_IMPLEMENT_INTERFACE (GTK_TYPE_ORIENTABLE, NULL)
                         G_IMPLEMENT_INTERFACE (HDY_TYPE_SWIPEABLE, hdy_leaflet_swipeable_init))

#define HDY_GET_HELPER(obj) (((HdyLeafletPrivate *) hdy_leaflet_get_instance_private (HDY_LEAFLET (obj)))->box)

/**
 * hdy_leaflet_get_folded: (attributes org.gtk.Method.get_property=folded)
 * @self: a leaflet
 *
 * Gets whether @self is folded.
 *
 * Returns: whether @self is folded
 *
 * Since: 1.0
 */
gboolean
hdy_leaflet_get_folded (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), FALSE);

  return hdy_stackable_box_get_folded (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_set_homogeneous:
 * @self: a leaflet
 * @folded: the fold
 * @orientation: the orientation
 * @homogeneous: `TRUE` to make @self homogeneous
 *
 * Sets whether to be homogeneous for the given fold and orientation.
 *
 * If it is homogeneous, the [class@Leaflet] will request the same
 * width or height for all its children depending on the orientation. If it
 * isn't and it is folded, the leaflet may change width or height when a
 * different child becomes visible.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_homogeneous (HdyLeaflet     *self,
                             gboolean        folded,
                             GtkOrientation  orientation,
                             gboolean        homogeneous)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));

  hdy_stackable_box_set_homogeneous (HDY_GET_HELPER (self), folded, orientation, homogeneous);
}

/**
 * hdy_leaflet_get_homogeneous:
 * @self: a leaflet
 * @folded: the fold
 * @orientation: the orientation
 *
 * Gets whether @self is homogeneous for the given fold and orientation.
 *
 * Returns: whether @self is homogeneous for the given fold and orientation
 *
 * Since: 1.0
 */
gboolean
hdy_leaflet_get_homogeneous (HdyLeaflet     *self,
                             gboolean        folded,
                             GtkOrientation  orientation)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), FALSE);

  return hdy_stackable_box_get_homogeneous (HDY_GET_HELPER (self), folded, orientation);
}

/**
 * hdy_leaflet_get_transition_type: (attributes org.gtk.Method.get_property=transition-type)
 * @self: a leaflet
 *
 * Gets the animation type that will be used for transitions between modes and
 * children.
 *
 * Returns: the current transition type of @self
 *
 * Since: 1.0
 */
HdyLeafletTransitionType
hdy_leaflet_get_transition_type (HdyLeaflet *self)
{
  HdyStackableBoxTransitionType type;

  g_return_val_if_fail (HDY_IS_LEAFLET (self), HDY_LEAFLET_TRANSITION_TYPE_OVER);

  type = hdy_stackable_box_get_transition_type (HDY_GET_HELPER (self));

  switch (type) {
  case HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER:
    return HDY_LEAFLET_TRANSITION_TYPE_OVER;

  case HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER:
    return HDY_LEAFLET_TRANSITION_TYPE_UNDER;

  case HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE:
    return HDY_LEAFLET_TRANSITION_TYPE_SLIDE;

  default:
    g_assert_not_reached ();
  }
}

/**
 * hdy_leaflet_set_transition_type: (attributes org.gtk.Method.set_property=transition-type)
 * @self: a leaflet
 * @transition: the new transition type
 *
 * Sets the animation type that will be used for transitions between modes and
 * children.
 *
 * The transition type can be changed without problems at runtime, so it is
 * possible to change the animation based on the mode or child that is about to
 * become current.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_transition_type (HdyLeaflet               *self,
                                 HdyLeafletTransitionType  transition)
{
  HdyStackableBoxTransitionType type;

  g_return_if_fail (HDY_IS_LEAFLET (self));
  g_return_if_fail (transition <= HDY_LEAFLET_TRANSITION_TYPE_SLIDE);

  switch (transition) {
  case HDY_LEAFLET_TRANSITION_TYPE_OVER:
    type = HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER;
    break;

  case HDY_LEAFLET_TRANSITION_TYPE_UNDER:
    type = HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER;
    break;

  case HDY_LEAFLET_TRANSITION_TYPE_SLIDE:
    type = HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE;
    break;

  default:
    g_assert_not_reached ();
  }

  hdy_stackable_box_set_transition_type (HDY_GET_HELPER (self), type);
}

/**
 * hdy_leaflet_get_mode_transition_duration: (attributes org.gtk.Method.get_property=mode-transition-duration)
 * @self: a leaflet
 *
 * Gets the amount of time that transitions between modes in @self will take.
 *
 * Returns: the mode transition duration, in milliseconds
 *
 * Since: 1.0
 */
guint
hdy_leaflet_get_mode_transition_duration (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), 0);

  return hdy_stackable_box_get_mode_transition_duration (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_set_mode_transition_duration: (attributes org.gtk.Method.set_property=mode-transition-duration)
 * @self: a leaflet
 * @duration: the new duration, in milliseconds
 *
 * Sets the duration that transitions between modes in @self will take.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_mode_transition_duration (HdyLeaflet *self,
                                          guint       duration)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));

  hdy_stackable_box_set_mode_transition_duration (HDY_GET_HELPER (self), duration);
}

/**
 * hdy_leaflet_get_child_transition_duration: (attributes org.gtk.Method.get_property=child-transition-duration)
 * @self: a leaflet
 *
 * Gets the amount of time that transitions between children will take.
 *
 * Returns: the child transition duration, in milliseconds
 *
 * Since: 1.0
 */
guint
hdy_leaflet_get_child_transition_duration (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), 0);

  return hdy_stackable_box_get_child_transition_duration (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_set_child_transition_duration: (attributes org.gtk.Method.set_property=child-transition-duration)
 * @self: a leaflet
 * @duration: the new duration, in milliseconds
 *
 * Sets the duration that transitions between children in @self will take.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_child_transition_duration (HdyLeaflet *self,
                                           guint       duration)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));

  hdy_stackable_box_set_child_transition_duration (HDY_GET_HELPER (self), duration);
}

/**
 * hdy_leaflet_get_visible_child: (attributes org.gtk.Method.get_property=visible-child)
 * @self: a leaflet
 *
 * Gets the visible child widget.
 *
 * Returns: (transfer none): the visible child widget
 *
 * Since: 1.0
 */
GtkWidget *
hdy_leaflet_get_visible_child (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), NULL);

  return hdy_stackable_box_get_visible_child (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_set_visible_child: (attributes org.gtk.Method.set_property=visible-child)
 * @self: a leaflet
 * @visible_child: the new child
 *
 * Sets the currently visible widget when the leaflet is folded.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_visible_child (HdyLeaflet *self,
                               GtkWidget  *visible_child)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));

  hdy_stackable_box_set_visible_child (HDY_GET_HELPER (self), visible_child);
}

/**
 * hdy_leaflet_get_visible_child_name: (attributes org.gtk.Method.get_property=visible-child-name)
 * @self: a leaflet
 *
 * Gets the name of the currently visible child widget.
 *
 * Returns: (transfer none): the name of the visible child
 *
 * Since: 1.0
 */
const gchar *
hdy_leaflet_get_visible_child_name (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), NULL);

  return hdy_stackable_box_get_visible_child_name (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_set_visible_child_name: (attributes org.gtk.Method.set_property=visible-child-name)
 * @self: a leaflet
 * @name: the name of a child
 *
 * Makes the child with the name @name visible.
 *
 * See [method@Leaflet.set_visible_child] for more details.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_visible_child_name (HdyLeaflet  *self,
                                    const gchar *name)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));

  hdy_stackable_box_set_visible_child_name (HDY_GET_HELPER (self), name);
}

/**
 * hdy_leaflet_get_child_transition_running: (attributes org.gtk.Method.get_property=child-transition-running)
 * @self: a leaflet
 *
 * Returns whether @self is currently in a transition from one page to another.
 *
 * Returns: whether a transition is currently running
 *
 * Since: 1.0
 */
gboolean
hdy_leaflet_get_child_transition_running (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), FALSE);

  return hdy_stackable_box_get_child_transition_running (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_set_interpolate_size: (attributes org.gtk.Method.set_property=interpolate-size)
 * @self: a leaflet
 * @interpolate_size: the new value
 *
 * Sets whether @self will interpolate its size when changing the visible child.
 *
 * If the [property@Leaflet:interpolate-size] property is set to `TRUE`, @self
 * will interpolate its size between the current one and the one it'll take
 * after changing the visible child, according to the set transition duration.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_interpolate_size (HdyLeaflet *self,
                                  gboolean    interpolate_size)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));

  hdy_stackable_box_set_interpolate_size (HDY_GET_HELPER (self), interpolate_size);
}

/**
 * hdy_leaflet_get_interpolate_size: (attributes org.gtk.Method.get_property=interpolate-size)
 * @self: a leaflet
 *
 * Gets whether to interpolate between the sizes of children on page switches.
 *
 * Returns: `TRUE` if child sizes are interpolated
 *
 * Since: 1.0
 */
gboolean
hdy_leaflet_get_interpolate_size (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), FALSE);

  return hdy_stackable_box_get_interpolate_size (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_set_can_swipe_back: (attributes org.gtk.Method.set_property=can-swipe-back)
 * @self: a leaflet
 * @can_swipe_back: the new value
 *
 * Sets whether swipe gestures switch to the previous navigatable child.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_can_swipe_back (HdyLeaflet *self,
                                gboolean    can_swipe_back)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));

  hdy_stackable_box_set_can_swipe_back (HDY_GET_HELPER (self), can_swipe_back);
}

/**
 * hdy_leaflet_get_can_swipe_back: (attributes org.gtk.Method.get_property=can-swipe-back)
 * @self: a leaflet
 *
 * Gets whether swipe gestures switch to the previous navigatable child.
 *
 * Returns: `TRUE` if back swipe is enabled
 *
 * Since: 1.0
 */
gboolean
hdy_leaflet_get_can_swipe_back (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), FALSE);

  return hdy_stackable_box_get_can_swipe_back (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_set_can_swipe_forward: (attributes org.gtk.Method.set_property=can-swipe-forward)
 * @self: a leaflet
 * @can_swipe_forward: the new value
 *
 * Sets whether swipe gestures switch to the next navigatable child.
 *
 * Since: 1.0
 */
void
hdy_leaflet_set_can_swipe_forward (HdyLeaflet *self,
                                   gboolean    can_swipe_forward)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));

  hdy_stackable_box_set_can_swipe_forward (HDY_GET_HELPER (self), can_swipe_forward);
}

/**
 * hdy_leaflet_get_can_swipe_forward: (attributes org.gtk.Method.get_property=can-swipe-forward)
 * @self: a leaflet
 *
 * Gets whether swipe gestures switch to the next navigatable child.
 *
 * Returns: `TRUE` if forward swipe is enabled
 *
 * Since: 1.0
 */
gboolean
hdy_leaflet_get_can_swipe_forward (HdyLeaflet *self)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), FALSE);

  return hdy_stackable_box_get_can_swipe_forward (HDY_GET_HELPER (self));
}

/**
 * hdy_leaflet_get_adjacent_child:
 * @self: a leaflet
 * @direction: the direction
 *
 * Finds the previous or next navigatable child.
 *
 * This will be the same widget [method@Leaflet.navigate] will navigate to.
 *
 * If there's no child to navigate to, `NULL` will be returned instead.
 *
 * Returns: (nullable) (transfer none): the previous or next child
 *
 * Since: 1.0
 */
GtkWidget *
hdy_leaflet_get_adjacent_child (HdyLeaflet             *self,
                                HdyNavigationDirection  direction)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), NULL);

  return hdy_stackable_box_get_adjacent_child (HDY_GET_HELPER (self), direction);
}

/**
 * hdy_leaflet_navigate:
 * @self: a leaflet
 * @direction: the direction
 *
 * Navigates to the previous or next navigatable child.
 *
 * The switch is similar to performing a swipe gesture to go in @direction.
 *
 * Returns: whether the visible child was changed
 *
 * Since: 1.0
 */
gboolean
hdy_leaflet_navigate (HdyLeaflet             *self,
                      HdyNavigationDirection  direction)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), FALSE);

  return hdy_stackable_box_navigate (HDY_GET_HELPER (self), direction);
}

/**
 * hdy_leaflet_get_child_by_name:
 * @self: a leaflet
 * @name: the name of the child to find
 *
 * Finds the child of @self with the name given as the argument.
 *
 * Returns `NULL` if there is no child with this name.
 *
 * Returns: (transfer none) (nullable): the requested child of @self
 *
 * Since: 1.0
 */
GtkWidget *
hdy_leaflet_get_child_by_name (HdyLeaflet  *self,
                               const gchar *name)
{
  g_return_val_if_fail (HDY_IS_LEAFLET (self), NULL);

  return hdy_stackable_box_get_child_by_name (HDY_GET_HELPER (self), name);
}

/**
 * hdy_leaflet_prepend:
 * @self: a leaflet
 * @child: the widget to prepend
 *
 * Inserts @child at the first position in @self.
 *
 * Since: 1.2
 */
void
hdy_leaflet_prepend (HdyLeaflet *self,
                     GtkWidget  *child)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));
  g_return_if_fail (GTK_IS_WIDGET (child));
  g_return_if_fail (gtk_widget_get_parent (child) == NULL);

  hdy_stackable_box_prepend (HDY_GET_HELPER (self), child);
}

/**
 * hdy_leaflet_insert_child_after:
 * @self: a leaflet
 * @child: the widget to insert
 * @sibling: (nullable): the sibling after which to insert @child
 *
 * Inserts @child in the position after @sibling in the list of children.
 *
 * If @sibling is `NULL`, inserts @child at the first position.
 *
 * Since: 1.2
 */
void
hdy_leaflet_insert_child_after (HdyLeaflet *self,
                                GtkWidget  *child,
                                GtkWidget  *sibling)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));
  g_return_if_fail (GTK_IS_WIDGET (child));
  g_return_if_fail (sibling == NULL || GTK_IS_WIDGET (sibling));

  g_return_if_fail (gtk_widget_get_parent (child) == NULL);
  g_return_if_fail (sibling == NULL || gtk_widget_get_parent (sibling) == GTK_WIDGET (self));

  hdy_stackable_box_insert_child_after (HDY_GET_HELPER (self), child, sibling);
}

/**
 * hdy_leaflet_reorder_child_after:
 * @self: a leaflet
 * @child: the widget to move, must be a child of @self
 * @sibling: (nullable): the sibling to move @child after
 *
 * Moves @child to the position after @sibling in the list of children.
 *
 * If @sibling is `NULL`, move @child to the first position.
 *
 * Since: 1.2
 */
void
hdy_leaflet_reorder_child_after (HdyLeaflet *self,
                                 GtkWidget  *child,
                                 GtkWidget  *sibling)
{
  g_return_if_fail (HDY_IS_LEAFLET (self));
  g_return_if_fail (GTK_IS_WIDGET (child));
  g_return_if_fail (sibling == NULL || GTK_IS_WIDGET (sibling));

  g_return_if_fail (gtk_widget_get_parent (child) == GTK_WIDGET (self));
  g_return_if_fail (sibling == NULL || gtk_widget_get_parent (sibling) == GTK_WIDGET (self));

  if (child == sibling)
    return;

  hdy_stackable_box_reorder_child_after (HDY_GET_HELPER (self), child, sibling);
}

/* This private method is prefixed by the call name because it will be a virtual
 * method in GTK 4.
 */
static void
hdy_leaflet_measure (GtkWidget      *widget,
                     GtkOrientation  orientation,
                     int             for_size,
                     int            *minimum,
                     int            *natural,
                     int            *minimum_baseline,
                     int            *natural_baseline)
{
  hdy_stackable_box_measure (HDY_GET_HELPER (widget),
                             orientation, for_size,
                             minimum, natural,
                             minimum_baseline, natural_baseline);
}

static void
hdy_leaflet_get_preferred_width (GtkWidget *widget,
                                 gint      *minimum_width,
                                 gint      *natural_width)
{
  hdy_leaflet_measure (widget, GTK_ORIENTATION_HORIZONTAL, -1,
                       minimum_width, natural_width, NULL, NULL);
}

static void
hdy_leaflet_get_preferred_height (GtkWidget *widget,
                                  gint      *minimum_height,
                                  gint      *natural_height)
{
  hdy_leaflet_measure (widget, GTK_ORIENTATION_VERTICAL, -1,
                       minimum_height, natural_height, NULL, NULL);
}

static void
hdy_leaflet_get_preferred_width_for_height (GtkWidget *widget,
                                            gint       height,
                                            gint      *minimum_width,
                                            gint      *natural_width)
{
  hdy_leaflet_measure (widget, GTK_ORIENTATION_HORIZONTAL, height,
                       minimum_width, natural_width, NULL, NULL);
}

static void
hdy_leaflet_get_preferred_height_for_width (GtkWidget *widget,
                                            gint       width,
                                            gint      *minimum_height,
                                            gint      *natural_height)
{
  hdy_leaflet_measure (widget, GTK_ORIENTATION_VERTICAL, width,
                       minimum_height, natural_height, NULL, NULL);
}

static void
hdy_leaflet_size_allocate (GtkWidget     *widget,
                           GtkAllocation *allocation)
{
  hdy_stackable_box_size_allocate (HDY_GET_HELPER (widget), allocation);
}

static gboolean
hdy_leaflet_draw (GtkWidget *widget,
                  cairo_t   *cr)
{
  return hdy_stackable_box_draw (HDY_GET_HELPER (widget), cr);
}

static void
hdy_leaflet_direction_changed (GtkWidget        *widget,
                               GtkTextDirection  previous_direction)
{
  hdy_stackable_box_direction_changed (HDY_GET_HELPER (widget), previous_direction);
}

static void
hdy_leaflet_add (GtkContainer *container,
                 GtkWidget    *widget)
{
  hdy_stackable_box_add (HDY_GET_HELPER (container), widget);
}

static void
hdy_leaflet_remove (GtkContainer *container,
                    GtkWidget    *widget)
{
  hdy_stackable_box_remove (HDY_GET_HELPER (container), widget);
}

static void
hdy_leaflet_forall (GtkContainer *container,
                    gboolean      include_internals,
                    GtkCallback   callback,
                    gpointer      callback_data)
{
  hdy_stackable_box_forall (HDY_GET_HELPER (container), include_internals, callback, callback_data);
}

static void
hdy_leaflet_get_property (GObject    *object,
                          guint       prop_id,
                          GValue     *value,
                          GParamSpec *pspec)
{
  HdyLeaflet *self = HDY_LEAFLET (object);

  switch (prop_id) {
  case PROP_FOLDED:
    g_value_set_boolean (value, hdy_leaflet_get_folded (self));
    break;
  case PROP_HHOMOGENEOUS_FOLDED:
    g_value_set_boolean (value, hdy_leaflet_get_homogeneous (self, TRUE, GTK_ORIENTATION_HORIZONTAL));
    break;
  case PROP_VHOMOGENEOUS_FOLDED:
    g_value_set_boolean (value, hdy_leaflet_get_homogeneous (self, TRUE, GTK_ORIENTATION_VERTICAL));
    break;
  case PROP_HHOMOGENEOUS_UNFOLDED:
    g_value_set_boolean (value, hdy_leaflet_get_homogeneous (self, FALSE, GTK_ORIENTATION_HORIZONTAL));
    break;
  case PROP_VHOMOGENEOUS_UNFOLDED:
    g_value_set_boolean (value, hdy_leaflet_get_homogeneous (self, FALSE, GTK_ORIENTATION_VERTICAL));
    break;
  case PROP_VISIBLE_CHILD:
    g_value_set_object (value, hdy_leaflet_get_visible_child (self));
    break;
  case PROP_VISIBLE_CHILD_NAME:
    g_value_set_string (value, hdy_leaflet_get_visible_child_name (self));
    break;
  case PROP_TRANSITION_TYPE:
    g_value_set_enum (value, hdy_leaflet_get_transition_type (self));
    break;
  case PROP_MODE_TRANSITION_DURATION:
    g_value_set_uint (value, hdy_leaflet_get_mode_transition_duration (self));
    break;
  case PROP_CHILD_TRANSITION_DURATION:
    g_value_set_uint (value, hdy_leaflet_get_child_transition_duration (self));
    break;
  case PROP_CHILD_TRANSITION_RUNNING:
    g_value_set_boolean (value, hdy_leaflet_get_child_transition_running (self));
    break;
  case PROP_INTERPOLATE_SIZE:
    g_value_set_boolean (value, hdy_leaflet_get_interpolate_size (self));
    break;
  case PROP_CAN_SWIPE_BACK:
    g_value_set_boolean (value, hdy_leaflet_get_can_swipe_back (self));
    break;
  case PROP_CAN_SWIPE_FORWARD:
    g_value_set_boolean (value, hdy_leaflet_get_can_swipe_forward (self));
    break;
  case PROP_ORIENTATION:
    g_value_set_enum (value, hdy_stackable_box_get_orientation (HDY_GET_HELPER (self)));
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_leaflet_set_property (GObject      *object,
                          guint         prop_id,
                          const GValue *value,
                          GParamSpec   *pspec)
{
  HdyLeaflet *self = HDY_LEAFLET (object);

  switch (prop_id) {
  case PROP_HHOMOGENEOUS_FOLDED:
    hdy_leaflet_set_homogeneous (self, TRUE, GTK_ORIENTATION_HORIZONTAL, g_value_get_boolean (value));
    break;
  case PROP_VHOMOGENEOUS_FOLDED:
    hdy_leaflet_set_homogeneous (self, TRUE, GTK_ORIENTATION_VERTICAL, g_value_get_boolean (value));
    break;
  case PROP_HHOMOGENEOUS_UNFOLDED:
    hdy_leaflet_set_homogeneous (self, FALSE, GTK_ORIENTATION_HORIZONTAL, g_value_get_boolean (value));
    break;
  case PROP_VHOMOGENEOUS_UNFOLDED:
    hdy_leaflet_set_homogeneous (self, FALSE, GTK_ORIENTATION_VERTICAL, g_value_get_boolean (value));
    break;
  case PROP_VISIBLE_CHILD:
    hdy_leaflet_set_visible_child (self, g_value_get_object (value));
    break;
  case PROP_VISIBLE_CHILD_NAME:
    hdy_leaflet_set_visible_child_name (self, g_value_get_string (value));
    break;
  case PROP_TRANSITION_TYPE:
    hdy_leaflet_set_transition_type (self, g_value_get_enum (value));
    break;
  case PROP_MODE_TRANSITION_DURATION:
    hdy_leaflet_set_mode_transition_duration (self, g_value_get_uint (value));
    break;
  case PROP_CHILD_TRANSITION_DURATION:
    hdy_leaflet_set_child_transition_duration (self, g_value_get_uint (value));
    break;
  case PROP_INTERPOLATE_SIZE:
    hdy_leaflet_set_interpolate_size (self, g_value_get_boolean (value));
    break;
  case PROP_CAN_SWIPE_BACK:
    hdy_leaflet_set_can_swipe_back (self, g_value_get_boolean (value));
    break;
  case PROP_CAN_SWIPE_FORWARD:
    hdy_leaflet_set_can_swipe_forward (self, g_value_get_boolean (value));
    break;
  case PROP_ORIENTATION:
    hdy_stackable_box_set_orientation (HDY_GET_HELPER (self), g_value_get_enum (value));
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_leaflet_finalize (GObject *object)
{
  HdyLeaflet *self = HDY_LEAFLET (object);
  HdyLeafletPrivate *priv = hdy_leaflet_get_instance_private (self);

  g_clear_object (&priv->box);

  G_OBJECT_CLASS (hdy_leaflet_parent_class)->finalize (object);
}

static void
hdy_leaflet_get_child_property (GtkContainer *container,
                                GtkWidget    *widget,
                                guint         property_id,
                                GValue       *value,
                                GParamSpec   *pspec)
{
  switch (property_id) {
  case CHILD_PROP_NAME:
    g_value_set_string (value, hdy_stackable_box_get_child_name (HDY_GET_HELPER (container), widget));
    break;

  case CHILD_PROP_NAVIGATABLE:
    g_value_set_boolean (value, hdy_stackable_box_get_child_navigatable (HDY_GET_HELPER (container), widget));
    break;

  default:
    GTK_CONTAINER_WARN_INVALID_CHILD_PROPERTY_ID (container, property_id, pspec);
    break;
  }
}

static void
hdy_leaflet_set_child_property (GtkContainer *container,
                                GtkWidget    *widget,
                                guint         property_id,
                                const GValue *value,
                                GParamSpec   *pspec)
{
  switch (property_id) {
  case CHILD_PROP_NAME:
    hdy_stackable_box_set_child_name (HDY_GET_HELPER (container), widget, g_value_get_string (value));
    gtk_container_child_notify_by_pspec (container, widget, pspec);
    break;

  case CHILD_PROP_NAVIGATABLE:
    hdy_stackable_box_set_child_navigatable (HDY_GET_HELPER (container), widget, g_value_get_boolean (value));
    gtk_container_child_notify_by_pspec (container, widget, pspec);
    break;

  default:
    GTK_CONTAINER_WARN_INVALID_CHILD_PROPERTY_ID (container, property_id, pspec);
    break;
  }
}

static void
hdy_leaflet_realize (GtkWidget *widget)
{
  hdy_stackable_box_realize (HDY_GET_HELPER (widget));
}

static void
hdy_leaflet_unrealize (GtkWidget *widget)
{
  hdy_stackable_box_unrealize (HDY_GET_HELPER (widget));
}

static void
hdy_leaflet_switch_child (HdySwipeable *swipeable,
                          guint         index,
                          gint64        duration)
{
  hdy_stackable_box_switch_child (HDY_GET_HELPER (swipeable), index, duration);
}

static HdySwipeTracker *
hdy_leaflet_get_swipe_tracker (HdySwipeable *swipeable)
{
  return hdy_stackable_box_get_swipe_tracker (HDY_GET_HELPER (swipeable));
}

static gdouble
hdy_leaflet_get_distance (HdySwipeable *swipeable)
{
  return hdy_stackable_box_get_distance (HDY_GET_HELPER (swipeable));
}

static gdouble *
hdy_leaflet_get_snap_points (HdySwipeable *swipeable,
                             gint         *n_snap_points)
{
  return hdy_stackable_box_get_snap_points (HDY_GET_HELPER (swipeable), n_snap_points);
}

static gdouble
hdy_leaflet_get_progress (HdySwipeable *swipeable)
{
  return hdy_stackable_box_get_progress (HDY_GET_HELPER (swipeable));
}

static gdouble
hdy_leaflet_get_cancel_progress (HdySwipeable *swipeable)
{
  return hdy_stackable_box_get_cancel_progress (HDY_GET_HELPER (swipeable));
}

static void
hdy_leaflet_get_swipe_area (HdySwipeable           *swipeable,
                            HdyNavigationDirection  navigation_direction,
                            gboolean                is_drag,
                            GdkRectangle           *rect)
{
  hdy_stackable_box_get_swipe_area (HDY_GET_HELPER (swipeable), navigation_direction, is_drag, rect);
}

static void
hdy_leaflet_class_init (HdyLeafletClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = (GtkWidgetClass*) klass;
  GtkContainerClass *container_class = (GtkContainerClass*) klass;

  object_class->get_property = hdy_leaflet_get_property;
  object_class->set_property = hdy_leaflet_set_property;
  object_class->finalize = hdy_leaflet_finalize;

  widget_class->realize = hdy_leaflet_realize;
  widget_class->unrealize = hdy_leaflet_unrealize;
  widget_class->get_preferred_width = hdy_leaflet_get_preferred_width;
  widget_class->get_preferred_height = hdy_leaflet_get_preferred_height;
  widget_class->get_preferred_width_for_height = hdy_leaflet_get_preferred_width_for_height;
  widget_class->get_preferred_height_for_width = hdy_leaflet_get_preferred_height_for_width;
  widget_class->size_allocate = hdy_leaflet_size_allocate;
  widget_class->draw = hdy_leaflet_draw;
  widget_class->direction_changed = hdy_leaflet_direction_changed;

  container_class->add = hdy_leaflet_add;
  container_class->remove = hdy_leaflet_remove;
  container_class->forall = hdy_leaflet_forall;
  container_class->set_child_property = hdy_leaflet_set_child_property;
  container_class->get_child_property = hdy_leaflet_get_child_property;
  gtk_container_class_handle_border_width (container_class);

  g_object_class_override_property (object_class,
                                    PROP_ORIENTATION,
                                    "orientation");

  /**
   * HdyLeaflet:folded: (attributes org.gtk.Property.get=hdy_leaflet_get_folded)
   *
   * Whether the leaflet is folded.
   *
   * The leaflet will be folded if the size allocated to it is smaller than the
   * sum of the natural size of its children, it will be unfolded otherwise.
   *
   * Since: 1.0
   */
  props[PROP_FOLDED] =
    g_param_spec_boolean ("folded",
                          _("Folded"),
                          _("Whether the widget is folded"),
                          FALSE,
                          G_PARAM_READABLE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:hhomogeneous-folded: (attributes org.gtk.Property.get=hdy_leaflet_get_homogeneous org.gtk.Property.set=hdy_leaflet_set_homogeneous)
   *
   * Whether to allocate the same width for all children when folded.
   *
   * Since: 1.0
   */
  props[PROP_HHOMOGENEOUS_FOLDED] =
    g_param_spec_boolean ("hhomogeneous-folded",
                          _("Horizontally homogeneous folded"),
                          _("Horizontally homogeneous sizing when the leaflet is folded"),
                          TRUE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:vhomogeneous-folded: (attributes org.gtk.Property.get=hdy_leaflet_get_homogeneous org.gtk.Property.set=hdy_leaflet_set_homogeneous)
   *
   * Whether to allocates the same height for all children when folded.
   *
   * Since: 1.0
   */
  props[PROP_VHOMOGENEOUS_FOLDED] =
    g_param_spec_boolean ("vhomogeneous-folded",
                          _("Vertically homogeneous folded"),
                          _("Vertically homogeneous sizing when the leaflet is folded"),
                          TRUE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:hhomogeneous-unfolded: (attributes org.gtk.Property.get=hdy_leaflet_get_homogeneous org.gtk.Property.set=hdy_leaflet_set_homogeneous)
   *
   * Whether to allocate the same width for all children when unfolded.
   *
   * Since: 1.0
   */
  props[PROP_HHOMOGENEOUS_UNFOLDED] =
    g_param_spec_boolean ("hhomogeneous-unfolded",
                          _("Box horizontally homogeneous"),
                          _("Horizontally homogeneous sizing when the leaflet is unfolded"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:vhomogeneous-unfolded: (attributes org.gtk.Property.get=hdy_leaflet_get_homogeneous org.gtk.Property.set=hdy_leaflet_set_homogeneous)
   *
   * Whether to allocate the same height for all children when unfolded.
   *
   * Since: 1.0
   */
  props[PROP_VHOMOGENEOUS_UNFOLDED] =
    g_param_spec_boolean ("vhomogeneous-unfolded",
                          _("Box vertically homogeneous"),
                          _("Vertically homogeneous sizing when the leaflet is unfolded"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:visible-child: (attributes org.gtk.Property.get=hdy_leaflet_get_visible_child org.gtk.Property.set=hdy_leaflet_set_visible_child)
   *
   * The widget currently visible when the leaflet is folded.
   *
   * The transition is determined by [property@Leaflet:transition-type] and
   * [property@Leaflet:child-transition-duration]. The transition can be
   * cancelled by the user, in which case visible child will change back to the
   * previously visible child.
   *
   * Since: 1.0
   */
  props[PROP_VISIBLE_CHILD] =
    g_param_spec_object ("visible-child",
                         _("Visible child"),
                         _("The widget currently visible when the leaflet is folded"),
                         GTK_TYPE_WIDGET,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:visible-child-name: (attributes org.gtk.Property.get=hdy_leaflet_get_visible_child_name org.gtk.Property.set=hdy_leaflet_set_visible_child_name)
   *
   * The name of the widget currently visible when the leaflet is folded.
   *
   * See [property@Leaflet:visible-child].
   *
   * Since: 1.0
   */
  props[PROP_VISIBLE_CHILD_NAME] =
    g_param_spec_string ("visible-child-name",
                         _("Name of visible child"),
                         _("The name of the widget currently visible when the children are stacked"),
                         NULL,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:transition-type: (attributes org.gtk.Property.get=hdy_leaflet_get_transition_type org.gtk.Property.set=hdy_leaflet_set_transition_type)
   *
   * The animation type used for transitions between modes and children.
   *
   * The transition type can be changed without problems at runtime, so it is
   * possible to change the animation based on the mode or child that is about
   * to become current.
   *
   * Since: 1.0
   */
  props[PROP_TRANSITION_TYPE] =
    g_param_spec_enum ("transition-type",
                       _("Transition type"),
                       _("The type of animation used to transition between modes and children"),
                       HDY_TYPE_LEAFLET_TRANSITION_TYPE, HDY_LEAFLET_TRANSITION_TYPE_OVER,
                       G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:mode-transition-duration: (attributes org.gtk.Property.get=hdy_leaflet_get_mode_transition_duration org.gtk.Property.set=hdy_leaflet_set_mode_transition_duration)
   *
   * The mode transition animation duration, in milliseconds.
   *
   * Since: 1.0
   */
  props[PROP_MODE_TRANSITION_DURATION] =
    g_param_spec_uint ("mode-transition-duration",
                       _("Mode transition duration"),
                       _("The mode transition animation duration, in milliseconds"),
                       0, G_MAXUINT, 250,
                       G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:child-transition-duration: (attributes org.gtk.Property.get=hdy_leaflet_get_child_transition_duration org.gtk.Property.set=hdy_leaflet_set_child_transition_duration)
   *
   * The child transition animation duration, in milliseconds.
   *
   * Since: 1.0
   */
  props[PROP_CHILD_TRANSITION_DURATION] =
    g_param_spec_uint ("child-transition-duration",
                       _("Child transition duration"),
                       _("The child transition animation duration, in milliseconds"),
                       0, G_MAXUINT, 200,
                       G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:child-transition-running: (attributes org.gtk.Property.get=hdy_leaflet_get_child_transition_running)
   *
   * Whether a child transition is currently running.
   *
   * Since: 1.0
   */
  props[PROP_CHILD_TRANSITION_RUNNING] =
      g_param_spec_boolean ("child-transition-running",
                            _("Child transition running"),
                            _("Whether or not the child transition is currently running"),
                            FALSE,
                            G_PARAM_READABLE);

  /**
   * HdyLeaflet:interpolate-size: (attributes org.gtk.Property.get=hdy_leaflet_get_interpolate_size org.gtk.Property.set=hdy_leaflet_set_interpolate_size)
   *
   * Whether the size should smoothly change when changing between children.
   *
   * Since: 1.0
   */
  props[PROP_INTERPOLATE_SIZE] =
      g_param_spec_boolean ("interpolate-size",
                            _("Interpolate size"),
                            _("Whether or not the size should smoothly change when changing between differently sized children"),
                            FALSE,
                            G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:can-swipe-back: (attributes org.gtk.Property.get=hdy_leaflet_get_can_swipe_back org.gtk.Property.set=hdy_leaflet_set_can_swipe_back)
   *
   * Whether swipe gestures allow switching to the previous navigatable child.
   *
   * Since: 1.0
   */
  props[PROP_CAN_SWIPE_BACK] =
      g_param_spec_boolean ("can-swipe-back",
                            _("Can swipe back"),
                            _("Whether or not swipe gesture can be used to switch to the previous child"),
                            FALSE,
                            G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyLeaflet:can-swipe-forward: (attributes org.gtk.Property.get=hdy_leaflet_get_can_swipe_forward org.gtk.Property.set=hdy_leaflet_set_can_swipe_forward)
   *
   * Whether swipe gestures allow switching to the next navigatable child.
   *
   * Since: 1.0
   */
  props[PROP_CAN_SWIPE_FORWARD] =
      g_param_spec_boolean ("can-swipe-forward",
                            _("Can swipe forward"),
                            _("Whether or not swipe gesture can be used to switch to the next child"),
                            FALSE,
                            G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  g_object_class_install_properties (object_class, LAST_PROP, props);

  child_props[CHILD_PROP_NAME] =
    g_param_spec_string ("name",
                         _("Name"),
                         _("The name of the child page"),
                         NULL,
                         G_PARAM_READWRITE);

  child_props[CHILD_PROP_NAVIGATABLE] =
    g_param_spec_boolean ("navigatable",
                          _("Navigatable"),
                          _("Whether the child can be navigated to"),
                          TRUE,
                          G_PARAM_READWRITE);

  gtk_container_class_install_child_properties (container_class, LAST_CHILD_PROP, child_props);

  gtk_widget_class_set_accessible_role (widget_class, ATK_ROLE_PANEL);
  gtk_widget_class_set_css_name (widget_class, "leaflet");
}

/**
 * hdy_leaflet_new:
 *
 * Creates a new `HdyLeaflet`.
 *
 * Returns: the newly created `HdyLeaflet`
 *
 * Since: 1.0
 */
GtkWidget *
hdy_leaflet_new (void)
{
  return g_object_new (HDY_TYPE_LEAFLET, NULL);
}

#define NOTIFY(func, prop) \
static void \
func (HdyLeaflet *self) { \
  g_object_notify_by_pspec (G_OBJECT (self), props[prop]); \
}

NOTIFY (notify_folded_cb, PROP_FOLDED);
NOTIFY (notify_hhomogeneous_folded_cb, PROP_HHOMOGENEOUS_FOLDED);
NOTIFY (notify_vhomogeneous_folded_cb, PROP_VHOMOGENEOUS_FOLDED);
NOTIFY (notify_hhomogeneous_unfolded_cb, PROP_HHOMOGENEOUS_UNFOLDED);
NOTIFY (notify_vhomogeneous_unfolded_cb, PROP_VHOMOGENEOUS_UNFOLDED);
NOTIFY (notify_visible_child_cb, PROP_VISIBLE_CHILD);
NOTIFY (notify_visible_child_name_cb, PROP_VISIBLE_CHILD_NAME);
NOTIFY (notify_transition_type_cb, PROP_TRANSITION_TYPE);
NOTIFY (notify_mode_transition_duration_cb, PROP_MODE_TRANSITION_DURATION);
NOTIFY (notify_child_transition_duration_cb, PROP_CHILD_TRANSITION_DURATION);
NOTIFY (notify_child_transition_running_cb, PROP_CHILD_TRANSITION_RUNNING);
NOTIFY (notify_interpolate_size_cb, PROP_INTERPOLATE_SIZE);
NOTIFY (notify_can_swipe_back_cb, PROP_CAN_SWIPE_BACK);
NOTIFY (notify_can_swipe_forward_cb, PROP_CAN_SWIPE_FORWARD);

static void
notify_orientation_cb (HdyLeaflet *self)
{
  g_object_notify (G_OBJECT (self), "orientation");
}

static void
hdy_leaflet_init (HdyLeaflet *self)
{
  HdyLeafletPrivate *priv = hdy_leaflet_get_instance_private (self);

  priv->box = hdy_stackable_box_new (GTK_CONTAINER (self),
                                     GTK_CONTAINER_CLASS (hdy_leaflet_parent_class),
                                     TRUE);

  g_signal_connect_object (priv->box, "notify::folded", G_CALLBACK (notify_folded_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::hhomogeneous-folded", G_CALLBACK (notify_hhomogeneous_folded_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::vhomogeneous-folded", G_CALLBACK (notify_vhomogeneous_folded_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::hhomogeneous-unfolded", G_CALLBACK (notify_hhomogeneous_unfolded_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::vhomogeneous-unfolded", G_CALLBACK (notify_vhomogeneous_unfolded_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::visible-child", G_CALLBACK (notify_visible_child_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::visible-child-name", G_CALLBACK (notify_visible_child_name_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::transition-type", G_CALLBACK (notify_transition_type_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::mode-transition-duration", G_CALLBACK (notify_mode_transition_duration_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::child-transition-duration", G_CALLBACK (notify_child_transition_duration_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::child-transition-running", G_CALLBACK (notify_child_transition_running_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::interpolate-size", G_CALLBACK (notify_interpolate_size_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::can-swipe-back", G_CALLBACK (notify_can_swipe_back_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::can-swipe-forward", G_CALLBACK (notify_can_swipe_forward_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (priv->box, "notify::orientation", G_CALLBACK (notify_orientation_cb), self, G_CONNECT_SWAPPED);
}

static void
hdy_leaflet_swipeable_init (HdySwipeableInterface *iface)
{
  iface->switch_child = hdy_leaflet_switch_child;
  iface->get_swipe_tracker = hdy_leaflet_get_swipe_tracker;
  iface->get_distance = hdy_leaflet_get_distance;
  iface->get_snap_points = hdy_leaflet_get_snap_points;
  iface->get_progress = hdy_leaflet_get_progress;
  iface->get_cancel_progress = hdy_leaflet_get_cancel_progress;
  iface->get_swipe_area = hdy_leaflet_get_swipe_area;
}
