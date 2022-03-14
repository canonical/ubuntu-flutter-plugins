/*
 * Copyright (C) 2018 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "config.h"
#include "hdy-clamp.h"

#include <glib/gi18n-lib.h>
#include <math.h>

#include "hdy-animation-private.h"
#include "hdy-css-private.h"

/**
 * HdyClamp:
 *
 * A widget constraining its child to a given size.
 *
 * The `HdyClamp` widget constrains the size of the widget it contains to a
 * given maximum size. It will constrain the width if it is horizontal, or the
 * height if it is vertical. The expansion of the child from its minimum to its
 * maximum size is eased out for a smooth transition.
 *
 * If the child requires more than the requested maximum size, it will be
 * allocated the minimum size it can fit in instead.
 *
 * ## CSS nodes
 *
 * `HdyClamp` has a single CSS node with name `clamp`.
 *
 * The node will get the style classes `.large` when its child reached its
 * maximum size, `.small` when the clamp allocates its full size to its child,
 * `.medium` in-between, or none if it didn't compute its size yet.
 *
 * Since: 1.0
 */

#define HDY_EASE_OUT_TAN_CUBIC 3

enum {
  PROP_0,
  PROP_MAXIMUM_SIZE,
  PROP_TIGHTENING_THRESHOLD,

  /* Overridden properties */
  PROP_ORIENTATION,

  LAST_PROP = PROP_TIGHTENING_THRESHOLD + 1,
};

struct _HdyClamp
{
  GtkBin parent_instance;

  gint maximum_size;
  gint tightening_threshold;

  GtkOrientation orientation;
};

static GParamSpec *props[LAST_PROP];

G_DEFINE_TYPE_WITH_CODE (HdyClamp, hdy_clamp, GTK_TYPE_BIN,
                         G_IMPLEMENT_INTERFACE (GTK_TYPE_ORIENTABLE, NULL))

static void
set_orientation (HdyClamp       *self,
                 GtkOrientation  orientation)
{
  if (self->orientation == orientation)
    return;

  self->orientation = orientation;
  gtk_widget_queue_resize (GTK_WIDGET (self));
  g_object_notify (G_OBJECT (self), "orientation");
}

