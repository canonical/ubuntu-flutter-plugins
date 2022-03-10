/*
 * Copyright (C) 2019 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "config.h"
#include <glib/gi18n-lib.h>

#include "hdy-preferences-group-private.h"

#include "hdy-css-private.h"
#include "hdy-preferences-row.h"

/**
 * HdyPreferencesGroup:
 *
 * A group of preference rows.
 *
 * A `HdyPreferencesGroup` represents a group or tightly related preferences,
 * which in turn are represented by [class@PreferencesRow].
 *
 * To summarize the role of the preferences it gathers, a group can have both a
 * title and a description. The title will be used by [class@PreferencesWindow]
 * to let the user look for a preference.
 *
 * ## CSS nodes
 *
 * `HdyPreferencesGroup` has a single CSS node with name `preferencesgroup`.
 *
 * Since: 1.0
 */

typedef struct
{
  GtkWidget *box;
  GtkLabel *description;
  GtkListBox *listbox;
  GtkBox *listbox_box;
  GtkLabel *title;
} HdyPreferencesGroupPrivate;

G_DEFINE_TYPE_WITH_PRIVATE (HdyPreferencesGroup, hdy_preferences_group, GTK_TYPE_BIN)

enum {
  PROP_0,
  PROP_DESCRIPTION,
  PROP_TITLE,
  PROP_USE_MARKUP,
  LAST_PROP,
};

static GParamSpec *props[LAST_PROP];

static void
update_title_visibility (HdyPreferencesGroup *self)
{
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (self);

  gtk_widget_set_visible (GTK_WIDGET (priv->title),
                          gtk_label_get_text (priv->title) != NULL &&
                          g_strcmp0 (gtk_label_get_text (priv->title), "") != 0);
}

static void
update_description_visibility (HdyPreferencesGroup *self)
{
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (self);

  gtk_widget_set_visible (GTK_WIDGET (priv->description),
                          gtk_label_get_text (priv->description) != NULL &&
                          g_strcmp0 (gtk_label_get_text (priv->description), "") != 0);
}

static void
update_listbox_visibility (HdyPreferencesGroup *self)
{
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (self);
  g_autoptr(GList) children = NULL;

  /* We must wait until the listbox has been built and added. */
  if (priv->listbox == NULL)
    return;

  children = gtk_container_get_children (GTK_CONTAINER (priv->listbox));

  gtk_widget_set_visible (GTK_WIDGET (priv->listbox), children != NULL);
}

static gboolean
listbox_keynav_failed_cb (HdyPreferencesGroup *self,
                          GtkDirectionType     direction)
{
  GtkWidget *toplevel = gtk_widget_get_toplevel (GTK_WIDGET (self));

  if (!toplevel)
    return FALSE;

  if (direction != GTK_DIR_UP && direction != GTK_DIR_DOWN)
    return FALSE;

  return gtk_widget_child_focus (toplevel, direction == GTK_DIR_UP ?
                                 GTK_DIR_TAB_BACKWARD : GTK_DIR_TAB_FORWARD);
}

typedef struct {
  HdyPreferencesGroup *group;
  GtkCallback callback;
  gpointer callback_data;
} ForallData;

static void
for_non_internal_child (GtkWidget *widget,
                        gpointer   callback_data)
{
  ForallData *data = callback_data;
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (data->group);

  if (widget != (GtkWidget *) priv->listbox)
    data->callback (widget, data->callback_data);
}

static void
hdy_preferences_group_forall (GtkContainer *container,
                              gboolean      include_internals,
                              GtkCallback   callback,
                              gpointer      callback_data)
{
  HdyPreferencesGroup *self = HDY_PREFERENCES_GROUP (container);
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (self);
  ForallData data;

  if (include_internals) {
    GTK_CONTAINER_CLASS (hdy_preferences_group_parent_class)->forall (GTK_CONTAINER (self), include_internals, callback, callback_data);

    return;
  }

  data.group = self;
  data.callback = callback;
  data.callback_data = callback_data;

  if (priv->listbox)
    GTK_CONTAINER_GET_CLASS (priv->listbox)->forall (GTK_CONTAINER (priv->listbox), include_internals, callback, callback_data);
  if (priv->listbox_box)
    GTK_CONTAINER_GET_CLASS (priv->listbox_box)->forall (GTK_CONTAINER (priv->listbox_box), include_internals, for_non_internal_child, &data);
}

