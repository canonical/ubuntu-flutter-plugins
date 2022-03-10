/*
 * Copyright (C) 2018 Purism SPC
 * Copyright (C) 2019 Alexander Mikhaylenko <exalm7659@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "config.h"
#include <glib/gi18n-lib.h>

#include "gtkprogresstrackerprivate.h"
#include "hdy-animation-private.h"
#include "hdy-enums-private.h"
#include "hdy-stackable-box-private.h"
#include "hdy-shadow-helper-private.h"
#include "hdy-swipe-tracker-private.h"
#include "hdy-swipeable.h"

/**
 * HdyStackableBox:
 *
 * An adaptive container acting like a box or a stack.
 *
 * The `HdyStackableBox` object can arrange the widgets it manages like
 * [class@Gtk.Box] does or like a [class@Gtk.Stack] does, adapting to size
 * changes by switching between the two modes. These modes are named
 * respectively “unfoled” and “folded”.
 *
 * When there is enough space the children are displayed side by side, otherwise
 * only one is displayed. The threshold is dictated by the preferred minimum
 * sizes of the children.
 *
 * `HdyStackableBox` is used as an internal implementation of [class@Deck] and
 * [class@Leaflet].
 *
 * Since: 1.0
 */

/**
 * HdyStackableBoxTransitionType:
 * @HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER: Cover the old page or uncover the
 *   new page, sliding from or towards the end according to orientation, text
 *   direction and children order
 * @HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER: Uncover the new page or cover the
 *   old page, sliding from or towards the start according to orientation, text
 *   direction and children order
 * @HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE: Slide from left, right, up or down
 *   according to the orientation, text direction and the children order
 *
 * This enumeration value describes the possible transitions between modes and
 * children in a [class@StackableBox] widget.
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
  PROP_ORIENTATION,
  LAST_PROP,
};

#define HDY_FOLD_UNFOLDED FALSE
#define HDY_FOLD_FOLDED TRUE
#define HDY_FOLD_MAX 2
#define GTK_ORIENTATION_MAX 2

typedef struct _HdyStackableBoxChildInfo HdyStackableBoxChildInfo;

struct _HdyStackableBoxChildInfo
{
  GtkWidget *widget;
  GdkWindow *window;
  gchar *name;
  gboolean navigatable;

  /* Convenience storage for per-child temporary frequently computed values. */
  GtkAllocation alloc;
  GtkRequisition min;
  GtkRequisition nat;
  gboolean visible;
};

struct _HdyStackableBox
{
  GObject parent;

  GtkContainer *container;
  GtkContainerClass *klass;
  gboolean can_unfold;

  GList *children;
  /* It is probably cheaper to store and maintain a reversed copy of the
   * children list that to reverse the list every time we need to allocate or
   * draw children for RTL languages on a horizontal widget.
   */
  GList *children_reversed;
  HdyStackableBoxChildInfo *visible_child;
  HdyStackableBoxChildInfo *last_visible_child;

  gboolean folded;

  gboolean homogeneous[HDY_FOLD_MAX][GTK_ORIENTATION_MAX];

  GtkOrientation orientation;

  HdyStackableBoxTransitionType transition_type;

  HdySwipeTracker *tracker;

  struct {
    guint duration;

    gdouble current_pos;
    gdouble source_pos;
    gdouble target_pos;

    gdouble start_progress;
    gdouble end_progress;
    guint tick_id;
    GtkProgressTracker tracker;
  } mode_transition;

  /* Child transition variables. */
  struct {
    guint duration;

    gdouble progress;
    gdouble start_progress;
    gdouble end_progress;

    gboolean is_gesture_active;
    gboolean is_cancelled;

    guint tick_id;
    GtkProgressTracker tracker;
    gboolean first_frame_skipped;

    gboolean interpolate_size;
    gboolean can_swipe_back;
    gboolean can_swipe_forward;

    GtkPanDirection active_direction;
    gboolean is_direct_swipe;
    gint swipe_direction;
  } child_transition;

  HdyShadowHelper *shadow_helper;
};

static GParamSpec *props[LAST_PROP];

static gint HOMOGENEOUS_PROP[HDY_FOLD_MAX][GTK_ORIENTATION_MAX] = {
  { PROP_HHOMOGENEOUS_UNFOLDED, PROP_VHOMOGENEOUS_UNFOLDED},
  { PROP_HHOMOGENEOUS_FOLDED, PROP_VHOMOGENEOUS_FOLDED},
};

G_DEFINE_TYPE (HdyStackableBox, hdy_stackable_box, G_TYPE_OBJECT);

static void
free_child_info (HdyStackableBoxChildInfo *child_info)
{
  g_free (child_info->name);
  g_free (child_info);
}

G_DEFINE_AUTOPTR_CLEANUP_FUNC (HdyStackableBoxChildInfo, free_child_info)

static HdyStackableBoxChildInfo *
find_child_info_for_widget (HdyStackableBox *self,
                            GtkWidget       *widget)
{
  GList *children;
  HdyStackableBoxChildInfo *child_info;

  for (children = self->children; children; children = children->next) {
    child_info = children->data;

    if (child_info->widget == widget)
      return child_info;
  }

  return NULL;
}

static HdyStackableBoxChildInfo *
find_child_info_for_name (HdyStackableBox *self,
                          const gchar     *name)
{
  GList *children;
  HdyStackableBoxChildInfo *child_info;

  for (children = self->children; children; children = children->next) {
    child_info = children->data;

    if (g_strcmp0 (child_info->name, name) == 0)
      return child_info;
  }

  return NULL;
}

static GList *
get_directed_children (HdyStackableBox *self)
{
  return self->orientation == GTK_ORIENTATION_HORIZONTAL &&
         gtk_widget_get_direction (GTK_WIDGET (self->container)) == GTK_TEXT_DIR_RTL ?
         self->children_reversed : self->children;
}

static GtkPanDirection
get_pan_direction (HdyStackableBox *self,
                   gboolean         new_child_first)
{
  if (self->orientation == GTK_ORIENTATION_HORIZONTAL) {
    if (gtk_widget_get_direction (GTK_WIDGET (self->container)) == GTK_TEXT_DIR_RTL)
      return new_child_first ? GTK_PAN_DIRECTION_LEFT : GTK_PAN_DIRECTION_RIGHT;
    else
      return new_child_first ? GTK_PAN_DIRECTION_RIGHT : GTK_PAN_DIRECTION_LEFT;
  }
  else
    return new_child_first ? GTK_PAN_DIRECTION_DOWN : GTK_PAN_DIRECTION_UP;
}

static gint
get_child_window_x (HdyStackableBox          *self,
                    HdyStackableBoxChildInfo *child_info,
                    gint                      width)
{
  gboolean is_rtl;
  gint rtl_multiplier;

  if (!self->child_transition.is_gesture_active &&
      gtk_progress_tracker_get_state (&self->child_transition.tracker) == GTK_PROGRESS_STATE_AFTER)
    return 0;

  if (self->child_transition.active_direction != GTK_PAN_DIRECTION_LEFT &&
      self->child_transition.active_direction != GTK_PAN_DIRECTION_RIGHT)
    return 0;

  is_rtl = gtk_widget_get_direction (GTK_WIDGET (self->container)) == GTK_TEXT_DIR_RTL;
  rtl_multiplier = is_rtl ? -1 : 1;

  if ((self->child_transition.active_direction == GTK_PAN_DIRECTION_RIGHT) == is_rtl) {
    if ((self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER ||
         self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE) &&
        child_info == self->visible_child)
      return width * (1 - self->child_transition.progress) * rtl_multiplier;

    if ((self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER ||
         self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE) &&
        child_info == self->last_visible_child)
      return -width * self->child_transition.progress * rtl_multiplier;
  } else {
    if ((self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER ||
         self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE) &&
        child_info == self->visible_child)
      return -width * (1 - self->child_transition.progress) * rtl_multiplier;

    if ((self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER ||
         self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE) &&
        child_info == self->last_visible_child)
      return width * self->child_transition.progress * rtl_multiplier;
  }

  return 0;
}

static gint
get_child_window_y (HdyStackableBox          *self,
                    HdyStackableBoxChildInfo *child_info,
                    gint                      height)
{
  if (!self->child_transition.is_gesture_active &&
      gtk_progress_tracker_get_state (&self->child_transition.tracker) == GTK_PROGRESS_STATE_AFTER)
    return 0;

  if (self->child_transition.active_direction != GTK_PAN_DIRECTION_UP &&
      self->child_transition.active_direction != GTK_PAN_DIRECTION_DOWN)
    return 0;

  if (self->child_transition.active_direction == GTK_PAN_DIRECTION_UP) {
    if ((self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER ||
         self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE) &&
        child_info == self->visible_child)
      return height * (1 - self->child_transition.progress);

    if ((self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER ||
         self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE) &&
        child_info == self->last_visible_child)
      return -height * self->child_transition.progress;
  } else {
    if ((self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER ||
         self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE) &&
        child_info == self->visible_child)
      return -height * (1 - self->child_transition.progress);

    if ((self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER ||
         self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE) &&
        child_info == self->last_visible_child)
      return height * self->child_transition.progress;
  }

  return 0;
}

static void
hdy_stackable_box_child_progress_updated (HdyStackableBox *self)
{
  gtk_widget_queue_draw (GTK_WIDGET (self->container));

  if (!self->homogeneous[HDY_FOLD_FOLDED][GTK_ORIENTATION_VERTICAL] ||
      !self->homogeneous[HDY_FOLD_FOLDED][GTK_ORIENTATION_HORIZONTAL])
    gtk_widget_queue_resize (GTK_WIDGET (self->container));
  else
    gtk_widget_queue_allocate (GTK_WIDGET (self->container));

  if (!self->child_transition.is_gesture_active &&
      gtk_progress_tracker_get_state (&self->child_transition.tracker) == GTK_PROGRESS_STATE_AFTER) {
    if (self->child_transition.is_cancelled) {
      if (self->last_visible_child != NULL) {
        if (self->folded) {
          gtk_widget_set_child_visible (self->last_visible_child->widget, TRUE);
          gtk_widget_set_child_visible (self->visible_child->widget, FALSE);
        }
        self->visible_child = self->last_visible_child;
        self->last_visible_child = NULL;
      }

      self->child_transition.is_cancelled = FALSE;

      g_object_freeze_notify (G_OBJECT (self));
      g_object_notify_by_pspec (G_OBJECT (self), props[PROP_VISIBLE_CHILD]);
      g_object_notify_by_pspec (G_OBJECT (self), props[PROP_VISIBLE_CHILD_NAME]);
      g_object_thaw_notify (G_OBJECT (self));
    } else {
      if (self->last_visible_child != NULL) {
        if (self->folded)
          gtk_widget_set_child_visible (self->last_visible_child->widget, FALSE);
        self->last_visible_child = NULL;
      }
    }

    gtk_widget_queue_allocate (GTK_WIDGET (self->container));
    self->child_transition.swipe_direction = 0;
    hdy_shadow_helper_clear_cache (self->shadow_helper);
  }
}

static gboolean
hdy_stackable_box_child_transition_cb (GtkWidget     *widget,
                                       GdkFrameClock *frame_clock,
                                       gpointer       user_data)
{
  HdyStackableBox *self = HDY_STACKABLE_BOX (user_data);
  gdouble progress;

  if (self->child_transition.first_frame_skipped) {
    gtk_progress_tracker_advance_frame (&self->child_transition.tracker,
                                        gdk_frame_clock_get_frame_time (frame_clock));
    progress = gtk_progress_tracker_get_ease_out_cubic (&self->child_transition.tracker, FALSE);
    self->child_transition.progress =
      hdy_lerp (self->child_transition.start_progress,
                self->child_transition.end_progress, progress);
  } else
    self->child_transition.first_frame_skipped = TRUE;

  /* Finish animation early if not mapped anymore */
  if (!gtk_widget_get_mapped (widget))
    gtk_progress_tracker_finish (&self->child_transition.tracker);

  hdy_stackable_box_child_progress_updated (self);

  if (gtk_progress_tracker_get_state (&self->child_transition.tracker) == GTK_PROGRESS_STATE_AFTER) {
    self->child_transition.tick_id = 0;
    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CHILD_TRANSITION_RUNNING]);

    return FALSE;
  }

  return TRUE;
}

static void
hdy_stackable_box_schedule_child_ticks (HdyStackableBox *self)
{
  if (self->child_transition.tick_id == 0) {
    self->child_transition.tick_id =
      gtk_widget_add_tick_callback (GTK_WIDGET (self->container),
                                    hdy_stackable_box_child_transition_cb,
                                    self, NULL);
    if (!self->child_transition.is_gesture_active)
      g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CHILD_TRANSITION_RUNNING]);
  }
}

