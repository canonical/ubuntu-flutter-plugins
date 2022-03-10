/*
 * Copyright (C) 2019 Red Hat Inc.
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "config.h"
#include <glib/gi18n-lib.h>
#include <gobject/gvaluecollector.h>
#include "hdy-value-object.h"

/**
 * HdyValueObject:
 *
 * An object representing a [struct@GObject.Value].
 *
 * The `HdyValueObject` object represents a [struct@GObject.Value], allowing it
 * to be used with [iface@Gio.ListModel].
 *
 * Since: 1.0
 */

struct _HdyValueObject
{
  GObject parent_instance;

  GValue value;
};

G_DEFINE_TYPE (HdyValueObject, hdy_value_object, G_TYPE_OBJECT)

enum {
  PROP_0,
  PROP_VALUE,
  N_PROPS
};

static GParamSpec *props [N_PROPS];

/**
 * hdy_value_object_new:
 * @value: the value to store
 *
 * Creates a new `HdyValueObject`.
 *
 * Returns: a new `HdyValueObject`
 *
 * Since: 1.0
 */
HdyValueObject *
hdy_value_object_new (const GValue *value)
{
  return g_object_new (HDY_TYPE_VALUE_OBJECT,
                       "value", value,
                       NULL);
}

/**
 * hdy_value_object_new_collect: (skip)
 * @type: the type of the value
 * @...: the value to store
 *
 * Creates a new `HdyValueObject`.
 *
 * This is a convenience method which uses the `G_VALUE_COLLECT` macro
 * internally.
 *
 * Returns: a new `HdyValueObject`
 *
 * Since: 1.0
 */
HdyValueObject*
hdy_value_object_new_collect (GType type, ...)
{
  g_auto(GValue) value = G_VALUE_INIT;
  g_autofree gchar *error = NULL;
  va_list var_args;

  va_start (var_args, type);

  G_VALUE_COLLECT_INIT (&value, type, var_args, 0, &error);

  va_end (var_args);

  if (error)
    g_critical ("%s: %s", G_STRFUNC, error);

  return g_object_new (HDY_TYPE_VALUE_OBJECT,
                       "value", &value,
                       NULL);
}

/**
 * hdy_value_object_new_string: (skip)
 * @string: (transfer none): the string to store
 *
 * Creates a new `HdyValueObject`.
 *
 * This is a convenience method to create a [class@ValueObject] that stores a
 * string.
 *
 * Returns: a new `HdyValueObject`
 *
 * Since: 1.0
 */
HdyValueObject*
hdy_value_object_new_string (const gchar *string)
{
  g_auto(GValue) value = G_VALUE_INIT;

  g_value_init (&value, G_TYPE_STRING);
  g_value_set_string (&value, string);
  return hdy_value_object_new (&value);
}

/**
 * hdy_value_object_new_take_string: (skip)
 * @string: (transfer full): the string to store
 *
 * Creates a new `HdyValueObject`.
 *
 * This is a convenience method to create a [class@ValueObject] that stores a
 * string taking ownership of it.
 *
 * Returns: a new `HdyValueObject`
 *
 * Since: 1.0
 */
HdyValueObject*
hdy_value_object_new_take_string (gchar *string)
{
  g_auto(GValue) value = G_VALUE_INIT;

  g_value_init (&value, G_TYPE_STRING);
  g_value_take_string (&value, string);
  return hdy_value_object_new (&value);
}

static void
hdy_value_object_finalize (GObject *object)
{
  HdyValueObject *self = HDY_VALUE_OBJECT (object);

  g_value_unset (&self->value);

  G_OBJECT_CLASS (hdy_value_object_parent_class)->finalize (object);
}

static void
hdy_value_object_get_property (GObject    *object,
                               guint       prop_id,
                               GValue     *value,
                               GParamSpec *pspec)
{
  HdyValueObject *self = HDY_VALUE_OBJECT (object);

  switch (prop_id)
    {
    case PROP_VALUE:
      g_value_set_boxed (value, &self->value);
      break;

    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
    }
}

static void
hdy_value_object_set_property (GObject      *object,
                               guint         prop_id,
                               const GValue *value,
                               GParamSpec   *pspec)
{
  HdyValueObject *self = HDY_VALUE_OBJECT (object);
  GValue *real_value;

  switch (prop_id)
    {
    case PROP_VALUE:
      /* construct only */
      real_value = g_value_get_boxed (value);
      g_value_init (&self->value, real_value->g_type);
      g_value_copy (real_value, &self->value);
      break;

    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
    }
}

static void
hdy_value_object_class_init (HdyValueObjectClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);

  object_class->finalize = hdy_value_object_finalize;
  object_class->get_property = hdy_value_object_get_property;
  object_class->set_property = hdy_value_object_set_property;

  /**
   * HdyValueObject:value: (attributes org.gtk.Property.get=hdy_value_object_get_value)
   *
   * The contained value.
   *
   * Since: 1.0
   */
  props[PROP_VALUE] =
    g_param_spec_boxed ("value", C_("HdyValueObjectClass", "Value"),
                        C_("HdyValueObjectClass", "The contained value"),
                        G_TYPE_VALUE,
                        G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_STATIC_STRINGS);

  g_object_class_install_properties (object_class,
                                     N_PROPS,
                                     props);
}

static void
hdy_value_object_init (HdyValueObject *self)
{
}

/**
 * hdy_value_object_get_value: (attributes org.gtk.Method.get_property=value)
 * @value: the value
 *
 * Return the contained value.
 *
 * Returns: (transfer none): the contained [struct@GObject.Value]
 *
 * Since: 1.0
 */
const GValue*
hdy_value_object_get_value (HdyValueObject *value)
{
  return &value->value;
}

/**
 * hdy_value_object_copy_value:
 * @value: the value
 * @dest: value with correct type to copy into
 *
 * Copy data from the contained [struct@GObject.Value] into @dest.
 *
 * Since: 1.0
 */
void
hdy_value_object_copy_value (HdyValueObject *value,
                             GValue         *dest)
{
  g_value_copy (&value->value, dest);
}

/**
 * hdy_value_object_get_string:
 * @value: the value
 *
 * Returns the contained string if the value is of type `G_TYPE_STRING`.
 *
 * Returns: (transfer none): the contained string
 *
 * Since: 1.0
 */
const gchar*
hdy_value_object_get_string (HdyValueObject *value)
{
  return g_value_get_string (&value->value);
}

/**
 * hdy_value_object_dup_string:
 * @value: the value
 *
 * Gets a copy of the contained string if the value is of type `G_TYPE_STRING`.
 *
 * Returns: (transfer full): a copy of the contained string
 *
 * Since: 1.0
 */
gchar*
hdy_value_object_dup_string (HdyValueObject *value)
{
  return g_value_dup_string (&value->value);
}
