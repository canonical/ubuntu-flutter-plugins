/*
 * Copyright (C) 2019 Alexander Mikhaylenko <exalm7659@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include "hdy-version.h"

#include <glib-object.h>
#include "hdy-swipeable.h"

G_BEGIN_DECLS

#define HDY_TYPE_SWIPE_GROUP (hdy_swipe_group_get_type())

HDY_AVAILABLE_IN_ALL
G_DECLARE_FINAL_TYPE (HdySwipeGroup, hdy_swipe_group, HDY, SWIPE_GROUP, GObject)

HDY_DEPRECATED_IN_1_4
HdySwipeGroup *hdy_swipe_group_new (void);

HDY_DEPRECATED_IN_1_4
void           hdy_swipe_group_add_swipeable    (HdySwipeGroup *self,
                                                 HdySwipeable  *swipeable);
HDY_DEPRECATED_IN_1_4
GSList *       hdy_swipe_group_get_swipeables   (HdySwipeGroup *self);
HDY_DEPRECATED_IN_1_4
void           hdy_swipe_group_remove_swipeable (HdySwipeGroup *self,
                                                 HdySwipeable  *swipeable);

G_END_DECLS