static void
hdy_stackable_box_unschedule_child_ticks (HdyStackableBox *self)
{
  if (self->child_transition.tick_id != 0) {
    gtk_widget_remove_tick_callback (GTK_WIDGET (self->container), self->child_transition.tick_id);
    self->child_transition.tick_id = 0;
    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CHILD_TRANSITION_RUNNING]);
  }
}

static void
hdy_stackable_box_stop_child_transition (HdyStackableBox *self)
{
  hdy_stackable_box_unschedule_child_ticks (self);
  gtk_progress_tracker_finish (&self->child_transition.tracker);
  if (self->last_visible_child != NULL) {
    gtk_widget_set_child_visible (self->last_visible_child->widget, FALSE);
    self->last_visible_child = NULL;
  }

  self->child_transition.swipe_direction = 0;
  hdy_shadow_helper_clear_cache (self->shadow_helper);
}

static void
hdy_stackable_box_start_child_transition (HdyStackableBox *self,
                                          guint            transition_duration,
                                          GtkPanDirection  transition_direction)
{
  GtkWidget *widget = GTK_WIDGET (self->container);

  if (gtk_widget_get_mapped (widget) &&
      ((hdy_get_enable_animations (widget) &&
        transition_duration != 0) ||
       self->child_transition.is_gesture_active) &&
      self->last_visible_child != NULL &&
      /* Don't animate child transition when a mode transition is ongoing. */
      self->mode_transition.tick_id == 0) {
    self->child_transition.active_direction = transition_direction;
    self->child_transition.first_frame_skipped = FALSE;
    self->child_transition.start_progress = 0;
    self->child_transition.end_progress = 1;
    self->child_transition.progress = 0;
    self->child_transition.is_cancelled = FALSE;

    if (!self->child_transition.is_gesture_active) {
      hdy_stackable_box_schedule_child_ticks (self);
      gtk_progress_tracker_start (&self->child_transition.tracker,
                                  transition_duration * 1000,
                                  0,
                                  1.0);
    }
  }
  else {
    hdy_stackable_box_unschedule_child_ticks (self);
    gtk_progress_tracker_finish (&self->child_transition.tracker);
  }

  hdy_stackable_box_child_progress_updated (self);
}

static void
set_visible_child_info (HdyStackableBox               *self,
                        HdyStackableBoxChildInfo      *new_visible_child,
                        HdyStackableBoxTransitionType  transition_type,
                        guint                          transition_duration,
                        gboolean                       emit_child_switched)
{
  GtkWidget *widget = GTK_WIDGET (self->container);
  GList *children;
  HdyStackableBoxChildInfo *child_info;
  GtkPanDirection transition_direction = GTK_PAN_DIRECTION_LEFT;

  /* If we are being destroyed, do not bother with transitions and
   * notifications.
   */
  if (gtk_widget_in_destruction (widget))
    return;

  /* If none, pick first visible. */
  if (new_visible_child == NULL) {
    for (children = self->children; children; children = children->next) {
      child_info = children->data;

      if (gtk_widget_get_visible (child_info->widget)) {
        new_visible_child = child_info;

        break;
      }
    }
  }

  if (new_visible_child == self->visible_child)
    return;

  /* FIXME Probably copied from Gtk Stack, should check whether it's needed. */
  /* toplevel = gtk_widget_get_toplevel (widget); */
  /* if (GTK_IS_WINDOW (toplevel)) { */
  /*   focus = gtk_window_get_focus (GTK_WINDOW (toplevel)); */
  /*   if (focus && */
  /*       self->visible_child && */
  /*       self->visible_child->widget && */
  /*       gtk_widget_is_ancestor (focus, self->visible_child->widget)) { */
  /*     contains_focus = TRUE; */

  /*     if (self->visible_child->last_focus) */
  /*       g_object_remove_weak_pointer (G_OBJECT (self->visible_child->last_focus), */
  /*                                     (gpointer *)&self->visible_child->last_focus); */
  /*     self->visible_child->last_focus = focus; */
  /*     g_object_add_weak_pointer (G_OBJECT (self->visible_child->last_focus), */
  /*                                (gpointer *)&self->visible_child->last_focus); */
  /*   } */
  /* } */

  if (self->last_visible_child)
    gtk_widget_set_child_visible (self->last_visible_child->widget, !self->folded);
  self->last_visible_child = NULL;

  hdy_shadow_helper_clear_cache (self->shadow_helper);

  if (self->visible_child && self->visible_child->widget) {
    if (gtk_widget_is_visible (widget))
      self->last_visible_child = self->visible_child;
    else
      gtk_widget_set_child_visible (self->visible_child->widget, !self->folded);
  }

  /* FIXME This comes from GtkStack and should be adapted. */
  /* hdy_stackable_box_accessible_update_visible_child (stack, */
  /*                                              self->visible_child ? self->visible_child->widget : NULL, */
  /*                                              new_visible_child ? new_visible_child->widget : NULL); */

  self->visible_child = new_visible_child;

  if (new_visible_child) {
    gtk_widget_set_child_visible (new_visible_child->widget, TRUE);

    /* FIXME This comes from GtkStack and should be adapted. */
    /* if (contains_focus) { */
    /*   if (new_visible_child->last_focus) */
    /*     gtk_widget_grab_focus (new_visible_child->last_focus); */
    /*   else */
    /*     gtk_widget_child_focus (new_visible_child->widget, GTK_DIR_TAB_FORWARD); */
    /* } */
  }

  if (new_visible_child == NULL || self->last_visible_child == NULL)
    transition_duration = 0;
  else {
    gboolean new_first = FALSE;
    for (children = self->children; children; children = children->next) {
      if (new_visible_child == children->data) {
        new_first = TRUE;

        break;
      }
      if (self->last_visible_child == children->data)
        break;
    }

    transition_direction = get_pan_direction (self, new_first);
  }

  if (self->folded) {
    if (self->homogeneous[HDY_FOLD_FOLDED][GTK_ORIENTATION_HORIZONTAL] &&
        self->homogeneous[HDY_FOLD_FOLDED][GTK_ORIENTATION_VERTICAL])
      gtk_widget_queue_allocate (widget);
    else
      gtk_widget_queue_resize (widget);

    hdy_stackable_box_start_child_transition (self, transition_duration, transition_direction);
  }

  if (emit_child_switched) {
    gint index = 0;

    for (children = self->children; children; children = children->next) {
      child_info = children->data;

      if (!child_info->navigatable)
        continue;

      if (child_info == new_visible_child)
        break;

      index++;
    }

    hdy_swipeable_emit_child_switched (HDY_SWIPEABLE (self->container), index,
                                       transition_duration);
  }

  g_object_freeze_notify (G_OBJECT (self));
  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_VISIBLE_CHILD]);
  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_VISIBLE_CHILD_NAME]);
  g_object_thaw_notify (G_OBJECT (self));
}

static void
hdy_stackable_box_set_position (HdyStackableBox *self,
                                gdouble          pos)
{
  self->mode_transition.current_pos = pos;

  gtk_widget_queue_allocate (GTK_WIDGET (self->container));
}

static void
hdy_stackable_box_mode_progress_updated (HdyStackableBox *self)
{
  if (gtk_progress_tracker_get_state (&self->mode_transition.tracker) == GTK_PROGRESS_STATE_AFTER)
    hdy_shadow_helper_clear_cache (self->shadow_helper);
}

static gboolean
hdy_stackable_box_mode_transition_cb (GtkWidget     *widget,
                                      GdkFrameClock *frame_clock,
                                      gpointer       user_data)
{
  HdyStackableBox *self = HDY_STACKABLE_BOX (user_data);
  gdouble ease;

  gtk_progress_tracker_advance_frame (&self->mode_transition.tracker,
                                      gdk_frame_clock_get_frame_time (frame_clock));
  ease = gtk_progress_tracker_get_ease_out_cubic (&self->mode_transition.tracker, FALSE);
  hdy_stackable_box_set_position (self,
                                  self->mode_transition.source_pos + (ease * (self->mode_transition.target_pos - self->mode_transition.source_pos)));

  hdy_stackable_box_mode_progress_updated (self);

  if (gtk_progress_tracker_get_state (&self->mode_transition.tracker) == GTK_PROGRESS_STATE_AFTER) {
    self->mode_transition.tick_id = 0;
    return FALSE;
  }

  return TRUE;
}

static void
hdy_stackable_box_start_mode_transition (HdyStackableBox *self,
                                         gdouble          target)
{
  GtkWidget *widget = GTK_WIDGET (self->container);

  if (self->mode_transition.target_pos == target)
    return;

  self->mode_transition.target_pos = target;
  /* FIXME PROP_REVEAL_CHILD needs to be implemented. */
  /* g_object_notify_by_pspec (G_OBJECT (revealer), props[PROP_REVEAL_CHILD]); */

  hdy_stackable_box_stop_child_transition (self);

  if (gtk_widget_get_mapped (widget) &&
      self->mode_transition.duration != 0 &&
      hdy_get_enable_animations (widget) &&
      self->can_unfold) {
    self->mode_transition.source_pos = self->mode_transition.current_pos;
    if (self->mode_transition.tick_id == 0)
      self->mode_transition.tick_id = gtk_widget_add_tick_callback (widget, hdy_stackable_box_mode_transition_cb, self, NULL);
    gtk_progress_tracker_start (&self->mode_transition.tracker,
                                self->mode_transition.duration * 1000,
                                0,
                                1.0);
  }
  else
    hdy_stackable_box_set_position (self, target);
}

/* FIXME Use this to stop the mode transition animation when it makes sense (see *
 * GtkRevealer for exmples).
 */
/* static void */
/* hdy_stackable_box_stop_mode_animation (HdyStackableBox *self) */
/* { */
/*   if (self->mode_transition.current_pos != self->mode_transition.target_pos) { */
/*     self->mode_transition.current_pos = self->mode_transition.target_pos; */
    /* g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CHILD_REVEALED]); */
/*   } */
/*   if (self->mode_transition.tick_id != 0) { */
/*     gtk_widget_remove_tick_callback (GTK_WIDGET (self->container), self->mode_transition.tick_id); */
/*     self->mode_transition.tick_id = 0; */
/*   } */
/* } */

/**
 * hdy_stackable_box_get_folded:
 * @self: a stackable box
 *
 * Gets whether @self is folded.
 *
 * Returns: whether @self is folded
 *
 * Since: 1.0
 */
gboolean
hdy_stackable_box_get_folded (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), FALSE);

  return self->folded;
}

static void
hdy_stackable_box_set_folded (HdyStackableBox *self,
                              gboolean         folded)
{
  GtkStyleContext *context;

  if (self->folded == folded)
    return;

  self->folded = folded;

  hdy_stackable_box_start_mode_transition (self, folded ? 0.0 : 1.0);

  if (self->can_unfold) {
    context = gtk_widget_get_style_context (GTK_WIDGET (self->container));
    if (folded) {
      gtk_style_context_add_class (context, "folded");
      gtk_style_context_remove_class (context, "unfolded");
    } else {
      gtk_style_context_remove_class (context, "folded");
      gtk_style_context_add_class (context, "unfolded");
    }
  }

  g_object_notify_by_pspec (G_OBJECT (self),
                            props[PROP_FOLDED]);
}

/**
 * hdy_stackable_box_set_homogeneous:
 * @self: a stackable box
 * @folded: the fold
 * @orientation: the orientation
 * @homogeneous: `TRUE` to make @self homogeneous
 *
 * Sets the [class@StackableBox] to be homogeneous or not for the given fold and
 * orientation. If it is homogeneous, the [class@StackableBox] will request the
 * same width or height for all its children depending on the orientation. If it
 * isn't and it is folded, the widget may change width or height when a
 * different child becomes visible.
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_homogeneous (HdyStackableBox *self,
                                   gboolean         folded,
                                   GtkOrientation   orientation,
                                   gboolean         homogeneous)
{
  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));

  folded = !!folded;
  homogeneous = !!homogeneous;

  if (self->homogeneous[folded][orientation] == homogeneous)
    return;

  self->homogeneous[folded][orientation] = homogeneous;

  if (gtk_widget_get_visible (GTK_WIDGET (self->container)))
    gtk_widget_queue_resize (GTK_WIDGET (self->container));

  g_object_notify_by_pspec (G_OBJECT (self), props[HOMOGENEOUS_PROP[folded][orientation]]);
}

/**
 * hdy_stackable_box_get_homogeneous:
 * @self: a stackable box
 * @folded: the fold
 * @orientation: the orientation
 *
 * Gets whether @self is homogeneous for the given fold and orientation. See
 * [method@StackableBox.set_homogeneous].
 *
 * Returns: whether @self is homogeneous for the given fold and orientation
 *
 * Since: 1.0
 */
gboolean
hdy_stackable_box_get_homogeneous (HdyStackableBox *self,
                                   gboolean         folded,
                                   GtkOrientation   orientation)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), FALSE);

  folded = !!folded;

  return self->homogeneous[folded][orientation];
}

