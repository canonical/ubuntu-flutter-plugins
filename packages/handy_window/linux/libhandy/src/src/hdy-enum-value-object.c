/*
 * Copyright (C) 2018 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "config.h"

#include "hdy-enum-value-object.h"

/**
 * HdyEnumValueObject:
 *
 * An object representing an [struct@GObject.EnumValue].
 *
 * The `HdyEnumValueObject` object represents a [struct@GObject.EnumValue],
 * allowing it to be used with [iface@Gio.ListModel].
 *
 * Since: 1.0
 */

struct _HdyEnumValueObject
{
  GObject parent_instance;

  GEnumValue enum_value;
};

G_DEFINE_TYPE (HdyEnumValueObject, hdy_enum_value_object, G_TYPE_OBJECT)

/**
 * hdy_enum_value_object_new:
 *
 * Creates a new `HdyEnumValueObject`.
 *
 * Returns: the newly created `HdyEnumValueObject`
 *
 * Since: 1.0
 */
HdyEnumValueObject *
hdy_enum_value_object_new (GEnumValue *enum_value)
{
  HdyEnumValueObject *self = g_object_new (HDY_TYPE_ENUM_VALUE_OBJECT, NULL);

  self->enum_value = *enum_value;

  return self;
}

static void
hdy_enum_value_object_class_init (HdyEnumValueObjectClass *klass)
{
}

static void
hdy_enum_value_object_init (HdyEnumValueObject *self)
{
}

/**
 * hdy_enum_value_object_get_value:
 * @self: an enum value object
 *
 * Gets the value of @self.
 *
 * Returns: the value of @self
 *
 * Since: 1.0
 */
gint
hdy_enum_value_object_get_value (HdyEnumValueObject *self)
{
  g_return_val_if_fail (HDY_IS_ENUM_VALUE_OBJECT (self), 0);

  return self->enum_value.value;
}

/**
 * hdy_enum_value_object_get_name:
 * @self: an enum value object
 *
 * Gets the name of @self.
 *
 * Returns: the name of @self
 *
 * Since: 1.0
 */
const gchar *
hdy_enum_value_object_get_name (HdyEnumValueObject *self)
{
  g_return_val_if_fail (HDY_IS_ENUM_VALUE_OBJECT (self), NULL);

  return self->enum_value.value_name;
}

/**
 * hdy_enum_value_object_get_nick:
 * @self: an enum value object
 *
 * Gets the nick of @self.
 *
 * Returns: the nick of @self
 *
 * Since: 1.0
 */
const gchar *
hdy_enum_value_object_get_nick (HdyEnumValueObject *self)
{
  g_return_val_if_fail (HDY_IS_ENUM_VALUE_OBJECT (self), NULL);

  return self->enum_value.value_nick;
}
