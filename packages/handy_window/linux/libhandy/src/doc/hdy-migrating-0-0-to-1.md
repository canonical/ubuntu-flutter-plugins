Title: Migrating from Handy 0.0.x to Handy 1
Slug: migrating-from-handy-0-to-1

# Migrating from Handy 0.0.x to Handy 1

Handy 1 is a major new version of Handy that breaks both API and ABI compared to
Handy 0.0.x. Thankfully, most of the changes are not hard to adapt to and there
are a number of steps that you can take to prepare your Handy 0.0.x application
for the switch to Handy 1. After that, there's a number of adjustments that you
may have to do when you actually switch your application to build against Handy
1.

## Preparation in Handy 0.0.x

The steps outlined in the following sections assume that your application is
working with Handy 0.0.13, which is the final stable release of Handy 0.0.x. It
includes all the necessary APIs and tools to help you port your application to
Handy 1. If you are using an older version of Handy 0.0.x, you should first get
your application to build and work with Handy 0.0.13.

### Do not use the static build option

Static linking support has been removed, and so did the static build option. You
must adapt you program to link to the library dynamically, using the
`package_subdir` build option if needed.

### Do not use deprecated symbols

Over the years, a number of functions, and in some cases, entire widgets have
been deprecated. These deprecations are clearly spelled out in the API
reference, with hints about the recommended replacements. The API reference for
GTK 3 also includes an
[index](https://developer.puri.sm/projects/libhandy/unstable/deprecated-api-index.html)
of all deprecated symbols.

## Changes that need to be done at the time of the switch

This section outlines porting tasks that you need to tackle when you get to the
point that you actually build your application against Handy 1. Making it
possible to prepare for these in Handy 0.0 would have been either impossible or
impractical.

### `hdy_init()` takes no parameters

[func@init] has been modified to take no parameters. It must be called just
after initializing GTK, if you are using [class@Gtk.Application] it means it
must be called when the [signal@Gio.Application::startup] signal is emitted.

It initializes the localization, the types, the themes, and the icons.

### Adapt to widget constructor changes

All widget constructors now return the [class@Gtk.Widget] type rather than the
constructed widget's type, following the same convention as GTK 3.

Affected widgets:

* [class@ActionRow]
* [class@ComboRow]
* [class@ExpanderRow]
* [class@PreferencesGroup]
* [class@PreferencesPage]
* [class@PreferencesRow]
* [class@PreferencesWindow]
* [class@Squeezer]
* [class@TitleBar]
* [class@ViewSwitcherBar]
* [class@ViewSwitcher]

### Adapt to derivability changes

Some widgets are now final, if your code is deriving from them, use composition
instead.

Affected widgets:

* [class@Squeezer]
* [class@ViewSwitcherBar]
* [class@ViewSwitcher]

### HdyFold has been removed

HdyFold has been removed. This affects the API of [class@Leaflet], see the
[Adapt to HdyLeaflet API changes](#adapt-to-hdyleaflet-api-changes) section to know how.

### Replace HdyColumn by HdyClamp

HdyColumn has been renamed [class@Clamp] as it now implements
[iface@Gtk.Orientable], so you should replace the former by the later. Its
`maximum-width` and `linear-growth-width` properties have been renamed
[property@Clamp:maximum-size] and [property@Clamp:tightening-threshold]
respectively to better reflect their role. It won't set the `.narrow`, `.medium`
and `.wide` style classes depending on its size, but the `.small`, `.medium` and
`.large` ones instead.

### Adapt to HdyPaginator API changes

HdyPaginator has been renamed [class@Carousel], so you should replace the former
by the later.

The `indicator-style`, `indicator-spacing` and `center-content` properties have
been removed, instead use [class@CarouselIndicatorDots] or
[class@CarouselIndicatorLines] widgets.

### Adapt to HdyHeaderGroup API changes

The [class@HeaderGroup] object has been largely redesigned, most of its methods
changed, see its documentation to know more.

The child type is now [class@HeaderGroupChild], which can represent either a
[class@Gtk.HeaderBar], a [class@HeaderBar], or a [class@HeaderGroup].

The `focus` property has been replaced by [property@HeaderGroup:decorate-all],
which works quite differently.

### Adapt to HdyLeaflet API changes

The HdyFold type has been removed in favor of using a boolean, and
[class@Leaflet] adjusted to that as the `fold` property has been removed in
favor of [property@Leaflet:folded]. Also, the [method@Leaflet.get_homogeneous]
and [method@Leaflet.set_homogeneous] getters take a boolean parameter instead of
a HdyFold.

On touchscreens, swiping forward with the `over` transition and swiping back
with the `under` transition can now only be done from the edge where the upper
child is.

The `over` and `under` transitions can draw their shadow on top of the window's
transparent areas, like the rounded corners. This is a side-effect of allowing
shadows to be drawn on top of OpenGL areas. It can be mitigated by using
[class@Window] or [class@ApplicationWindow] as they will crop anything drawn
beyond the rounded corners.

The `allow-visible` child property has been renamed `navigatable`.

The `none` transition type has been removed. The default value for the
[property@Leaflet:transition-type] property has been changed to `over`. `over`
is the recommended transition for typical [class@Leaflet] use-cases, if this
isn't what you want to use, be sure to adapt your code. If transitions are
undesired, set [property@Leaflet:mode-transition-duration] and
[property@Leaflet:child-transition-duration] properties to `0`.

### Adapt to HdyViewSwitcher API changes

[class@ViewSwitcher] doesn't subclass [class@Gtk.Box] anymore. Instead, it
subclasses [class@Gtk.Bin] and contains a box.

The `icon-size` property has been dropped without replacement, you must stop
using it.

### Adapt to HdyViewSwitcherBar API changes

[class@ViewSwitcherBar] won't be revealed if the
[property@ViewSwitcherBar:stack] property is `NULL` or if it has less than two
pages, even if you set [property@ViewSwitcherBar:reveal] to `TRUE`.

The `icon-size` property has been dropped without replacement, you must stop
using it.

### Adapt to CSS node name changes

Widgets with a custom CSS node name got their name changed to be the class' name
in lowercase, with no separation between words, and with no namespace prefix.
E.g. the CSS node name of [class@ViewSwitcher] is `viewswitcher`.

### Adapt to HdyActionRow API changes

Action items were packed from the end toward the start of the row. It is now
reversed, and widgets have to be packed from the start to the end.

It isn't possible to add children at the bottom of a [class@ActionRow] anymore,
instead use other widgets like [class@ExpanderRow]. Widgets added to a
[class@ActionRow] will now be added at the end of the row, and the
`hdy_action_row_add_action()` method and the action child type have been removed.

The main horizontal box of [class@ActionRow] had the row-header CSS style class,
it now has the header CSS style class and can hence be accessed as `box.header`
subnode.

[class@ActionRow] is now unactivatable by default, giving it an activatable
widget will automatically make it activatable.

### Adapt to HdyComboRow API changes

[class@ComboRow] is now unactivatable by default, binding and unbinding a model
will toggle its activatability.

### Adapt to HdyExpanderRow API changes

[class@ExpanderRow] doesn't descend from [class@ActionRow] anymore but from
[class@PreferencesRow]. It reimplements some features from [class@ActionRow],
like the [property@PreferencesRow:title], [property@ExpanderRow:subtitle],
[property@PreferencesRow:use-underline] and [property@ExpanderRow:icon-name],
but it doesn't offer the "activate" signal nor the ability to add widgets in its
header row.

Widgets you add to it will be added to its inner [class@Gtk.ListBox].

### Adapt to HdyPreferencesPage API changes

[class@PreferencesPage] doesn't subclass [class@Gtk.ScrolledWindow] anymore.
Instead, it subclasses [class@Gtk.Bin] and contains a scrolled window.

### Adapt to HdyPreferencesGroup API changes

[class@PreferencesGroup] doesn't subclass [class@Gtk.Box] anymore. Instead, it
subclasses [class@Gtk.Bin] and contains a box.

### Adapt to HdyKeypad API changes

[class@Keypad] doesn't subclass [class@Gtk.Grid] anymore. Instead, it subclasses
[class@Gtk.Bin] and contains a grid.

The `show-symbols` property has been replaced by
[property@Keypad:letters-visible].

The `only-digits` property has been replaced by
[property@Keypad:symbols-visible], which has a inverse boolean meaning. This
also affects the corresponding parameter of the constructor.

The `left-action` property has been replaced by [property@Keypad:start-action],
and the `right-action` property has been replaced by
[property@Keypad:end-action].

The `entry` property isn't a [class@Gtk.Widget] anymore but a [class@Gtk.Entry].

### Stop using `hdy_list_box_separator_header()`

Instead, either use CSS styling (the `list.content` style class may fit your
need), or implement it yourself as it is trivial.

### Stop acknowledging the instability

When the library was young and changing a lot, we required you to acknowledge
that your are using an unstable API. To do so, you had to define
`HANDY_USE_UNSTABLE_API` for compilation to succeed.

The API remained stable since many versions, despite this acknowledgment still
being required. To reflect that proven stability, the acknowledgment isn't
necessary and you can stop defining `HANDY_USE_UNSTABLE_API`, either before
including the Libhandy; header in C-compatible languages, or with the definition
option of your compiler.