/**
 * hdy_stackable_box_get_transition_type:
 * @self: a stackable box
 *
 * Gets the type of animation that will be used for transitions between modes
 * and children in @self.
 *
 * Returns: the current transition type of @self
 *
 * Since: 1.0
 */
HdyStackableBoxTransitionType
hdy_stackable_box_get_transition_type (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER);

  return self->transition_type;
}

/**
 * hdy_stackable_box_set_transition_type:
 * @self: a stackable box
 * @transition: the new transition type
 *
 * Sets the type of animation that will be used for transitions between modes
 * and children in @self.
 *
 * The transition type can be changed without problems at runtime, so it is
 * possible to change the animation based on the mode or child that is about to
 * become current.
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_transition_type (HdyStackableBox               *self,
                                       HdyStackableBoxTransitionType  transition)
{
  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));

  if (self->transition_type == transition)
    return;

  self->transition_type = transition;
  g_object_notify_by_pspec (G_OBJECT (self),
                            props[PROP_TRANSITION_TYPE]);
}

/**
 * hdy_stackable_box_get_mode_transition_duration:
 * @self: a stackable box
 *
 * Returns the amount of time that transitions between modes in @self will take.
 *
 * Returns: the mode transition duration, in milliseconds
 *
 * Since: 1.0
 */
guint
hdy_stackable_box_get_mode_transition_duration (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), 0);

  return self->mode_transition.duration;
}

/**
 * hdy_stackable_box_set_mode_transition_duration:
 * @self: a stackable box
 * @duration: the new duration, in milliseconds
 *
 * Sets the duration that transitions between modes in @self will take.
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_mode_transition_duration (HdyStackableBox *self,
                                                guint            duration)
{
  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));

  if (self->mode_transition.duration == duration)
    return;

  self->mode_transition.duration = duration;
  g_object_notify_by_pspec (G_OBJECT (self),
                            props[PROP_MODE_TRANSITION_DURATION]);
}

/**
 * hdy_stackable_box_get_child_transition_duration:
 * @self: a stackable box
 *
 * Gets the amount of time that transitions between children in @self will take.
 *
 * Returns: the child transition duration, in milliseconds
 *
 * Since: 1.0
 */
guint
hdy_stackable_box_get_child_transition_duration (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), 0);

  return self->child_transition.duration;
}

/**
 * hdy_stackable_box_set_child_transition_duration:
 * @self: a stackable box
 * @duration: the new duration, in milliseconds
 *
 * Sets the duration that transitions between children in @self will take.
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_child_transition_duration (HdyStackableBox *self,
                                                 guint            duration)
{
  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));

  if (self->child_transition.duration == duration)
    return;

  self->child_transition.duration = duration;
  g_object_notify_by_pspec (G_OBJECT (self),
                            props[PROP_CHILD_TRANSITION_DURATION]);
}

/**
 * hdy_stackable_box_get_visible_child:
 * @self: a stackable box
 *
 * Gets the visible child widget.
 *
 * Returns: (transfer none): the visible child widget
 *
 * Since: 1.0
 */
GtkWidget *
hdy_stackable_box_get_visible_child (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), NULL);

  if (self->visible_child == NULL)
    return NULL;

  return self->visible_child->widget;
}

/**
 * hdy_stackable_box_set_visible_child:
 * @self: a stackable box
 * @visible_child: the new child
 *
 * Makes @visible_child visible using a transition determined by
 * [property@StackableBox:transition-type] and
 * [property@StackableBox:child-transition-duration]. The transition can be
 * cancelled by the user, in which case visible child will change back to the
 * previously visible child.
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_visible_child (HdyStackableBox *self,
                                     GtkWidget       *visible_child)
{
  HdyStackableBoxChildInfo *child_info;
  gboolean contains_child;

  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));
  g_return_if_fail (GTK_IS_WIDGET (visible_child));

  child_info = find_child_info_for_widget (self, visible_child);
  contains_child = child_info != NULL;

  g_return_if_fail (contains_child);

  set_visible_child_info (self, child_info, self->transition_type, self->child_transition.duration, TRUE);
}

/**
 * hdy_stackable_box_get_visible_child_name:
 * @self: a stackable box
 *
 * Gets the name of the currently visible child widget.
 *
 * Returns: (transfer none): the name of the visible child
 *
 * Since: 1.0
 */
const gchar *
hdy_stackable_box_get_visible_child_name (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), NULL);

  if (self->visible_child == NULL)
    return NULL;

  return self->visible_child->name;
}

/**
 * hdy_stackable_box_set_visible_child_name:
 * @self: a stackable box
 * @name: the name of a child
 *
 * Makes the child with the name @name visible.
 *
 * See [method@StackableBox.set_visible_child] for more details.
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_visible_child_name (HdyStackableBox *self,
                                          const gchar     *name)
{
  HdyStackableBoxChildInfo *child_info;
  gboolean contains_child;

  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));
  g_return_if_fail (name != NULL);

  child_info = find_child_info_for_name (self, name);
  contains_child = child_info != NULL;

  g_return_if_fail (contains_child);

  set_visible_child_info (self, child_info, self->transition_type, self->child_transition.duration, TRUE);
}

/**
 * hdy_stackable_box_get_child_transition_running:
 * @self: a stackable box
 *
 * Returns whether @self is currently in a transition from one page to another.
 *
 * Returns: `TRUE` if the transition is currently running
 *
 * Since: 1.0
 */
gboolean
hdy_stackable_box_get_child_transition_running (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), FALSE);

  return (self->child_transition.tick_id != 0 ||
          self->child_transition.is_gesture_active);
}

/**
 * hdy_stackable_box_set_interpolate_size:
 * @self: a stackable box
 * @interpolate_size: the new value
 *
 * Sets whether or not @self will interpolate its size when changing the visible
 * child. If the [property@StackableBox:interpolate-size] property is set to
 * `TRUE`, @self will interpolate its size between the current one and the one
 * it'll take after changing the visible child, according to the set transition
 * duration.
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_interpolate_size (HdyStackableBox *self,
                                        gboolean         interpolate_size)
{
  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));

  interpolate_size = !!interpolate_size;

  if (self->child_transition.interpolate_size == interpolate_size)
    return;

  self->child_transition.interpolate_size = interpolate_size;
  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_INTERPOLATE_SIZE]);
}

/**
 * hdy_stackable_box_get_interpolate_size:
 * @self: a stackable box
 *
 * Returns whether the [class@StackableBox] is set up to interpolate between the
 * sizes of children on page switch.
 *
 * Returns: `TRUE` if child sizes are interpolated
 *
 * Since: 1.0
 */
gboolean
hdy_stackable_box_get_interpolate_size (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), FALSE);

  return self->child_transition.interpolate_size;
}

/**
 * hdy_stackable_box_set_can_swipe_back:
 * @self: a stackable box
 * @can_swipe_back: the new value
 *
 * Sets whether or not @self allows switching to the previous child that has
 * 'navigatable' child property set to `TRUE` via a swipe gesture
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_can_swipe_back (HdyStackableBox *self,
                                      gboolean         can_swipe_back)
{
  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));

  can_swipe_back = !!can_swipe_back;

  if (self->child_transition.can_swipe_back == can_swipe_back)
    return;

  self->child_transition.can_swipe_back = can_swipe_back;
  hdy_swipe_tracker_set_enabled (self->tracker, can_swipe_back || self->child_transition.can_swipe_forward);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CAN_SWIPE_BACK]);
}

/**
 * hdy_stackable_box_get_can_swipe_back:
 * @self: a stackable box
 *
 * Returns whether the [class@StackableBox] allows swiping to the previous
 * child.
 *
 * Returns: `TRUE` if back swipe is enabled
 *
 * Since: 1.0
 */
gboolean
hdy_stackable_box_get_can_swipe_back (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), FALSE);

  return self->child_transition.can_swipe_back;
}

/**
 * hdy_stackable_box_set_can_swipe_forward:
 * @self: a stackable box
 * @can_swipe_forward: the new value
 *
 * Sets whether or not @self allows switching to the next child that has
 * 'navigatable' child property set to `TRUE` via a swipe gesture.
 *
 * Since: 1.0
 */
void
hdy_stackable_box_set_can_swipe_forward (HdyStackableBox *self,
                                         gboolean         can_swipe_forward)
{
  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));

  can_swipe_forward = !!can_swipe_forward;

  if (self->child_transition.can_swipe_forward == can_swipe_forward)
    return;

  self->child_transition.can_swipe_forward = can_swipe_forward;
  hdy_swipe_tracker_set_enabled (self->tracker, self->child_transition.can_swipe_back || can_swipe_forward);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CAN_SWIPE_FORWARD]);
}

/**
 * hdy_stackable_box_get_can_swipe_forward:
 * @self: a stackable box
 *
 * Returns whether the [class@StackableBox] allows swiping to the next child.
 *
 * Returns: `TRUE` if forward swipe is enabled
 *
 * Since: 1.0
 */
gboolean
hdy_stackable_box_get_can_swipe_forward (HdyStackableBox *self)
{
  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), FALSE);

  return self->child_transition.can_swipe_forward;
}

static HdyStackableBoxChildInfo *
find_swipeable_child (HdyStackableBox        *self,
                      HdyNavigationDirection  direction)
{
  GList *children;
  HdyStackableBoxChildInfo *child = NULL;

  children = g_list_find (self->children, self->visible_child);

  if (children == NULL)
    return NULL;

  do {
    children = (direction == HDY_NAVIGATION_DIRECTION_BACK) ? children->prev : children->next;

    if (children == NULL)
      break;

    child = children->data;
  } while (child && !child->navigatable);

  return child;
}

/**
 * hdy_stackable_box_get_adjacent_child:
 * @self: a stackable box
 * @direction: the direction
 *
 * Gets the previous or next child that doesn't have 'navigatable' child
 * property set to `FALSE`, or `NULL` if it doesn't exist. This will be the same
 * widget [method@Stackablebox.navigate] will navigate to.
 *
 * Returns: (nullable) (transfer none): the previous or next navigatable child
 *
 * Since: 1.0
 */
GtkWidget *
hdy_stackable_box_get_adjacent_child (HdyStackableBox        *self,
                                      HdyNavigationDirection  direction)
{
  HdyStackableBoxChildInfo *child;

  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), NULL);

  child = find_swipeable_child (self, direction);

  if (!child)
    return NULL;

  return child->widget;
}

/**
 * hdy_stackable_box_navigate:
 * @self: a stackable box
 * @direction: the direction
 *
 * Switches to the previous or next child that doesn't have 'navigatable' child
 * property set to `FALSE`, similar to performing a swipe gesture to go in
 * @direction.
 *
 * Returns: `TRUE` if visible child was changed
 *
 * Since: 1.0
 */
gboolean
hdy_stackable_box_navigate (HdyStackableBox        *self,
                            HdyNavigationDirection  direction)
{
  HdyStackableBoxChildInfo *child;

  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), FALSE);

  child = find_swipeable_child (self, direction);

  if (!child)
    return FALSE;

  set_visible_child_info (self, child, self->transition_type, self->child_transition.duration, TRUE);

  return TRUE;
}

/**
 * hdy_stackable_box_get_child_by_name:
 * @self: a stackable box
 * @name: the name of the child to find
 *
 * Finds the child of @self with the name given as the argument. Returns `NULL`
 * if there is no child with this name.
 *
 * Returns: (transfer none) (nullable): the requested child of @self
 *
 * Since: 1.0
 */
GtkWidget *
hdy_stackable_box_get_child_by_name (HdyStackableBox *self,
                                     const gchar     *name)
{
  HdyStackableBoxChildInfo *child_info;

  g_return_val_if_fail (HDY_IS_STACKABLE_BOX (self), NULL);
  g_return_val_if_fail (name != NULL, NULL);

  child_info = find_child_info_for_name (self, name);

  return child_info ? child_info->widget : NULL;
}

static void
get_preferred_size (gint     *min,
                    gint     *nat,
                    gboolean  same_orientation,
                    gboolean  homogeneous_folded,
                    gboolean  homogeneous_unfolded,
                    gint      visible_children,
                    gdouble   visible_child_progress,
                    gint      sum_nat,
                    gint      max_min,
                    gint      max_nat,
                    gint      visible_min,
                    gint      last_visible_min)
{
  if (same_orientation) {
    *min = homogeneous_folded ?
             max_min :
             hdy_lerp (last_visible_min, visible_min, visible_child_progress);
    *nat = homogeneous_unfolded ?
             max_nat * visible_children :
             sum_nat;
  }
  else {
    *min = homogeneous_folded ?
             max_min :
             hdy_lerp (last_visible_min, visible_min, visible_child_progress);
    *nat = max_nat;
  }
}