static void
hdy_clamp_get_property (GObject    *object,
                        guint       prop_id,
                        GValue     *value,
                        GParamSpec *pspec)
{
  HdyClamp *self = HDY_CLAMP (object);

  switch (prop_id) {
  case PROP_MAXIMUM_SIZE:
    g_value_set_int (value, hdy_clamp_get_maximum_size (self));
    break;
  case PROP_TIGHTENING_THRESHOLD:
    g_value_set_int (value, hdy_clamp_get_tightening_threshold (self));
    break;
  case PROP_ORIENTATION:
    g_value_set_enum (value, self->orientation);
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_clamp_set_property (GObject      *object,
                        guint         prop_id,
                        const GValue *value,
                        GParamSpec   *pspec)
{
  HdyClamp *self = HDY_CLAMP (object);

  switch (prop_id) {
  case PROP_MAXIMUM_SIZE:
    hdy_clamp_set_maximum_size (self, g_value_get_int (value));
    break;
  case PROP_TIGHTENING_THRESHOLD:
    hdy_clamp_set_tightening_threshold (self, g_value_get_int (value));
    break;
  case PROP_ORIENTATION:
    set_orientation (self, g_value_get_enum (value));
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static inline double
inverse_lerp (double a,
              double b,
              double t)
{
  return (t - a) / (b - a);
}

static int
clamp_size_from_child (HdyClamp *self,
                       int       min,
                       int       nat)
{
  int max = 0, lower = 0, upper = 0;
  double progress;

  lower = MAX (MIN (self->tightening_threshold, self->maximum_size), min);
  max = MAX (lower, self->maximum_size);
  upper = lower + HDY_EASE_OUT_TAN_CUBIC * (max - lower);

  if (nat <= lower)
    progress = 0;
  else if (nat >= max)
    progress = 1;
  else {
    double ease = inverse_lerp (lower, max, nat);

    progress = 1 + cbrt (ease - 1); // inverse ease out cubic
  }

  return ceil (hdy_lerp (lower, upper, progress));
}

static int
child_size_from_clamp (HdyClamp  *self,
                       GtkWidget *child,
                       int        for_size,
                       int       *child_maximum,
                       int       *lower_threshold)
{
  int min = 0, nat = 0, max = 0, lower = 0, upper = 0;
  double progress;

  if (self->orientation == GTK_ORIENTATION_HORIZONTAL)
    gtk_widget_get_preferred_width (child, &min, &nat);
  else
    gtk_widget_get_preferred_height (child, &min, &nat);

  lower = MAX (MIN (self->tightening_threshold, self->maximum_size), min);
  max = MAX (lower, self->maximum_size);
  upper = lower + HDY_EASE_OUT_TAN_CUBIC * (max - lower);

  if (child_maximum)
    *child_maximum = max;
  if (lower_threshold)
    *lower_threshold = lower;

  if (for_size < 0)
    return MIN (nat, max);

  if (for_size <= lower)
    return for_size;

  if (for_size >= upper)
    return max;

  progress = inverse_lerp (lower, upper, for_size);

  return hdy_lerp (lower, max, hdy_ease_out_cubic (progress));
}

/* This private method is prefixed by the call name because it will be a virtual
 * method in GTK 4.
 */
static void
hdy_clamp_measure (GtkWidget      *widget,
                   GtkOrientation  orientation,
                   int             for_size,
                   int            *minimum,
                   int            *natural,
                   int            *minimum_baseline,
                   int            *natural_baseline)
{
  HdyClamp *self = HDY_CLAMP (widget);
  GtkBin *bin = GTK_BIN (widget);
  GtkWidget *child;
  int child_min = 0;
  int child_nat = 0;
  int child_min_baseline = -1;
  int child_nat_baseline = -1;

  if (minimum)
    *minimum = 0;
  if (natural)
    *natural = 0;
  if (minimum_baseline)
    *minimum_baseline = -1;
  if (natural_baseline)
    *natural_baseline = -1;

  child = gtk_bin_get_child (bin);

  if (!child || !gtk_widget_is_visible (child))
    return;

  for_size = hdy_css_adjust_for_size (widget, orientation, for_size);

  if (self->orientation == orientation) {
    if (orientation == GTK_ORIENTATION_HORIZONTAL)
      gtk_widget_get_preferred_width (child, &child_min, &child_nat);
    else
      gtk_widget_get_preferred_height_and_baseline_for_width (child, -1,
                                                              &child_min,
                                                              &child_nat,
                                                              &child_min_baseline,
                                                              &child_nat_baseline);

    child_nat = clamp_size_from_child (self, child_min, child_nat);
  } else {
    int child_size = child_size_from_clamp (self, child, for_size, NULL, NULL);

    if (orientation == GTK_ORIENTATION_HORIZONTAL)
      gtk_widget_get_preferred_width_for_height (child, child_size,
                                                 &child_min, &child_nat);
    else
      gtk_widget_get_preferred_height_and_baseline_for_width (child, child_size,
                                                              &child_min,
                                                              &child_nat,
                                                              &child_min_baseline,
                                                              &child_nat_baseline);
  }

  if (minimum)
    *minimum = child_min;
  if (natural)
    *natural = child_nat;
  if (minimum_baseline && child_min_baseline > -1)
    *minimum_baseline = child_min_baseline;
  if (natural_baseline && child_nat_baseline > -1)
    *natural_baseline = child_nat_baseline;

  hdy_css_measure (widget, orientation, minimum, natural);
}

static GtkSizeRequestMode
hdy_clamp_get_request_mode (GtkWidget *widget)
{
  HdyClamp *self = HDY_CLAMP (widget);

  return self->orientation == GTK_ORIENTATION_HORIZONTAL ?
    GTK_SIZE_REQUEST_HEIGHT_FOR_WIDTH :
    GTK_SIZE_REQUEST_WIDTH_FOR_HEIGHT;
}

static void
hdy_clamp_get_preferred_width_for_height (GtkWidget *widget,
                                          gint       height,
                                          gint      *minimum,
                                          gint      *natural)
{
  hdy_clamp_measure (widget, GTK_ORIENTATION_HORIZONTAL, height,
                     minimum, natural, NULL, NULL);
}

static void
hdy_clamp_get_preferred_width (GtkWidget *widget,
                               gint      *minimum,
                               gint      *natural)
{
  hdy_clamp_measure (widget, GTK_ORIENTATION_HORIZONTAL, -1,
                     minimum, natural, NULL, NULL);
}

static void
hdy_clamp_get_preferred_height_and_baseline_for_width (GtkWidget *widget,
                                                       gint       width,
                                                       gint      *minimum,
                                                       gint      *natural,
                                                       gint      *minimum_baseline,
                                                       gint      *natural_baseline)
{
  hdy_clamp_measure (widget, GTK_ORIENTATION_VERTICAL, width,
                     minimum, natural, minimum_baseline, natural_baseline);
}

static void
hdy_clamp_get_preferred_height_for_width (GtkWidget *widget,
                                          gint       width,
                                          gint      *minimum,
                                          gint      *natural)
{
  hdy_clamp_measure (widget, GTK_ORIENTATION_VERTICAL, width,
                     minimum, natural, NULL, NULL);
}

static void
hdy_clamp_get_preferred_height (GtkWidget *widget,
                                gint      *minimum,
                                gint      *natural)
{
  hdy_clamp_measure (widget, GTK_ORIENTATION_VERTICAL, -1,
                     minimum, natural, NULL, NULL);
}

static void
hdy_clamp_size_allocate (GtkWidget     *widget,
                         GtkAllocation *allocation)
{
  HdyClamp *self = HDY_CLAMP (widget);
  GtkBin *bin = GTK_BIN (widget);
  GtkAllocation child_allocation, base_child_allocation;
  gint baseline;
  GtkWidget *child;
  GtkStyleContext *context = gtk_widget_get_style_context (widget);
  gint child_maximum = 0, lower_threshold = 0;
  gint child_clamped_size;

  hdy_css_size_allocate_self (widget, allocation);
  gtk_widget_set_allocation (widget, allocation);

  child = gtk_bin_get_child (bin);
  if (!(child && gtk_widget_get_visible (child))) {
    gtk_style_context_remove_class (context, "small");
    gtk_style_context_remove_class (context, "medium");
    gtk_style_context_remove_class (context, "large");

    return;
  }

  child_allocation = *allocation;
  hdy_css_size_allocate_children (widget, &child_allocation);
  base_child_allocation = child_allocation;

  if (self->orientation == GTK_ORIENTATION_HORIZONTAL) {
    child_allocation.width = child_size_from_clamp (self, child,
                                                    child_allocation.width,
                                                    &child_maximum,
                                                    &lower_threshold);

    child_clamped_size = child_allocation.width;
  } else {
    child_allocation.height = child_size_from_clamp (self, child,
                                                     child_allocation.height,
                                                     &child_maximum,
                                                     &lower_threshold);

    child_clamped_size = child_allocation.height;
  }

  if (child_clamped_size >= child_maximum) {
    gtk_style_context_remove_class (context, "small");
    gtk_style_context_remove_class (context, "medium");
    gtk_style_context_add_class (context, "large");
  } else if (child_clamped_size <= lower_threshold) {
    gtk_style_context_add_class (context, "small");
    gtk_style_context_remove_class (context, "medium");
    gtk_style_context_remove_class (context, "large");
  } else {
    gtk_style_context_remove_class (context, "small");
    gtk_style_context_add_class (context, "medium");
    gtk_style_context_remove_class (context, "large");
  }

  /* Always center the child on the side of the orientation. */
  if (self->orientation == GTK_ORIENTATION_HORIZONTAL)
    child_allocation.x += (base_child_allocation.width - child_allocation.width) / 2;
  else
    child_allocation.y += (base_child_allocation.height - child_allocation.height) / 2;

  baseline = gtk_widget_get_allocated_baseline (widget);
  gtk_widget_size_allocate_with_baseline (child, &child_allocation, baseline);
}

static void
hdy_clamp_class_init (HdyClampClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
  GtkContainerClass *container_class = GTK_CONTAINER_CLASS (klass);

  object_class->get_property = hdy_clamp_get_property;
  object_class->set_property = hdy_clamp_set_property;

  widget_class->get_request_mode = hdy_clamp_get_request_mode;
  widget_class->get_preferred_width = hdy_clamp_get_preferred_width;
  widget_class->get_preferred_width_for_height = hdy_clamp_get_preferred_width_for_height;
  widget_class->get_preferred_height = hdy_clamp_get_preferred_height;
  widget_class->get_preferred_height_for_width = hdy_clamp_get_preferred_height_for_width;
  widget_class->get_preferred_height_and_baseline_for_width = hdy_clamp_get_preferred_height_and_baseline_for_width;
  widget_class->size_allocate = hdy_clamp_size_allocate;
  widget_class->draw = hdy_css_draw_bin;

  gtk_container_class_handle_border_width (container_class);

  g_object_class_override_property (object_class,
                                    PROP_ORIENTATION,
                                    "orientation");

  /**
   * HdyClamp:maximum-size: (attributes org.gtk.Property.get=hdy_clamp_get_maximum_size org.gtk.Property.set=hdy_clamp_set_maximum_size)
   *
   * The maximum size to allocate the children.
   *
   * It is the width if the clamp is horizontal, or the height if it is
   * vertical.
   *
   * Since: 1.0
   */
  props[PROP_MAXIMUM_SIZE] =
      g_param_spec_int ("maximum-size",
                        _("Maximum size"),
                        _("The maximum size allocated to the child"),
                        0, G_MAXINT, 600,
                        G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyClamp:tightening-threshold: (attributes org.gtk.Property.get=hdy_clamp_get_tightening_threshold org.gtk.Property.set=hdy_clamp_set_tightening_threshold)
   *
   * The size above which the child is clamped.
   *
   * Starting from this size, the layout will tighten its grip on the children,
   * slowly allocating less and less of the available size up to the maximum
   * allocated size. Below that threshold and below the maximum size, the
   * children will be allocated all the available size.
   *
   * If the threshold is greater than the maximum size to allocate to the
   * children, they will be allocated the whole size up to the maximum. If the
   * threshold is lower than the minimum size to allocate to the children, that
   * size will be used as the tightening threshold.
   *
   * Effectively, tightening the grip on a child before it reaches its maximum
   * size makes transitions to and from the maximum size smoother when resizing.
   *
   * Since: 1.0
   */
  props[PROP_TIGHTENING_THRESHOLD] =
      g_param_spec_int ("tightening-threshold",
                        _("Tightening threshold"),
                        _("The size from which the clamp will tighten its grip on the child"),
                        0, G_MAXINT, 400,
                        G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  g_object_class_install_properties (object_class, LAST_PROP, props);

  gtk_widget_class_set_css_name (widget_class, "clamp");
}

static void
hdy_clamp_init (HdyClamp *self)
{
  self->maximum_size = 600;
  self->tightening_threshold = 400;
}

/**
 * hdy_clamp_new:
 *
 * Creates a new `HdyClamp`.
 *
 * Returns: the newly created `HdyClamp`
 *
 * Since: 1.0
 */
GtkWidget *
hdy_clamp_new (void)
{
  return g_object_new (HDY_TYPE_CLAMP, NULL);
}

/**
 * hdy_clamp_get_maximum_size: (attributes org.gtk.Method.get_property=maximum-size)
 * @self: a clamp
 *
 * Gets the maximum size allocated to the children.
 *
 * Returns: the maximum size to allocate to the children
 *
 * Since: 1.0
 */
gint
hdy_clamp_get_maximum_size (HdyClamp *self)
{
  g_return_val_if_fail (HDY_IS_CLAMP (self), 0);

  return self->maximum_size;
}

/**
 * hdy_clamp_set_maximum_size: (attributes org.gtk.Method.set_property=maximum-size)
 * @self: a clamp
 * @maximum_size: the maximum size
 *
 * Sets the maximum size allocated to the children.
 *
 * Since: 1.0
 */
void
hdy_clamp_set_maximum_size (HdyClamp *self,
                            gint      maximum_size)
{
  g_return_if_fail (HDY_IS_CLAMP (self));

  if (self->maximum_size == maximum_size)
    return;

  self->maximum_size = maximum_size;

  gtk_widget_queue_resize (GTK_WIDGET (self));

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_MAXIMUM_SIZE]);
}

/**
 * hdy_clamp_get_tightening_threshold: (attributes org.gtk.Method.get_property=tightening-threshold)
 * @self: a clamp
 *
 * Gets the size above which the children are clamped.
 *
 * Returns: the size above which the children are clamped
 *
 * Since: 1.0
 */
gint
hdy_clamp_get_tightening_threshold (HdyClamp *self)
{
  g_return_val_if_fail (HDY_IS_CLAMP (self), 0);

  return self->tightening_threshold;
}

/**
 * hdy_clamp_set_tightening_threshold: (attributes org.gtk.Method.set_property=tightening-threshold)
 * @self: a clamp
 * @tightening_threshold: the tightening threshold
 *
 * Sets the size above which the children are clamped.
 *
 * Since: 1.0
 */
void
hdy_clamp_set_tightening_threshold (HdyClamp *self,
                                    gint      tightening_threshold)
{
  g_return_if_fail (HDY_IS_CLAMP (self));

  if (self->tightening_threshold == tightening_threshold)
    return;

  self->tightening_threshold = tightening_threshold;

  gtk_widget_queue_resize (GTK_WIDGET (self));

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_TIGHTENING_THRESHOLD]);
}
