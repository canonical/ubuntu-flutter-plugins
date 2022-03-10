/*
 * Copyright (C) 2020 Felix Häcker <haeckerfelix@gnome.org>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include "hdy-version.h"

#include <gtk/gtk.h>
#include "hdy-enums.h"

G_BEGIN_DECLS

#define HDY_TYPE_FLAP (hdy_flap_get_type ())

HDY_AVAILABLE_IN_1_2
G_DECLARE_FINAL_TYPE (HdyFlap, hdy_flap, HDY, FLAP, GtkContainer)

typedef enum {
  HDY_FLAP_FOLD_POLICY_NEVER,
  HDY_FLAP_FOLD_POLICY_ALWAYS,
  HDY_FLAP_FOLD_POLICY_AUTO,
} HdyFlapFoldPolicy;

typedef enum {
  HDY_FLAP_TRANSITION_TYPE_OVER,
  HDY_FLAP_TRANSITION_TYPE_UNDER,
  HDY_FLAP_TRANSITION_TYPE_SLIDE,
} HdyFlapTransitionType;

HDY_AVAILABLE_IN_1_2
GtkWidget *hdy_flap_new (void);

HDY_AVAILABLE_IN_1_2
GtkWidget *hdy_flap_get_content (HdyFlap *self);
HDY_AVAILABLE_IN_1_2
void       hdy_flap_set_content (HdyFlap   *self,
                                 GtkWidget *content);

HDY_AVAILABLE_IN_1_2
GtkWidget *hdy_flap_get_flap (HdyFlap   *self);
HDY_AVAILABLE_IN_1_2
void       hdy_flap_set_flap (HdyFlap   *self,
                              GtkWidget *flap);

HDY_AVAILABLE_IN_1_2
GtkWidget *hdy_flap_get_separator (HdyFlap   *self);
HDY_AVAILABLE_IN_1_2
void       hdy_flap_set_separator (HdyFlap   *self,
                                   GtkWidget *separator);

HDY_AVAILABLE_IN_1_2
GtkPackType hdy_flap_get_flap_position (HdyFlap *self);
HDY_AVAILABLE_IN_1_2
void        hdy_flap_set_flap_position (HdyFlap     *self,
                                        GtkPackType  position);

HDY_AVAILABLE_IN_1_2
gboolean hdy_flap_get_reveal_flap (HdyFlap *self);
HDY_AVAILABLE_IN_1_2
void     hdy_flap_set_reveal_flap (HdyFlap  *self,
                                   gboolean  reveal_flap);

HDY_AVAILABLE_IN_1_2
guint hdy_flap_get_reveal_duration (HdyFlap *self);
HDY_AVAILABLE_IN_1_2
void  hdy_flap_set_reveal_duration (HdyFlap *self,
                                    guint    duration);

HDY_AVAILABLE_IN_1_2
gdouble hdy_flap_get_reveal_progress (HdyFlap *self);

HDY_AVAILABLE_IN_1_2
HdyFlapFoldPolicy hdy_flap_get_fold_policy (HdyFlap           *self);
HDY_AVAILABLE_IN_1_2
void              hdy_flap_set_fold_policy (HdyFlap           *self,
                                            HdyFlapFoldPolicy  policy);

HDY_AVAILABLE_IN_1_2
guint hdy_flap_get_fold_duration (HdyFlap *self);
HDY_AVAILABLE_IN_1_2
void  hdy_flap_set_fold_duration (HdyFlap *self,
                                  guint    duration);

HDY_AVAILABLE_IN_1_2
gboolean hdy_flap_get_folded (HdyFlap *self);

HDY_AVAILABLE_IN_1_2
gboolean hdy_flap_get_locked (HdyFlap *self);
HDY_AVAILABLE_IN_1_2
void     hdy_flap_set_locked (HdyFlap  *self,
                              gboolean  locked);

HDY_AVAILABLE_IN_1_2
HdyFlapTransitionType hdy_flap_get_transition_type (HdyFlap               *self);
HDY_AVAILABLE_IN_1_2
void                  hdy_flap_set_transition_type (HdyFlap               *self,
                                                    HdyFlapTransitionType  transition_type);

HDY_AVAILABLE_IN_1_2
gboolean hdy_flap_get_modal (HdyFlap  *self);
HDY_AVAILABLE_IN_1_2
void     hdy_flap_set_modal (HdyFlap  *self,
                             gboolean  modal);

HDY_AVAILABLE_IN_1_2
gboolean hdy_flap_get_swipe_to_open (HdyFlap  *self);
HDY_AVAILABLE_IN_1_2
void     hdy_flap_set_swipe_to_open (HdyFlap  *self,
                                     gboolean  swipe_to_open);

HDY_AVAILABLE_IN_1_2
gboolean hdy_flap_get_swipe_to_close (HdyFlap  *self);
HDY_AVAILABLE_IN_1_2
void     hdy_flap_set_swipe_to_close (HdyFlap  *self,
                                      gboolean  swipe_to_close);

G_END_DECLS