void
hdy_stackable_box_measure (HdyStackableBox *self,
                           GtkOrientation   orientation,
                           int              for_size,
                           int             *minimum,
                           int             *natural,
                           int             *minimum_baseline,
                           int             *natural_baseline)
{
  GList *children;
  HdyStackableBoxChildInfo *child_info;
  gint visible_children;
  gdouble visible_child_progress;
  gint child_min, max_min, visible_min, last_visible_min;
  gint child_nat, max_nat, sum_nat;
  gboolean same_orientation;
  void (*get_preferred_size_static) (GtkWidget *widget,
                                     gint      *minimum_width,
                                     gint      *natural_width);
  void (*get_preferred_size_for_size) (GtkWidget *widget,
                                       gint       height,
                                       gint      *minimum_width,
                                       gint      *natural_width);

  get_preferred_size_static = orientation == GTK_ORIENTATION_HORIZONTAL ?
    gtk_widget_get_preferred_width :
    gtk_widget_get_preferred_height;
  get_preferred_size_for_size = orientation == GTK_ORIENTATION_HORIZONTAL ?
    gtk_widget_get_preferred_width_for_height :
    gtk_widget_get_preferred_height_for_width;

  visible_children = 0;
  child_min = max_min = visible_min = last_visible_min = 0;
  child_nat = max_nat = sum_nat = 0;
  for (children = self->children; children; children = children->next) {
    child_info = children->data;

    if (child_info->widget == NULL || !gtk_widget_get_visible (child_info->widget))
      continue;

    visible_children++;
    if (for_size < 0)
      get_preferred_size_static (child_info->widget,
                                 &child_min, &child_nat);
    else
      get_preferred_size_for_size (child_info->widget, for_size,
                                   &child_min, &child_nat);

    max_min = MAX (max_min, child_min);
    max_nat = MAX (max_nat, child_nat);
    sum_nat += child_nat;
  }

  if (self->visible_child != NULL) {
    if (for_size < 0)
      get_preferred_size_static (self->visible_child->widget,
                                 &visible_min, NULL);
    else
      get_preferred_size_for_size (self->visible_child->widget, for_size,
                                   &visible_min, NULL);
  }

  if (self->last_visible_child != NULL) {
    if (for_size < 0)
      get_preferred_size_static (self->last_visible_child->widget,
                                 &last_visible_min, NULL);
    else
      get_preferred_size_for_size (self->last_visible_child->widget, for_size,
                                   &last_visible_min, NULL);
  } else {
    last_visible_min = visible_min;
  }

  visible_child_progress = self->child_transition.interpolate_size ? self->child_transition.progress : 1.0;

  same_orientation =
    orientation == gtk_orientable_get_orientation (GTK_ORIENTABLE (self->container));

  get_preferred_size (minimum, natural,
                      same_orientation && self->can_unfold,
                      self->homogeneous[HDY_FOLD_FOLDED][orientation],
                      self->homogeneous[HDY_FOLD_UNFOLDED][orientation],
                      visible_children, visible_child_progress,
                      sum_nat, max_min, max_nat, visible_min, last_visible_min);
}

static void
hdy_stackable_box_size_allocate_folded (HdyStackableBox *self,
                                        GtkAllocation   *allocation)
{
  GtkWidget *widget = GTK_WIDGET (self->container);
  GtkOrientation orientation = gtk_orientable_get_orientation (GTK_ORIENTABLE (widget));
  GList *directed_children, *children;
  HdyStackableBoxChildInfo *child_info, *visible_child;
  gint start_size, end_size, visible_size;
  gint remaining_start_size, remaining_end_size, remaining_size;
  gint current_pad;
  gint max_child_size = 0;
  gint start_position, end_position;
  gboolean box_homogeneous;
  HdyStackableBoxTransitionType mode_transition_type;
  GtkTextDirection direction;
  gboolean under;

  directed_children = get_directed_children (self);
  visible_child = self->visible_child;

  if (!visible_child)
    return;

  for (children = directed_children; children; children = children->next) {
    child_info = children->data;

    if (!child_info->widget)
      continue;

    if (child_info->widget == visible_child->widget)
      continue;

    if (self->last_visible_child &&
        child_info->widget == self->last_visible_child->widget)
      continue;

    child_info->visible = FALSE;
  }

  if (visible_child->widget == NULL)
    return;

  /* FIXME is this needed? */
  if (!gtk_widget_get_visible (visible_child->widget)) {
    visible_child->visible = FALSE;

    return;
  }

  visible_child->visible = TRUE;

  mode_transition_type = self->transition_type;

  /* Avoid useless computations and allow visible child transitions. */
  if (self->mode_transition.current_pos <= 0.0) {
    /* Child transitions should be applied only when folded and when no mode
     * transition is ongoing.
     */
    for (children = directed_children; children; children = children->next) {
      child_info = children->data;

      if (child_info != visible_child &&
          child_info != self->last_visible_child) {
        child_info->visible = FALSE;

        continue;
      }

      child_info->alloc.x = get_child_window_x (self, child_info, allocation->width);
      child_info->alloc.y = get_child_window_y (self, child_info, allocation->height);
      child_info->alloc.width = allocation->width;
      child_info->alloc.height = allocation->height;
      child_info->visible = TRUE;
    }

    return;
  }

  /* Compute visible child size. */
  visible_size = orientation == GTK_ORIENTATION_HORIZONTAL ?
    MIN (allocation->width, MAX (visible_child->nat.width, (gint) (allocation->width * (1.0 - self->mode_transition.current_pos)))) :
    MIN (allocation->height, MAX (visible_child->nat.height, (gint) (allocation->height * (1.0 - self->mode_transition.current_pos))));

  /* Compute homogeneous box child size. */
  box_homogeneous = (self->homogeneous[HDY_FOLD_UNFOLDED][GTK_ORIENTATION_HORIZONTAL] && orientation == GTK_ORIENTATION_HORIZONTAL) ||
                    (self->homogeneous[HDY_FOLD_UNFOLDED][GTK_ORIENTATION_VERTICAL] && orientation == GTK_ORIENTATION_VERTICAL);
  if (box_homogeneous) {
    for (children = directed_children; children; children = children->next) {
      child_info = children->data;

      max_child_size = orientation == GTK_ORIENTATION_HORIZONTAL ?
        MAX (max_child_size, child_info->nat.width) :
        MAX (max_child_size, child_info->nat.height);
    }
  }

  /* Compute the start size. */
  start_size = 0;
  for (children = directed_children; children; children = children->next) {
    child_info = children->data;

    if (child_info == visible_child)
      break;

    start_size += orientation == GTK_ORIENTATION_HORIZONTAL ?
      (box_homogeneous ? max_child_size : child_info->nat.width) :
      (box_homogeneous ? max_child_size : child_info->nat.height);
  }

  /* Compute the end size. */
  end_size = 0;
  for (children = g_list_last (directed_children); children; children = children->prev) {
    child_info = children->data;

    if (child_info == visible_child)
      break;

    end_size += orientation == GTK_ORIENTATION_HORIZONTAL ?
      (box_homogeneous ? max_child_size : child_info->nat.width) :
      (box_homogeneous ? max_child_size : child_info->nat.height);
  }

  /* Compute pads. */
  remaining_size = orientation == GTK_ORIENTATION_HORIZONTAL ?
    allocation->width - visible_size :
    allocation->height - visible_size;
  remaining_start_size = (gint) (remaining_size * ((gdouble) start_size / (gdouble) (start_size + end_size)));
  remaining_end_size = remaining_size - remaining_start_size;

  /* Store start and end allocations. */
  switch (orientation) {
  case GTK_ORIENTATION_HORIZONTAL:
    direction = gtk_widget_get_direction (GTK_WIDGET (self->container));
    under = (mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER && direction == GTK_TEXT_DIR_LTR) ||
            (mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER && direction == GTK_TEXT_DIR_RTL);
    start_position = under ? 0 : remaining_start_size - start_size;
    self->mode_transition.start_progress = under ? (gdouble) remaining_size / start_size : 1;
    under = (mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER && direction == GTK_TEXT_DIR_LTR) ||
            (mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER && direction == GTK_TEXT_DIR_RTL);
    end_position = under ? allocation->width - end_size : remaining_start_size + visible_size;
    self->mode_transition.end_progress = under ? (gdouble) remaining_end_size / end_size : 1;
    break;
  case GTK_ORIENTATION_VERTICAL:
    under = mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER;
    start_position = under ? 0 : remaining_start_size - start_size;
    self->mode_transition.start_progress = under ? (gdouble) remaining_size / start_size : 1;
    under = mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER;
    end_position = remaining_start_size + visible_size;
    self->mode_transition.end_progress = under ? (gdouble) remaining_end_size / end_size : 1;
    break;
  default:
    g_assert_not_reached ();
  }

  /* Allocate visible child. */
  if (orientation == GTK_ORIENTATION_HORIZONTAL) {
    visible_child->alloc.width = visible_size;
    visible_child->alloc.height = allocation->height;
    visible_child->alloc.x = remaining_start_size;
    visible_child->alloc.y = 0;
    visible_child->visible = TRUE;
  }
  else {
    visible_child->alloc.width = allocation->width;
    visible_child->alloc.height = visible_size;
    visible_child->alloc.x = 0;
    visible_child->alloc.y = remaining_start_size;
    visible_child->visible = TRUE;
  }

  /* Allocate starting children. */
  current_pad = start_position;

  for (children = directed_children; children; children = children->next) {
    child_info = children->data;

    if (child_info == visible_child)
      break;

    if (orientation == GTK_ORIENTATION_HORIZONTAL) {
      child_info->alloc.width = box_homogeneous ?
        max_child_size :
        child_info->nat.width;
      child_info->alloc.height = allocation->height;
      child_info->alloc.x = current_pad;
      child_info->alloc.y = 0;
      child_info->visible = child_info->alloc.x + child_info->alloc.width > 0;

      current_pad += child_info->alloc.width;
    }
    else {
      child_info->alloc.width = allocation->width;
      child_info->alloc.height = box_homogeneous ?
        max_child_size :
        child_info->nat.height;
      child_info->alloc.x = 0;
      child_info->alloc.y = current_pad;
      child_info->visible = child_info->alloc.y + child_info->alloc.height > 0;

      current_pad += child_info->alloc.height;
    }
  }

  /* Allocate ending children. */
  current_pad = end_position;

  if (!children || !children->next)
    return;

  for (children = children->next; children; children = children->next) {
    child_info = children->data;

    if (orientation == GTK_ORIENTATION_HORIZONTAL) {
      child_info->alloc.width = box_homogeneous ?
        max_child_size :
        child_info->nat.width;
      child_info->alloc.height = allocation->height;
      child_info->alloc.x = current_pad;
      child_info->alloc.y = 0;
      child_info->visible = child_info->alloc.x < allocation->width;

      current_pad += child_info->alloc.width;
    }
    else {
      child_info->alloc.width = allocation->width;
      child_info->alloc.height = box_homogeneous ?
        max_child_size :
        child_info->nat.height;
      child_info->alloc.x = 0;
      child_info->alloc.y = current_pad;
      child_info->visible = child_info->alloc.y < allocation->height;

      current_pad += child_info->alloc.height;
    }
  }
}