static void
hdy_preferences_group_get_property (GObject    *object,
                                    guint       prop_id,
                                    GValue     *value,
                                    GParamSpec *pspec)
{
  HdyPreferencesGroup *self = HDY_PREFERENCES_GROUP (object);

  switch (prop_id) {
  case PROP_DESCRIPTION:
    g_value_set_string (value, hdy_preferences_group_get_description (self));
    break;
  case PROP_TITLE:
    g_value_set_string (value, hdy_preferences_group_get_title (self));
    break;
  case PROP_USE_MARKUP:
    g_value_set_boolean (value, hdy_preferences_group_get_use_markup (self));
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_preferences_group_set_property (GObject      *object,
                                    guint         prop_id,
                                    const GValue *value,
                                    GParamSpec   *pspec)
{
  HdyPreferencesGroup *self = HDY_PREFERENCES_GROUP (object);

  switch (prop_id) {
  case PROP_DESCRIPTION:
    hdy_preferences_group_set_description (self, g_value_get_string (value));
    break;
  case PROP_TITLE:
    hdy_preferences_group_set_title (self, g_value_get_string (value));
    break;
  case PROP_USE_MARKUP:
    hdy_preferences_group_set_use_markup (self, g_value_get_boolean (value));
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_preferences_group_destroy (GtkWidget *widget)
{
  HdyPreferencesGroup *self = HDY_PREFERENCES_GROUP (widget);
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (self);

  /*
   * Since we overload forall(), the inherited destroy() won't work as normal.
   * Remove internal widgets ourselves.
   */
  g_clear_pointer ((GtkWidget **) &priv->box, gtk_widget_destroy);
  priv->description = NULL;
  priv->listbox = NULL;
  priv->listbox_box = NULL;
  priv->title = NULL;

  GTK_WIDGET_CLASS (hdy_preferences_group_parent_class)->destroy (widget);
}

static void
hdy_preferences_group_add (GtkContainer *container,
                           GtkWidget    *child)
{
  HdyPreferencesGroup *self = HDY_PREFERENCES_GROUP (container);
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (self);

  if (priv->title == NULL || priv->description == NULL || priv->listbox_box == NULL) {
    GTK_CONTAINER_CLASS (hdy_preferences_group_parent_class)->add (container, child);

    return;
  }

  if (HDY_IS_PREFERENCES_ROW (child))
    gtk_container_add (GTK_CONTAINER (priv->listbox), child);
  else
    gtk_container_add (GTK_CONTAINER (priv->listbox_box), child);
}

static void
hdy_preferences_group_remove (GtkContainer *container,
                              GtkWidget    *child)
{
  HdyPreferencesGroup *self = HDY_PREFERENCES_GROUP (container);
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (self);

  if (child == priv->box)
    GTK_CONTAINER_CLASS (hdy_preferences_group_parent_class)->remove (container, child);
  else if (HDY_IS_PREFERENCES_ROW (child))
    gtk_container_remove (GTK_CONTAINER (priv->listbox), child);
  else if (child != GTK_WIDGET (priv->listbox))
    gtk_container_remove (GTK_CONTAINER (priv->listbox_box), child);
}

static void
hdy_preferences_group_class_init (HdyPreferencesGroupClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
  GtkContainerClass *container_class = GTK_CONTAINER_CLASS (klass);

  object_class->get_property = hdy_preferences_group_get_property;
  object_class->set_property = hdy_preferences_group_set_property;

  widget_class->destroy = hdy_preferences_group_destroy;

  widget_class->size_allocate = hdy_css_size_allocate_bin;
  widget_class->get_preferred_height = hdy_css_get_preferred_height;
  widget_class->get_preferred_height_for_width = hdy_css_get_preferred_height_for_width;
  widget_class->get_preferred_width = hdy_css_get_preferred_width;
  widget_class->get_preferred_width_for_height = hdy_css_get_preferred_width_for_height;
  widget_class->draw = hdy_css_draw_bin;

  container_class->add = hdy_preferences_group_add;
  container_class->remove = hdy_preferences_group_remove;
  container_class->forall = hdy_preferences_group_forall;

  /**
   * HdyPreferencesGroup:description: (attributes org.gtk.Property.get=hdy_preferences_group_get_description org.gtk.Property.set=hdy_preferences_group_set_description)
   *
   * The description for this group of preferences.
   *
   * Since: 1.0
   */
  props[PROP_DESCRIPTION] =
    g_param_spec_string ("description",
                         _("Description"),
                         _("Description"),
                         "",
                         G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);

  /**
   * HdyPreferencesGroup:title: (attributes org.gtk.Property.get=hdy_preferences_group_get_title org.gtk.Property.set=hdy_preferences_group_set_title)
   *
   * The title for this group of preferences.
   *
   * Since: 1.0
   */
  props[PROP_TITLE] =
    g_param_spec_string ("title",
                         _("Title"),
                         _("Title"),
                         "",
                         G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);

  /**
   * HdyPreferencesGroup:use-markup: (attributes org.gtk.Property.get=hdy_preferences_group_get_use_markup org.gtk.Property.set=hdy_preferences_group_set_use_markup)
   *
   * Whether to use markup for the title and description.
   *
   * Since: 1.4
   */
  props[PROP_USE_MARKUP] =
    g_param_spec_boolean ("use-markup",
                          _("Use markup"),
                          _("Whether to use markup for the title and description"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);

  g_object_class_install_properties (object_class, LAST_PROP, props);

  gtk_widget_class_set_css_name (widget_class, "preferencesgroup");
  gtk_widget_class_set_template_from_resource (widget_class,
                                               "/sm/puri/handy/ui/hdy-preferences-group.ui");
  gtk_widget_class_bind_template_child_private (widget_class, HdyPreferencesGroup, box);
  gtk_widget_class_bind_template_child_private (widget_class, HdyPreferencesGroup, description);
  gtk_widget_class_bind_template_child_private (widget_class, HdyPreferencesGroup, listbox);
  gtk_widget_class_bind_template_child_private (widget_class, HdyPreferencesGroup, listbox_box);
  gtk_widget_class_bind_template_child_private (widget_class, HdyPreferencesGroup, title);
  gtk_widget_class_bind_template_callback (widget_class, update_listbox_visibility);
  gtk_widget_class_bind_template_callback (widget_class, listbox_keynav_failed_cb);
}

static void
hdy_preferences_group_init (HdyPreferencesGroup *self)
{
  gtk_widget_init_template (GTK_WIDGET (self));

  update_description_visibility (self);
  update_title_visibility (self);
  update_listbox_visibility (self);
}

/**
 * hdy_preferences_group_new:
 *
 * Creates a new `HdyPreferencesGroup`.
 *
 * Returns: the newly created `HdyPreferencesGroup`
 *
 * Since: 1.0
 */
GtkWidget *
hdy_preferences_group_new (void)
{
  return g_object_new (HDY_TYPE_PREFERENCES_GROUP, NULL);
}

/**
 * hdy_preferences_group_get_title: (attributes org.gtk.Method.get_property=title)
 * @self: a preferences group
 *
 * Gets the title of @self.
 *
 * Returns: the title of @self
 *
 * Since: 1.0
 */
const gchar *
hdy_preferences_group_get_title (HdyPreferencesGroup *self)
{
  HdyPreferencesGroupPrivate *priv;

  g_return_val_if_fail (HDY_IS_PREFERENCES_GROUP (self), NULL);

  priv = hdy_preferences_group_get_instance_private (self);

  return gtk_label_get_text (priv->title);
}

/**
 * hdy_preferences_group_set_title: (attributes org.gtk.Method.set_property=title)
 * @self: a preferences group
 * @title: the title
 *
 * Sets the title for @self.
 *
 * Since: 1.0
 */
void
hdy_preferences_group_set_title (HdyPreferencesGroup *self,
                                 const gchar         *title)
{
  HdyPreferencesGroupPrivate *priv;

  g_return_if_fail (HDY_IS_PREFERENCES_GROUP (self));

  priv = hdy_preferences_group_get_instance_private (self);

  if (g_strcmp0 (gtk_label_get_label (priv->title), title) == 0)
    return;

  gtk_label_set_label (priv->title, title);
  update_title_visibility (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_TITLE]);
}

/**
 * hdy_preferences_group_get_description: (attributes org.gtk.Method.get_property=description)
 * @self: a preferences group
 *
 * Returns: the description of @self
 *
 * Since: 1.0
 */
const gchar *
hdy_preferences_group_get_description (HdyPreferencesGroup *self)
{
  HdyPreferencesGroupPrivate *priv;

  g_return_val_if_fail (HDY_IS_PREFERENCES_GROUP (self), NULL);

  priv = hdy_preferences_group_get_instance_private (self);

  return gtk_label_get_text (priv->description);
}

/**
 * hdy_preferences_group_set_description: (attributes org.gtk.Method.set_property=description)
 * @self: a preferences group
 * @description: the description
 *
 * Sets the description for @self.
 *
 * Since: 1.0
 */
void
hdy_preferences_group_set_description (HdyPreferencesGroup *self,
                                       const gchar         *description)
{
  HdyPreferencesGroupPrivate *priv;

  g_return_if_fail (HDY_IS_PREFERENCES_GROUP (self));

  priv = hdy_preferences_group_get_instance_private (self);

  if (g_strcmp0 (gtk_label_get_label (priv->description), description) == 0)
    return;

  gtk_label_set_label (priv->description, description);
  update_description_visibility (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_DESCRIPTION]);
}

/**
 * hdy_preferences_group_get_use_markup: (attributes org.gtk.Method.get_property=use-markup)
 * @self: a preferences group
 *
 * Gets whether @self uses markup for the title and description.
 *
 * Returns: whether @self uses markup for its labels
 *
 * Since: 1.4
 */
gboolean
hdy_preferences_group_get_use_markup (HdyPreferencesGroup *self)
{
  HdyPreferencesGroupPrivate *priv;

  g_return_val_if_fail (HDY_IS_PREFERENCES_GROUP (self), FALSE);

  priv = hdy_preferences_group_get_instance_private (self);

  return gtk_label_get_use_markup (priv->title);
}

/**
 * hdy_preferences_group_set_use_markup: (attributes org.gtk.Method.set_property=use-markup)
 * @self: a preferences group
 * @use_markup: whether to use markup
 *
 * Sets whether @self uses markup for the title and description.
 *
 * Since: 1.4
 */
void
hdy_preferences_group_set_use_markup (HdyPreferencesGroup *self,
                                      gboolean             use_markup)
{
  HdyPreferencesGroupPrivate *priv;

  g_return_if_fail (HDY_IS_PREFERENCES_GROUP (self));

  priv = hdy_preferences_group_get_instance_private (self);

  use_markup = !!use_markup;

  if (gtk_label_get_use_markup (priv->title) == use_markup)
    return;

  gtk_label_set_use_markup (priv->title, use_markup);
  gtk_label_set_use_markup (priv->description, use_markup);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_USE_MARKUP]);
}

static void
add_preferences_to_model (HdyPreferencesRow *row,
                          GListStore        *model)
{
  const gchar *title;

  g_assert (HDY_IS_PREFERENCES_ROW (row));
  g_assert (G_IS_LIST_STORE (model));

  if (!gtk_widget_get_visible (GTK_WIDGET (row)))
    return;

  title = hdy_preferences_row_get_title (row);

  if (!title || !*title)
    return;

  g_list_store_append (model, row);
}

/*< private >
 * hdy_preferences_group_add_preferences_to_model: (skip)
 * @self: a preferences group
 * @model: the model
 *
 * Add preferences from @self to the model.
 *
 * Since: 1.0
 */
void
hdy_preferences_group_add_preferences_to_model (HdyPreferencesGroup *self,
                                                GListStore          *model)
{
  HdyPreferencesGroupPrivate *priv = hdy_preferences_group_get_instance_private (self);

  g_return_if_fail (HDY_IS_PREFERENCES_GROUP (self));
  g_return_if_fail (G_IS_LIST_STORE (model));

  if (!gtk_widget_get_visible (GTK_WIDGET (self)))
    return;

  gtk_container_foreach (GTK_CONTAINER (priv->listbox), (GtkCallback) add_preferences_to_model, model);
}