static void
hdy_stackable_box_size_allocate_unfolded (HdyStackableBox *self,
                                          GtkAllocation   *allocation)
{
  GtkWidget *widget = GTK_WIDGET (self->container);
  GtkOrientation orientation = gtk_orientable_get_orientation (GTK_ORIENTABLE (widget));
  GtkAllocation remaining_alloc;
  GList *directed_children, *children;
  HdyStackableBoxChildInfo *child_info, *visible_child;
  gint homogeneous_size = 0, min_size, extra_size;
  gint per_child_extra, n_extra_widgets;
  gint n_visible_children, n_expand_children;
  gint start_pad = 0, end_pad = 0;
  gboolean box_homogeneous;
  HdyStackableBoxTransitionType mode_transition_type;
  GtkTextDirection direction;
  gboolean under;

  visible_child = self->visible_child;
  if (!visible_child)
    return;

  directed_children = get_directed_children (self);

  box_homogeneous = (self->homogeneous[HDY_FOLD_UNFOLDED][GTK_ORIENTATION_HORIZONTAL] && orientation == GTK_ORIENTATION_HORIZONTAL) ||
                    (self->homogeneous[HDY_FOLD_UNFOLDED][GTK_ORIENTATION_VERTICAL] && orientation == GTK_ORIENTATION_VERTICAL);

  n_visible_children = n_expand_children = 0;
  for (children = directed_children; children; children = children->next) {
    child_info = children->data;

    child_info->visible = child_info->widget != NULL && gtk_widget_get_visible (child_info->widget);

    if (child_info->visible) {
      n_visible_children++;
      if (gtk_widget_compute_expand (child_info->widget, orientation))
        n_expand_children++;
    }
    else {
      child_info->min.width = child_info->min.height = 0;
      child_info->nat.width = child_info->nat.height = 0;
    }
  }

  /* Compute repartition of extra space. */

  if (box_homogeneous) {
    if (orientation == GTK_ORIENTATION_HORIZONTAL) {
      homogeneous_size = n_visible_children > 0 ? allocation->width / n_visible_children : 0;
      n_expand_children = n_visible_children > 0 ? allocation->width % n_visible_children : 0;
      min_size = allocation->width - n_expand_children;
    }
    else {
      homogeneous_size = n_visible_children > 0 ? allocation->height / n_visible_children : 0;
      n_expand_children = n_visible_children > 0 ? allocation->height % n_visible_children : 0;
      min_size = allocation->height - n_expand_children;
    }
  }
  else {
    min_size = 0;
    if (orientation == GTK_ORIENTATION_HORIZONTAL) {
      for (children = directed_children; children; children = children->next) {
        child_info = children->data;

        min_size += child_info->nat.width;
      }
    }
    else {
      for (children = directed_children; children; children = children->next) {
        child_info = children->data;

        min_size += child_info->nat.height;
      }
    }
  }

  remaining_alloc.x = 0;
  remaining_alloc.y = 0;
  remaining_alloc.width = allocation->width;
  remaining_alloc.height = allocation->height;

  extra_size = orientation == GTK_ORIENTATION_HORIZONTAL ?
    remaining_alloc.width - min_size :
    remaining_alloc.height - min_size;

  per_child_extra = 0, n_extra_widgets = 0;
  if (n_expand_children > 0) {
    per_child_extra = extra_size / n_expand_children;
    n_extra_widgets = extra_size % n_expand_children;
  }

  /* Compute children allocation */
  for (children = directed_children; children; children = children->next) {
    child_info = children->data;

    if (!child_info->visible)
      continue;

    child_info->alloc.x = remaining_alloc.x;
    child_info->alloc.y = remaining_alloc.y;

    if (orientation == GTK_ORIENTATION_HORIZONTAL) {
      if (box_homogeneous) {
        child_info->alloc.width = homogeneous_size;
        if (n_extra_widgets > 0) {
          child_info->alloc.width++;
          n_extra_widgets--;
        }
      }
      else {
        child_info->alloc.width = child_info->nat.width;
        if (gtk_widget_compute_expand (child_info->widget, orientation)) {
          child_info->alloc.width += per_child_extra;
          if (n_extra_widgets > 0) {
            child_info->alloc.width++;
            n_extra_widgets--;
          }
        }
      }
      child_info->alloc.height = remaining_alloc.height;

      remaining_alloc.x += child_info->alloc.width;
      remaining_alloc.width -= child_info->alloc.width;
    }
    else {
      if (box_homogeneous) {
        child_info->alloc.height = homogeneous_size;
        if (n_extra_widgets > 0) {
          child_info->alloc.height++;
          n_extra_widgets--;
        }
      }
      else {
        child_info->alloc.height = child_info->nat.height;
        if (gtk_widget_compute_expand (child_info->widget, orientation)) {
          child_info->alloc.height += per_child_extra;
          if (n_extra_widgets > 0) {
            child_info->alloc.height++;
            n_extra_widgets--;
          }
        }
      }
      child_info->alloc.width = remaining_alloc.width;

      remaining_alloc.y += child_info->alloc.height;
      remaining_alloc.height -= child_info->alloc.height;
    }
  }

  /* Apply animations. */

  if (orientation == GTK_ORIENTATION_HORIZONTAL) {
    start_pad = (gint) ((visible_child->alloc.x) * (1.0 - self->mode_transition.current_pos));
    end_pad = (gint) ((allocation->width - (visible_child->alloc.x + visible_child->alloc.width)) * (1.0 - self->mode_transition.current_pos));
  }
  else {
    start_pad = (gint) ((visible_child->alloc.y) * (1.0 - self->mode_transition.current_pos));
    end_pad = (gint) ((allocation->height - (visible_child->alloc.y + visible_child->alloc.height)) * (1.0 - self->mode_transition.current_pos));
  }

  mode_transition_type = self->transition_type;
  direction = gtk_widget_get_direction (GTK_WIDGET (self->container));

  if (orientation == GTK_ORIENTATION_HORIZONTAL)
    under = (mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER && direction == GTK_TEXT_DIR_LTR) ||
            (mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER && direction == GTK_TEXT_DIR_RTL);
  else
    under = mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER;
  for (children = directed_children; children; children = children->next) {
    child_info = children->data;

    if (child_info == visible_child)
      break;

    if (!child_info->visible)
      continue;

    if (under)
      continue;

    if (orientation == GTK_ORIENTATION_HORIZONTAL)
      child_info->alloc.x -= start_pad;
    else
      child_info->alloc.y -= start_pad;
  }

  self->mode_transition.start_progress = under ? self->mode_transition.current_pos : 1;

  if (orientation == GTK_ORIENTATION_HORIZONTAL)
    under = (mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER && direction == GTK_TEXT_DIR_LTR) ||
            (mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER && direction == GTK_TEXT_DIR_RTL);
  else
    under = mode_transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER;
  for (children = g_list_last (directed_children); children; children = children->prev) {
    child_info = children->data;

    if (child_info == visible_child)
      break;

    if (!child_info->visible)
      continue;

    if (under)
      continue;

    if (orientation == GTK_ORIENTATION_HORIZONTAL)
      child_info->alloc.x += end_pad;
    else
      child_info->alloc.y += end_pad;
  }

  self->mode_transition.end_progress = under ? self->mode_transition.current_pos : 1;

  if (orientation == GTK_ORIENTATION_HORIZONTAL) {
    visible_child->alloc.x -= start_pad;
    visible_child->alloc.width += start_pad + end_pad;
  }
  else {
    visible_child->alloc.y -= start_pad;
    visible_child->alloc.height += start_pad + end_pad;
  }
}

static HdyStackableBoxChildInfo *
get_top_overlap_child (HdyStackableBox *self)
{
  gboolean is_rtl, start;

  if (!self->last_visible_child)
    return self->visible_child;

  is_rtl = gtk_widget_get_direction (GTK_WIDGET (self->container)) == GTK_TEXT_DIR_RTL;

  start = (self->child_transition.active_direction == GTK_PAN_DIRECTION_LEFT && !is_rtl) ||
          (self->child_transition.active_direction == GTK_PAN_DIRECTION_RIGHT && is_rtl) ||
           self->child_transition.active_direction == GTK_PAN_DIRECTION_UP;

  switch (self->transition_type) {
  case HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE:
    // Nothing overlaps in this case
    return NULL;
  case HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER:
    return start ? self->visible_child : self->last_visible_child;
  case HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER:
    return start ? self->last_visible_child : self->visible_child;
  default:
    g_assert_not_reached ();
  }
}

static void
restack_windows (HdyStackableBox *self)
{
  HdyStackableBoxChildInfo *child_info, *overlap_child;
  GList *l;

  overlap_child = get_top_overlap_child (self);

  switch (self->transition_type) {
  case HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE:
    // Nothing overlaps in this case
    return;
  case HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER:
    for (l = g_list_last (self->children); l; l = l->prev) {
      child_info = l->data;

      if (child_info->window)
        gdk_window_raise (child_info->window);

      if (child_info == overlap_child)
        break;
    }

    break;
  case HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER:
    for (l = self->children; l; l = l->next) {
      child_info = l->data;

      if (child_info->window)
        gdk_window_raise (child_info->window);

      if (child_info == overlap_child)
        break;
    }

    break;
  default:
    g_assert_not_reached ();
  }
}

void
hdy_stackable_box_size_allocate (HdyStackableBox *self,
                                 GtkAllocation   *allocation)
{
  GtkWidget *widget = GTK_WIDGET (self->container);
  GtkOrientation orientation = gtk_orientable_get_orientation (GTK_ORIENTABLE (widget));
  GList *directed_children, *children;
  HdyStackableBoxChildInfo *child_info;
  gboolean folded;

  directed_children = get_directed_children (self);

  gtk_widget_set_allocation (widget, allocation);

  if (gtk_widget_get_realized (widget)) {
    gdk_window_move_resize (gtk_widget_get_window (widget),
                            allocation->x, allocation->y,
                            allocation->width, allocation->height);
  }

  /* Prepare children information. */
  for (children = directed_children; children; children = children->next) {
    child_info = children->data;

    gtk_widget_get_preferred_size (child_info->widget, &child_info->min, &child_info->nat);
    child_info->alloc.x = child_info->alloc.y = child_info->alloc.width = child_info->alloc.height = 0;
    child_info->visible = FALSE;
  }

  /* Check whether the children should be stacked or not. */
  if (self->can_unfold) {
    gint nat_box_size = 0, nat_max_size = 0, visible_children = 0;

    if (orientation == GTK_ORIENTATION_HORIZONTAL) {

      for (children = directed_children; children; children = children->next) {
        child_info = children->data;

        /* FIXME Check the child is visible. */
        if (!child_info->widget)
          continue;

        if (child_info->nat.width <= 0)
          continue;

        nat_box_size += child_info->nat.width;
        nat_max_size = MAX (nat_max_size, child_info->nat.width);
        visible_children++;
      }
      if (self->homogeneous[HDY_FOLD_UNFOLDED][GTK_ORIENTATION_HORIZONTAL])
        nat_box_size = nat_max_size * visible_children;
      folded = visible_children > 1 && allocation->width < nat_box_size;
    }
    else {
      for (children = directed_children; children; children = children->next) {
        child_info = children->data;

        /* FIXME Check the child is visible. */
        if (!child_info->widget)
          continue;

        if (child_info->nat.height <= 0)
          continue;

        nat_box_size += child_info->nat.height;
        nat_max_size = MAX (nat_max_size, child_info->nat.height);
        visible_children++;
      }
      if (self->homogeneous[HDY_FOLD_UNFOLDED][GTK_ORIENTATION_VERTICAL])
        nat_box_size = nat_max_size * visible_children;
      folded = visible_children > 1 && allocation->height < nat_box_size;
    }
  } else {
    folded = TRUE;
  }

  hdy_stackable_box_set_folded (self, folded);

  /* Allocate size to the children. */
  if (folded)
    hdy_stackable_box_size_allocate_folded (self, allocation);
  else
    hdy_stackable_box_size_allocate_unfolded (self, allocation);

  /* Apply visibility and allocation. */
  for (children = directed_children; children; children = children->next) {
    GtkAllocation alloc;

    child_info = children->data;

    gtk_widget_set_child_visible (child_info->widget, child_info->visible);

    if (child_info->window &&
        child_info->visible != gdk_window_is_visible (child_info->window)) {
      if (child_info->visible)
        gdk_window_show (child_info->window);
      else
        gdk_window_hide (child_info->window);
    }

    if (!child_info->visible)
      continue;

    if (child_info->window)
      gdk_window_move_resize (child_info->window,
                              child_info->alloc.x,
                              child_info->alloc.y,
                              child_info->alloc.width,
                              child_info->alloc.height);

    alloc.x = 0;
    alloc.y = 0;
    alloc.width = child_info->alloc.width;
    alloc.height = child_info->alloc.height;
    gtk_widget_size_allocate (child_info->widget, &alloc);

    if (gtk_widget_get_realized (widget))
      gtk_widget_show (child_info->widget);
  }

  restack_windows (self);
}

gboolean
hdy_stackable_box_draw (HdyStackableBox *self,
                        cairo_t         *cr)
{
  GtkWidget *widget = GTK_WIDGET (self->container);
  GList *stacked_children, *l;
  HdyStackableBoxChildInfo *child_info, *overlap_child;
  gboolean is_transition;
  gboolean is_vertical;
  gboolean is_rtl;
  gboolean is_over;
  GtkAllocation shadow_rect;
  gdouble shadow_progress, mode_progress;
  GtkPanDirection shadow_direction;

  overlap_child = get_top_overlap_child (self);

  is_transition = self->child_transition.is_gesture_active ||
                  gtk_progress_tracker_get_state (&self->child_transition.tracker) != GTK_PROGRESS_STATE_AFTER ||
                  gtk_progress_tracker_get_state (&self->mode_transition.tracker) != GTK_PROGRESS_STATE_AFTER;

  if (!is_transition ||
      self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE ||
      !overlap_child) {
    for (l = self->children; l; l = l->next) {
      child_info = l->data;

      if (!gtk_cairo_should_draw_window (cr, child_info->window))
        continue;

      gtk_container_propagate_draw (self->container,
                                    child_info->widget,
                                    cr);
    }

    return GDK_EVENT_PROPAGATE;
  }

  stacked_children = self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER ?
                     self->children_reversed : self->children;

  is_vertical = gtk_orientable_get_orientation (GTK_ORIENTABLE (widget)) == GTK_ORIENTATION_VERTICAL;
  is_rtl = gtk_widget_get_direction (widget) == GTK_TEXT_DIR_RTL;
  is_over = self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER;

  cairo_save (cr);

  shadow_rect.x = 0;
  shadow_rect.y = 0;
  shadow_rect.width = gtk_widget_get_allocated_width (widget);
  shadow_rect.height = gtk_widget_get_allocated_height (widget);

  if (is_vertical) {
    if (!is_over) {
      shadow_rect.y = overlap_child->alloc.y + overlap_child->alloc.height;
      shadow_rect.height -= shadow_rect.y;
      shadow_direction = GTK_PAN_DIRECTION_UP;
      mode_progress = self->mode_transition.end_progress;
    } else {
      shadow_rect.height = overlap_child->alloc.y;
      shadow_direction = GTK_PAN_DIRECTION_DOWN;
      mode_progress = self->mode_transition.start_progress;
    }
  } else {
    if (is_over == is_rtl) {
      shadow_rect.x = overlap_child->alloc.x + overlap_child->alloc.width;
      shadow_rect.width -= shadow_rect.x;
      shadow_direction = GTK_PAN_DIRECTION_LEFT;
      mode_progress = self->mode_transition.end_progress;
    } else {
      shadow_rect.width = overlap_child->alloc.x;
      shadow_direction = GTK_PAN_DIRECTION_RIGHT;
      mode_progress = self->mode_transition.start_progress;
    }
  }

  if (gtk_progress_tracker_get_state (&self->mode_transition.tracker) != GTK_PROGRESS_STATE_AFTER) {
    shadow_progress = mode_progress;
  } else {
    GtkPanDirection direction = self->child_transition.active_direction;
    GtkPanDirection left_or_right = is_rtl ? GTK_PAN_DIRECTION_RIGHT : GTK_PAN_DIRECTION_LEFT;
    gint width = gtk_widget_get_allocated_width (widget);
    gint height = gtk_widget_get_allocated_height (widget);

    if (direction == GTK_PAN_DIRECTION_UP || direction == left_or_right)
      shadow_progress = self->child_transition.progress;
    else
      shadow_progress = 1 - self->child_transition.progress;

    if (is_over)
      shadow_progress = 1 - shadow_progress;

    /* Normalize the shadow rect size so that we can cache the shadow */
    if (shadow_direction == GTK_PAN_DIRECTION_RIGHT)
      shadow_rect.x -= (width - shadow_rect.width);
    else if (shadow_direction == GTK_PAN_DIRECTION_DOWN)
      shadow_rect.y -= (height - shadow_rect.height);

    shadow_rect.width = width;
    shadow_rect.height = height;
  }

  cairo_rectangle (cr, shadow_rect.x, shadow_rect.y, shadow_rect.width, shadow_rect.height);
  cairo_clip (cr);

  for (l = stacked_children; l; l = l->next) {
    child_info = l->data;

    if (!gtk_cairo_should_draw_window (cr, child_info->window))
      continue;

    if (child_info == overlap_child)
      cairo_restore (cr);

    gtk_container_propagate_draw (self->container,
                                  child_info->widget,
                                  cr);
  }

  if (shadow_progress > 0) {
    cairo_save (cr);
    cairo_translate (cr, shadow_rect.x, shadow_rect.y);
    hdy_shadow_helper_draw_shadow (self->shadow_helper, cr,
                                   shadow_rect.width, shadow_rect.height,
                                   shadow_progress, shadow_direction);
    cairo_restore (cr);
  }

  return GDK_EVENT_PROPAGATE;
}

static void
update_tracker_orientation (HdyStackableBox *self)
{
  gboolean reverse;

  reverse = (self->orientation == GTK_ORIENTATION_HORIZONTAL &&
             gtk_widget_get_direction (GTK_WIDGET (self->container)) == GTK_TEXT_DIR_RTL);

  g_object_set (self->tracker,
                "orientation", self->orientation,
                "reversed", reverse,
                NULL);
}

void
hdy_stackable_box_direction_changed (HdyStackableBox  *self,
                                     GtkTextDirection  previous_direction)
{
  update_tracker_orientation (self);
}

static void
hdy_stackable_box_child_visibility_notify_cb (GObject    *obj,
                                              GParamSpec *pspec,
                                              gpointer    user_data)
{
  HdyStackableBox *self = HDY_STACKABLE_BOX (user_data);
  GtkWidget *widget = GTK_WIDGET (obj);
  HdyStackableBoxChildInfo *child_info;

  child_info = find_child_info_for_widget (self, widget);

  if (self->visible_child == NULL && gtk_widget_get_visible (widget))
    set_visible_child_info (self, child_info, self->transition_type, self->child_transition.duration, TRUE);
  else if (self->visible_child == child_info && !gtk_widget_get_visible (widget))
    set_visible_child_info (self, NULL, self->transition_type, self->child_transition.duration, TRUE);

  if (child_info == self->last_visible_child) {
    gtk_widget_set_child_visible (self->last_visible_child->widget, !self->folded);
    self->last_visible_child = NULL;
  }
}

static void
register_window (HdyStackableBox          *self,
                 HdyStackableBoxChildInfo *child)
{
  GtkWidget *widget = GTK_WIDGET (self->container);
  GdkWindowAttr attributes = { 0 };
  GdkWindowAttributesType attributes_mask;

  attributes.x = child->alloc.x;
  attributes.y = child->alloc.y;
  attributes.width = child->alloc.width;
  attributes.height = child->alloc.height;
  attributes.window_type = GDK_WINDOW_CHILD;
  attributes.wclass = GDK_INPUT_OUTPUT;
  attributes.visual = gtk_widget_get_visual (widget);
  attributes.event_mask = gtk_widget_get_events (widget);
  attributes_mask = (GDK_WA_X | GDK_WA_Y) | GDK_WA_VISUAL;

  attributes.event_mask = gtk_widget_get_events (widget) |
                          gtk_widget_get_events (child->widget);

  child->window = gdk_window_new (gtk_widget_get_window (widget), &attributes, attributes_mask);
  gtk_widget_register_window (widget, child->window);

  gtk_widget_set_parent_window (child->widget, child->window);

  gdk_window_show (child->window);
}

static void
unregister_window (HdyStackableBox          *self,
                   HdyStackableBoxChildInfo *child)
{
  GtkWidget *widget = GTK_WIDGET (self->container);

  if (!child->window)
    return;

  gtk_widget_unregister_window (widget, child->window);
  gdk_window_destroy (child->window);
  child->window = NULL;
}

void
hdy_stackable_box_add (HdyStackableBox *self,
                       GtkWidget       *widget)
{
  if (self->children == NULL) {
    hdy_stackable_box_insert_child_after (self, widget, NULL);
  } else {
    HdyStackableBoxChildInfo *last_child_info = g_list_last (self->children)->data;

    hdy_stackable_box_insert_child_after (self, widget, last_child_info->widget);
  }
}

void
hdy_stackable_box_remove (HdyStackableBox *self,
                          GtkWidget       *widget)
{
  g_autoptr (HdyStackableBoxChildInfo) child_info = find_child_info_for_widget (self, widget);
  gboolean contains_child = child_info != NULL;

  g_return_if_fail (contains_child);

  self->children = g_list_remove (self->children, child_info);
  self->children_reversed = g_list_remove (self->children_reversed, child_info);

  g_signal_handlers_disconnect_by_func (widget,
                                        hdy_stackable_box_child_visibility_notify_cb,
                                        self);

  if (hdy_stackable_box_get_visible_child (self) == widget)
    set_visible_child_info (self, NULL, self->transition_type, self->child_transition.duration, TRUE);

  if (child_info == self->last_visible_child)
    self->last_visible_child = NULL;

  if (gtk_widget_get_visible (widget))
    gtk_widget_queue_resize (GTK_WIDGET (self->container));

  unregister_window (self, child_info);

  gtk_widget_unparent (widget);
}

void
hdy_stackable_box_forall (HdyStackableBox *self,
                          gboolean         include_internals,
                          GtkCallback      callback,
                          gpointer         callback_data)
{
  /* This shallow copy is needed when the callback changes the list while we are
   * looping through it, for example by calling hdy_stackable_box_remove() on all
   * children when destroying the HdyStackableBox_private_offset.
   */
  g_autoptr (GList) children_copy = g_list_copy (self->children);
  GList *children;
  HdyStackableBoxChildInfo *child_info;

  for (children = children_copy; children; children = children->next) {
    child_info = children->data;

    (* callback) (child_info->widget, callback_data);
  }

  g_list_free (self->children_reversed);
  self->children_reversed = g_list_copy (self->children);
  self->children_reversed = g_list_reverse (self->children_reversed);
}

static void
hdy_stackable_box_get_property (GObject    *object,
                                guint       prop_id,
                                GValue     *value,
                                GParamSpec *pspec)
{
  HdyStackableBox *self = HDY_STACKABLE_BOX (object);

  switch (prop_id) {
  case PROP_FOLDED:
    g_value_set_boolean (value, hdy_stackable_box_get_folded (self));
    break;
  case PROP_HHOMOGENEOUS_FOLDED:
    g_value_set_boolean (value, hdy_stackable_box_get_homogeneous (self, TRUE, GTK_ORIENTATION_HORIZONTAL));
    break;
  case PROP_VHOMOGENEOUS_FOLDED:
    g_value_set_boolean (value, hdy_stackable_box_get_homogeneous (self, TRUE, GTK_ORIENTATION_VERTICAL));
    break;
  case PROP_HHOMOGENEOUS_UNFOLDED:
    g_value_set_boolean (value, hdy_stackable_box_get_homogeneous (self, FALSE, GTK_ORIENTATION_HORIZONTAL));
    break;
  case PROP_VHOMOGENEOUS_UNFOLDED:
    g_value_set_boolean (value, hdy_stackable_box_get_homogeneous (self, FALSE, GTK_ORIENTATION_VERTICAL));
    break;
  case PROP_VISIBLE_CHILD:
    g_value_set_object (value, hdy_stackable_box_get_visible_child (self));
    break;
  case PROP_VISIBLE_CHILD_NAME:
    g_value_set_string (value, hdy_stackable_box_get_visible_child_name (self));
    break;
  case PROP_TRANSITION_TYPE:
    g_value_set_enum (value, hdy_stackable_box_get_transition_type (self));
    break;
  case PROP_MODE_TRANSITION_DURATION:
    g_value_set_uint (value, hdy_stackable_box_get_mode_transition_duration (self));
    break;
  case PROP_CHILD_TRANSITION_DURATION:
    g_value_set_uint (value, hdy_stackable_box_get_child_transition_duration (self));
    break;
  case PROP_CHILD_TRANSITION_RUNNING:
    g_value_set_boolean (value, hdy_stackable_box_get_child_transition_running (self));
    break;
  case PROP_INTERPOLATE_SIZE:
    g_value_set_boolean (value, hdy_stackable_box_get_interpolate_size (self));
    break;
  case PROP_CAN_SWIPE_BACK:
    g_value_set_boolean (value, hdy_stackable_box_get_can_swipe_back (self));
    break;
  case PROP_CAN_SWIPE_FORWARD:
    g_value_set_boolean (value, hdy_stackable_box_get_can_swipe_forward (self));
    break;
  case PROP_ORIENTATION:
    g_value_set_enum (value, hdy_stackable_box_get_orientation (self));
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_stackable_box_set_property (GObject      *object,
                                guint         prop_id,
                                const GValue *value,
                                GParamSpec   *pspec)
{
  HdyStackableBox *self = HDY_STACKABLE_BOX (object);

  switch (prop_id) {
  case PROP_HHOMOGENEOUS_FOLDED:
    hdy_stackable_box_set_homogeneous (self, TRUE, GTK_ORIENTATION_HORIZONTAL, g_value_get_boolean (value));
    break;
  case PROP_VHOMOGENEOUS_FOLDED:
    hdy_stackable_box_set_homogeneous (self, TRUE, GTK_ORIENTATION_VERTICAL, g_value_get_boolean (value));
    break;
  case PROP_HHOMOGENEOUS_UNFOLDED:
    hdy_stackable_box_set_homogeneous (self, FALSE, GTK_ORIENTATION_HORIZONTAL, g_value_get_boolean (value));
    break;
  case PROP_VHOMOGENEOUS_UNFOLDED:
    hdy_stackable_box_set_homogeneous (self, FALSE, GTK_ORIENTATION_VERTICAL, g_value_get_boolean (value));
    break;
  case PROP_VISIBLE_CHILD:
    hdy_stackable_box_set_visible_child (self, g_value_get_object (value));
    break;
  case PROP_VISIBLE_CHILD_NAME:
    hdy_stackable_box_set_visible_child_name (self, g_value_get_string (value));
    break;
  case PROP_TRANSITION_TYPE:
    hdy_stackable_box_set_transition_type (self, g_value_get_enum (value));
    break;
  case PROP_MODE_TRANSITION_DURATION:
    hdy_stackable_box_set_mode_transition_duration (self, g_value_get_uint (value));
    break;
  case PROP_CHILD_TRANSITION_DURATION:
    hdy_stackable_box_set_child_transition_duration (self, g_value_get_uint (value));
    break;
  case PROP_INTERPOLATE_SIZE:
    hdy_stackable_box_set_interpolate_size (self, g_value_get_boolean (value));
    break;
  case PROP_CAN_SWIPE_BACK:
    hdy_stackable_box_set_can_swipe_back (self, g_value_get_boolean (value));
    break;
  case PROP_CAN_SWIPE_FORWARD:
    hdy_stackable_box_set_can_swipe_forward (self, g_value_get_boolean (value));
    break;
  case PROP_ORIENTATION:
    hdy_stackable_box_set_orientation (self, g_value_get_enum (value));
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_stackable_box_finalize (GObject *object)
{
  HdyStackableBox *self = HDY_STACKABLE_BOX (object);

  self->visible_child = NULL;

  if (self->shadow_helper)
    g_clear_object (&self->shadow_helper);

  hdy_stackable_box_unschedule_child_ticks (self);

  G_OBJECT_CLASS (hdy_stackable_box_parent_class)->finalize (object);
}

void
hdy_stackable_box_realize (HdyStackableBox *self)
{
  GtkWidget *widget = GTK_WIDGET (self->container);
  GtkAllocation allocation;
  GdkWindowAttr attributes = { 0 };
  GdkWindowAttributesType attributes_mask;
  GList *children;
  GdkWindow *window;

  gtk_widget_set_realized (widget, TRUE);

  gtk_widget_get_allocation (widget, &allocation);

  attributes.x = allocation.x;
  attributes.y = allocation.y;
  attributes.width = allocation.width;
  attributes.height = allocation.height;
  attributes.window_type = GDK_WINDOW_CHILD;
  attributes.wclass = GDK_INPUT_OUTPUT;
  attributes.visual = gtk_widget_get_visual (widget);
  attributes.event_mask = gtk_widget_get_events (widget);
  attributes_mask = (GDK_WA_X | GDK_WA_Y) | GDK_WA_VISUAL;

  window = gdk_window_new (gtk_widget_get_parent_window (widget),
                           &attributes, attributes_mask);
  gtk_widget_set_window (widget, window);
  gtk_widget_register_window (widget, window);

  for (children = self->children; children != NULL; children = children->next)
    register_window (self, children->data);
}

void
hdy_stackable_box_unrealize (HdyStackableBox *self)
{
  GtkWidget *widget = GTK_WIDGET (self->container);
  GList *children;

  for (children = self->children; children != NULL; children = children->next)
    unregister_window (self, children->data);

  GTK_WIDGET_CLASS (self->klass)->unrealize (widget);
}

HdySwipeTracker *
hdy_stackable_box_get_swipe_tracker (HdyStackableBox *self)
{
  return self->tracker;
}

gdouble
hdy_stackable_box_get_distance (HdyStackableBox *self)
{
  if (self->orientation == GTK_ORIENTATION_HORIZONTAL)
    return gtk_widget_get_allocated_width (GTK_WIDGET (self->container));
  else
    return gtk_widget_get_allocated_height (GTK_WIDGET (self->container));
}

static gboolean
can_swipe_in_direction (HdyStackableBox        *self,
                        HdyNavigationDirection  direction)
{
  switch (direction) {
  case HDY_NAVIGATION_DIRECTION_BACK:
    return self->child_transition.can_swipe_back;
  case HDY_NAVIGATION_DIRECTION_FORWARD:
    return self->child_transition.can_swipe_forward;
  default:
    g_assert_not_reached ();
  }
}

gdouble *
hdy_stackable_box_get_snap_points (HdyStackableBox *self,
                                   gint            *n_snap_points)
{
  gint n;
  gdouble *points, lower, upper;

  if (self->child_transition.tick_id > 0 ||
      self->child_transition.is_gesture_active) {
    gint current_direction;
    gboolean is_rtl = gtk_widget_get_direction (GTK_WIDGET (self->container)) == GTK_TEXT_DIR_RTL;

    switch (self->child_transition.active_direction) {
    case GTK_PAN_DIRECTION_UP:
      current_direction = 1;
      break;
    case GTK_PAN_DIRECTION_DOWN:
      current_direction = -1;
      break;
    case GTK_PAN_DIRECTION_LEFT:
      current_direction = is_rtl ? -1 : 1;
      break;
    case GTK_PAN_DIRECTION_RIGHT:
      current_direction = is_rtl ? 1 : -1;
      break;
    default:
      g_assert_not_reached ();
    }

    lower = MIN (0, current_direction);
    upper = MAX (0, current_direction);
  } else {
    HdyStackableBoxChildInfo *child = NULL;

    if ((can_swipe_in_direction (self, self->child_transition.swipe_direction) ||
         !self->child_transition.is_direct_swipe) && self->folded)
      child = find_swipeable_child (self, self->child_transition.swipe_direction);

    lower = MIN (0, child ? self->child_transition.swipe_direction : 0);
    upper = MAX (0, child ? self->child_transition.swipe_direction : 0);
  }

  n = (lower != upper) ? 2 : 1;

  points = g_new0 (gdouble, n);
  points[0] = lower;
  points[n - 1] = upper;

  if (n_snap_points)
    *n_snap_points = n;

  return points;
}

gdouble
hdy_stackable_box_get_progress (HdyStackableBox *self)
{
  gboolean new_first = FALSE;
  GList *children;

  if (!self->child_transition.is_gesture_active &&
      gtk_progress_tracker_get_state (&self->child_transition.tracker) == GTK_PROGRESS_STATE_AFTER)
    return 0;

  for (children = self->children; children; children = children->next) {
    if (self->last_visible_child == children->data) {
      new_first = TRUE;

      break;
    }
    if (self->visible_child == children->data)
      break;
  }

  return self->child_transition.progress * (new_first ? 1 : -1);
}

gdouble
hdy_stackable_box_get_cancel_progress (HdyStackableBox *self)
{
  return 0;
}

void
hdy_stackable_box_get_swipe_area (HdyStackableBox        *self,
                                  HdyNavigationDirection  navigation_direction,
                                  gboolean                is_drag,
                                  GdkRectangle           *rect)
{
  gint width = gtk_widget_get_allocated_width (GTK_WIDGET (self->container));
  gint height = gtk_widget_get_allocated_height (GTK_WIDGET (self->container));
  gdouble progress = 0;

  rect->x = 0;
  rect->y = 0;
  rect->width = width;
  rect->height = height;

  if (!is_drag)
    return;

  if (self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_SLIDE)
    return;

  if (self->child_transition.is_gesture_active ||
      gtk_progress_tracker_get_state (&self->child_transition.tracker) != GTK_PROGRESS_STATE_AFTER)
    progress = self->child_transition.progress;

  if (self->orientation == GTK_ORIENTATION_HORIZONTAL) {
    gboolean is_rtl = gtk_widget_get_direction (GTK_WIDGET (self->container)) == GTK_TEXT_DIR_RTL;

    if (self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER &&
         navigation_direction == HDY_NAVIGATION_DIRECTION_FORWARD) {
      rect->width = MAX (progress * width, HDY_SWIPE_BORDER);
      rect->x = is_rtl ? 0 : width - rect->width;
    } else if (self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER &&
               navigation_direction == HDY_NAVIGATION_DIRECTION_BACK) {
      rect->width = MAX (progress * width, HDY_SWIPE_BORDER);
      rect->x = is_rtl ? width - rect->width : 0;
    }
  } else {
    if (self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER &&
        navigation_direction == HDY_NAVIGATION_DIRECTION_FORWARD) {
      rect->height = MAX (progress * height, HDY_SWIPE_BORDER);
      rect->y = height - rect->height;
    } else if (self->transition_type == HDY_STACKABLE_BOX_TRANSITION_TYPE_UNDER &&
               navigation_direction == HDY_NAVIGATION_DIRECTION_BACK) {
      rect->height = MAX (progress * height, HDY_SWIPE_BORDER);
      rect->y = 0;
    }
  }
}

void
hdy_stackable_box_switch_child (HdyStackableBox *self,
                                guint            index,
                                gint64           duration)
{
  HdyStackableBoxChildInfo *child_info = NULL;
  GList *children;
  guint i = 0;

  for (children = self->children; children; children = children->next) {
    child_info = children->data;

    if (!child_info->navigatable)
      continue;

    if (i == index)
      break;

    i++;
  }

  if (child_info == NULL) {
    g_critical ("Couldn't find eligible child with index %u", index);
    return;
  }

  set_visible_child_info (self, child_info, self->transition_type,
                          duration, FALSE);
}

static void
begin_swipe_cb (HdySwipeTracker        *tracker,
                HdyNavigationDirection  direction,
                gboolean                direct,
                HdyStackableBox        *self)
{
  self->child_transition.is_direct_swipe = direct;
  self->child_transition.swipe_direction = direction;

  if (self->child_transition.tick_id > 0) {
    gtk_widget_remove_tick_callback (GTK_WIDGET (self->container),
                                     self->child_transition.tick_id);
    self->child_transition.tick_id = 0;
    self->child_transition.is_gesture_active = TRUE;
    self->child_transition.is_cancelled = FALSE;
  } else {
    HdyStackableBoxChildInfo *child;

    if ((can_swipe_in_direction (self, direction) || !direct) && self->folded)
      child = find_swipeable_child (self, direction);
    else
      child = NULL;

    if (child) {
      self->child_transition.is_gesture_active = TRUE;
      set_visible_child_info (self, child, self->transition_type,
                              self->child_transition.duration, FALSE);

      g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CHILD_TRANSITION_RUNNING]);
    }
  }
}

static void
update_swipe_cb (HdySwipeTracker *tracker,
                 gdouble          progress,
                 HdyStackableBox *self)
{
  self->child_transition.progress = ABS (progress);
  hdy_stackable_box_child_progress_updated (self);
}

static void
end_swipe_cb (HdySwipeTracker *tracker,
              gint64           duration,
              gdouble          to,
              HdyStackableBox *self)
{
 if (!self->child_transition.is_gesture_active)
    return;

  self->child_transition.start_progress = self->child_transition.progress;
  self->child_transition.end_progress = ABS (to);
  self->child_transition.is_cancelled = (to == 0);
  self->child_transition.first_frame_skipped = TRUE;

  hdy_stackable_box_schedule_child_ticks (self);
  if (hdy_get_enable_animations (GTK_WIDGET (self->container)) && duration != 0) {
    gtk_progress_tracker_start (&self->child_transition.tracker,
                                duration * 1000,
                                0,
                                1.0);
  } else {
    self->child_transition.progress = self->child_transition.end_progress;
    gtk_progress_tracker_finish (&self->child_transition.tracker);
  }

  self->child_transition.is_gesture_active = FALSE;
  hdy_stackable_box_child_progress_updated (self);

  gtk_widget_queue_draw (GTK_WIDGET (self->container));
}

GtkOrientation
hdy_stackable_box_get_orientation (HdyStackableBox *self)
{
  return self->orientation;
}

void
hdy_stackable_box_set_orientation (HdyStackableBox *self,
                                   GtkOrientation   orientation)
{
  if (self->orientation == orientation)
    return;

  self->orientation = orientation;
  update_tracker_orientation (self);
  gtk_widget_queue_resize (GTK_WIDGET (self->container));
  g_object_notify (G_OBJECT (self), "orientation");
}

const gchar *
hdy_stackable_box_get_child_name (HdyStackableBox *self,
                                  GtkWidget       *widget)
{
  HdyStackableBoxChildInfo *child_info;

  child_info = find_child_info_for_widget (self, widget);

  g_return_val_if_fail (child_info != NULL, NULL);

  return child_info->name;
}

void
hdy_stackable_box_set_child_name (HdyStackableBox *self,
                                  GtkWidget       *widget,
                                  const gchar     *name)
{
  HdyStackableBoxChildInfo *child_info;
  HdyStackableBoxChildInfo *child_info2;
  GList *children;

  child_info = find_child_info_for_widget (self, widget);

  g_return_if_fail (child_info != NULL);

  for (children = self->children; children; children = children->next) {
    child_info2 = children->data;

    if (child_info == child_info2)
      continue;
    if (g_strcmp0 (child_info2->name, name) == 0) {
      g_warning ("Duplicate child name in HdyStackableBox: %s", name);

      break;
    }
  }

  g_free (child_info->name);
  child_info->name = g_strdup (name);

  if (self->visible_child == child_info)
    g_object_notify_by_pspec (G_OBJECT (self),
                              props[PROP_VISIBLE_CHILD_NAME]);
}

gboolean
hdy_stackable_box_get_child_navigatable (HdyStackableBox *self,
                                         GtkWidget       *widget)
{
  HdyStackableBoxChildInfo *child_info;

  child_info = find_child_info_for_widget (self, widget);

  g_return_val_if_fail (child_info != NULL, FALSE);

  return child_info->navigatable;
}

void
hdy_stackable_box_set_child_navigatable (HdyStackableBox *self,
                                         GtkWidget       *widget,
                                         gboolean         navigatable)
{
  HdyStackableBoxChildInfo *child_info;

  child_info = find_child_info_for_widget (self, widget);

  g_return_if_fail (child_info != NULL);

  child_info->navigatable = navigatable;

  if (!child_info->navigatable &&
      hdy_stackable_box_get_visible_child (self) == widget)
    set_visible_child_info (self, NULL, self->transition_type, self->child_transition.duration, TRUE);
}

void
hdy_stackable_box_prepend (HdyStackableBox *self,
                           GtkWidget       *child)
{
  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));
  g_return_if_fail (GTK_IS_WIDGET (child));
  g_return_if_fail (gtk_widget_get_parent (child) == NULL);

  hdy_stackable_box_insert_child_after (self, child, NULL);
}

void
hdy_stackable_box_insert_child_after (HdyStackableBox *self,
                                      GtkWidget       *child,
                                      GtkWidget       *sibling)
{
  HdyStackableBoxChildInfo *child_info;
  gint visible_child_pos_before_insert = -1;
  gint visible_child_pos_after_insert = -1;

  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));
  g_return_if_fail (GTK_IS_WIDGET (child));
  g_return_if_fail (sibling == NULL || GTK_IS_WIDGET (sibling));

  g_return_if_fail (gtk_widget_get_parent (child) == NULL);
  g_return_if_fail (sibling == NULL || gtk_widget_get_parent (sibling) == GTK_WIDGET (self->container));

  child_info = g_new0 (HdyStackableBoxChildInfo, 1);
  child_info->widget = child;
  child_info->navigatable = TRUE;

  if (self->visible_child)
    visible_child_pos_before_insert = g_list_index (self->children, self->visible_child);

  if (!sibling) {
    self->children = g_list_prepend (self->children, child_info);
    self->children_reversed = g_list_append (self->children_reversed, child_info);
  } else {
    HdyStackableBoxChildInfo *sibling_info = find_child_info_for_widget (self, sibling);
    gint sibling_info_pos = g_list_index (self->children, sibling_info);
    gint length = g_list_length (self->children);

    self->children =
      g_list_insert (self->children, child_info,
                     sibling_info_pos + 1);
    self->children_reversed =
      g_list_insert (self->children_reversed, child_info,
                     length - sibling_info_pos - 1);
  }

  if (self->visible_child)
    visible_child_pos_after_insert = g_list_index (self->children, self->visible_child);

  if (gtk_widget_get_realized (GTK_WIDGET (self->container)))
    register_window (self, child_info);

  gtk_widget_set_child_visible (child, FALSE);
  gtk_widget_set_parent (child, GTK_WIDGET (self->container));

  g_signal_connect (child, "notify::visible",
                    G_CALLBACK (hdy_stackable_box_child_visibility_notify_cb), self);

  if (!hdy_stackable_box_get_visible_child (self) &&
      gtk_widget_get_visible (child))
    set_visible_child_info (self,
                            child_info,
                            self->transition_type,
                            self->child_transition.duration,
                            FALSE);
  else if (visible_child_pos_before_insert != visible_child_pos_after_insert)
    hdy_swipeable_emit_child_switched (HDY_SWIPEABLE (self->container),
                                       visible_child_pos_after_insert,
                                       0);

  if (!self->folded ||
      (self->homogeneous[HDY_FOLD_FOLDED][GTK_ORIENTATION_HORIZONTAL] ||
       self->homogeneous[HDY_FOLD_FOLDED][GTK_ORIENTATION_VERTICAL] ||
       self->visible_child == child_info))
    gtk_widget_queue_resize (GTK_WIDGET (self->container));
}

void
hdy_stackable_box_reorder_child_after (HdyStackableBox *self,
                                       GtkWidget       *child,
                                       GtkWidget       *sibling)
{
  HdyStackableBoxChildInfo *child_info;
  HdyStackableBoxChildInfo *sibling_info;
  gint sibling_info_pos;
  gint visible_child_pos_before_reorder;
  gint visible_child_pos_after_reorder;

  g_return_if_fail (HDY_IS_STACKABLE_BOX (self));
  g_return_if_fail (GTK_IS_WIDGET (child));
  g_return_if_fail (sibling == NULL || GTK_IS_WIDGET (sibling));

  g_return_if_fail (gtk_widget_get_parent (child) == GTK_WIDGET (self->container));
  g_return_if_fail (sibling == NULL || gtk_widget_get_parent (sibling) == GTK_WIDGET (self->container));

  if (child == sibling)
    return;

  visible_child_pos_before_reorder = g_list_index (self->children, self->visible_child);

  /* Cancel a gesture if there's one in progress */
  hdy_swipe_tracker_emit_end_swipe (self->tracker, 0, 0.0);

  child_info = find_child_info_for_widget (self, child);
  self->children = g_list_remove (self->children, child_info);
  self->children_reversed = g_list_remove (self->children_reversed, child_info);

  sibling_info = find_child_info_for_widget (self, sibling);
  sibling_info_pos = g_list_index (self->children, sibling_info);

  self->children =
    g_list_insert (self->children, child_info,
                   sibling_info_pos + 1);
  self->children_reversed =
    g_list_insert (self->children_reversed, child_info,
                   g_list_length (self->children) - sibling_info_pos - 1);

  visible_child_pos_after_reorder = g_list_index (self->children, self->visible_child);

  if (visible_child_pos_before_reorder != visible_child_pos_after_reorder)
    hdy_swipeable_emit_child_switched (HDY_SWIPEABLE (self->container), visible_child_pos_after_reorder, 0);
}

static void
hdy_stackable_box_class_init (HdyStackableBoxClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);

  object_class->get_property = hdy_stackable_box_get_property;
  object_class->set_property = hdy_stackable_box_set_property;
  object_class->finalize = hdy_stackable_box_finalize;

  /**
   * HdyStackableBox:folded:
   *
   * `TRUE` if the widget is folded.
   *
   * The [class@StackableBox] will be folded if the size allocated to it is smaller
   * than the sum of the natural size of its children, it will be unfolded
   * otherwise.
   */
  props[PROP_FOLDED] =
    g_param_spec_boolean ("folded",
                          _("Folded"),
                          _("Whether the widget is folded"),
                          FALSE,
                          G_PARAM_READABLE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyStackableBox:hhomogeneous_folded:
   *
   * `TRUE` if the widget allocates the same width for all children when folded.
   */
  props[PROP_HHOMOGENEOUS_FOLDED] =
    g_param_spec_boolean ("hhomogeneous-folded",
                          _("Horizontally homogeneous folded"),
                          _("Horizontally homogeneous sizing when the widget is folded"),
                          TRUE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyStackableBox:vhomogeneous_folded:
   *
   * `TRUE` if the widget allocates the same height for all children when folded.
   */
  props[PROP_VHOMOGENEOUS_FOLDED] =
    g_param_spec_boolean ("vhomogeneous-folded",
                          _("Vertically homogeneous folded"),
                          _("Vertically homogeneous sizing when the widget is folded"),
                          TRUE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyStackableBox:hhomogeneous_unfolded:
   *
   * `TRUE` if the widget allocates the same width for all children when unfolded.
   */
  props[PROP_HHOMOGENEOUS_UNFOLDED] =
    g_param_spec_boolean ("hhomogeneous-unfolded",
                          _("Box horizontally homogeneous"),
                          _("Horizontally homogeneous sizing when the widget is unfolded"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyStackableBox:vhomogeneous_unfolded:
   *
   * `TRUE` if the widget allocates the same height for all children when unfolded.
   */
  props[PROP_VHOMOGENEOUS_UNFOLDED] =
    g_param_spec_boolean ("vhomogeneous-unfolded",
                          _("Box vertically homogeneous"),
                          _("Vertically homogeneous sizing when the widget is unfolded"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_VISIBLE_CHILD] =
    g_param_spec_object ("visible-child",
                         _("Visible child"),
                         _("The widget currently visible when the widget is folded"),
                         GTK_TYPE_WIDGET,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_VISIBLE_CHILD_NAME] =
    g_param_spec_string ("visible-child-name",
                         _("Name of visible child"),
                         _("The name of the widget currently visible when the children are stacked"),
                         NULL,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyStackableBox:transition-type:
   *
   * The type of animation that will be used for transitions between modes and
   * children.
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
                       HDY_TYPE_STACKABLE_BOX_TRANSITION_TYPE, HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER,
                       G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_MODE_TRANSITION_DURATION] =
    g_param_spec_uint ("mode-transition-duration",
                       _("Mode transition duration"),
                       _("The mode transition animation duration, in milliseconds"),
                       0, G_MAXUINT, 250,
                       G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_CHILD_TRANSITION_DURATION] =
    g_param_spec_uint ("child-transition-duration",
                       _("Child transition duration"),
                       _("The child transition animation duration, in milliseconds"),
                       0, G_MAXUINT, 200,
                       G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_CHILD_TRANSITION_RUNNING] =
      g_param_spec_boolean ("child-transition-running",
                            _("Child transition running"),
                            _("Whether or not the child transition is currently running"),
                            FALSE,
                            G_PARAM_READABLE);

  props[PROP_INTERPOLATE_SIZE] =
      g_param_spec_boolean ("interpolate-size",
                            _("Interpolate size"),
                            _("Whether or not the size should smoothly change when changing between differently sized children"),
                            FALSE,
                            G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyStackableBox:can-swipe-back:
   *
   * Whether or not the widget allows switching to the previous child that has
   * 'navigatable' child property set to `TRUE` via a swipe gesture.
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
   * HdyStackableBox:can-swipe-forward:
   *
   * Whether or not the widget allows switching to the next child that has
   * 'navigatable' child property set to `TRUE` via a swipe gesture.
   *
   * Since: 1.0
   */
  props[PROP_CAN_SWIPE_FORWARD] =
      g_param_spec_boolean ("can-swipe-forward",
                            _("Can swipe forward"),
                            _("Whether or not swipe gesture can be used to switch to the next child"),
                            FALSE,
                            G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_ORIENTATION] =
      g_param_spec_enum ("orientation",
                         _("Orientation"),
                         _("Orientation"),
                         GTK_TYPE_ORIENTATION,
                         GTK_ORIENTATION_HORIZONTAL,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  g_object_class_install_properties (object_class, LAST_PROP, props);
}

HdyStackableBox *
hdy_stackable_box_new (GtkContainer      *container,
                       GtkContainerClass *klass,
                       gboolean           can_unfold)
{
  GtkWidget *widget;
  HdyStackableBox *self;

  g_return_val_if_fail (GTK_IS_CONTAINER (container), NULL);
  g_return_val_if_fail (GTK_IS_ORIENTABLE (container), NULL);
  g_return_val_if_fail (GTK_IS_CONTAINER_CLASS (klass), NULL);

  widget = GTK_WIDGET (container);
  self = g_object_new (HDY_TYPE_STACKABLE_BOX, NULL);

  self->container = container;
  self->klass = klass;
  self->can_unfold = can_unfold;

  self->children = NULL;
  self->children_reversed = NULL;
  self->visible_child = NULL;
  self->folded = FALSE;
  self->homogeneous[HDY_FOLD_UNFOLDED][GTK_ORIENTATION_HORIZONTAL] = FALSE;
  self->homogeneous[HDY_FOLD_UNFOLDED][GTK_ORIENTATION_VERTICAL] = FALSE;
  self->homogeneous[HDY_FOLD_FOLDED][GTK_ORIENTATION_HORIZONTAL] = TRUE;
  self->homogeneous[HDY_FOLD_FOLDED][GTK_ORIENTATION_VERTICAL] = TRUE;
  self->transition_type = HDY_STACKABLE_BOX_TRANSITION_TYPE_OVER;
  self->mode_transition.duration = 250;
  self->child_transition.duration = 200;
  self->mode_transition.current_pos = 1.0;
  self->mode_transition.target_pos = 1.0;

  self->tracker = hdy_swipe_tracker_new (HDY_SWIPEABLE (self->container));

  g_object_set (self->tracker, "orientation", self->orientation, "enabled", FALSE, NULL);

  g_signal_connect_object (self->tracker, "begin-swipe", G_CALLBACK (begin_swipe_cb), self, 0);
  g_signal_connect_object (self->tracker, "update-swipe", G_CALLBACK (update_swipe_cb), self, 0);
  g_signal_connect_object (self->tracker, "end-swipe", G_CALLBACK (end_swipe_cb), self, 0);

  self->shadow_helper = hdy_shadow_helper_new (widget);

  gtk_widget_set_can_focus (widget, FALSE);
  gtk_widget_set_redraw_on_allocate (widget, FALSE);

  if (can_unfold) {
    GtkStyleContext *context = gtk_widget_get_style_context (widget);
    gtk_style_context_add_class (context, "unfolded");
  }

  return self;
}

static void
hdy_stackable_box_init (HdyStackableBox *self)
{
}
