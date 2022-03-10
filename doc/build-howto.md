Title: Compiling with Libhandy
Slug: build-howto

# Compiling with Libhandy

If you need to build Libhandy, get the source from
[here](https://gitlab.gnome.org/GNOME/libhandy/) and see the `README.md` file.

## Using pkg-config

Like other GNOME libraries, Libhandy uses `pkg-config` to provide compiler
options. The package name is `libhandy-1`.


If you use Automake/Autoconf, in your `configure.ac` script, you might specify
something like:

```autoconf
PKG_CHECK_MODULES(LIBHANDY, [libhandy-1])
AC_SUBST(LIBHANDY_CFLAGS)
AC_SUBST(LIBHANDY_LIBS)
```

Or when using the Meson build system you can declare a dependency like:

```meson
dependency('libhandy-1')
```

The `1` in the package name is the "API version" (indicating "the version of the
Libhandy API that first appeared in version 1") and is essentially just part of
the package name.

## Bundling the library

As Libhandy uses the Meson build system, bundling it as a subproject when it is
not installed is easy. Add this to your `meson.build`:

```meson
libhandy_dep = dependency('libhandy-1', version: '>= 1', required: false)
if not libhandy_dep.found()
  libhandy = subproject(
    'libhandy',
    install: false,
    default_options: [
      'examples=false',
      'package_subdir=my-project-name',
      'tests=false',
    ]
  )
  libhandy_dep = libhandy.get_variable('libhandy_dep')
endif
```

Then add Libhandy as a git submodule:

```bash
git submodule add https://gitlab.gnome.org/GNOME/libhandy.git subprojects/libhandy
```

To bundle the library with your Flatpak application, add the following module to
your manifest:

```json
{
  "name" : "libhandy",
  "buildsystem" : "meson",
  "config-opts": [
    "-Dexamples=false",
    "-Dtests=false"
  ],
  "sources" : [
    {
      "type" : "git",
      "url" : "https://gitlab.gnome.org/GNOME/libhandy.git"
    }
  ]
}
```

## Building on macOS

To build on macOS you need to install the build-dependencies first. This can
e.g. be done via [brew](https://brew.sh):

```bash
brew install pkg-config gtk+3 adwaita-icon-theme meson glade gobject-introspection vala
```

After running the command above, one may now build the library:

```bash
git clone https://gitlab.gnome.org/GNOME/libhandy.git
cd libhandy
meson . _build
ninja -C _build test
ninja -C _build install
```

Working with the library on macOS is pretty much the same as on Linux. To link
it, use `pkg-config`:

```bash
gcc $(pkg-config --cflags --libs gtk+-3.0) $(pkg-config --cflags --libs libhandy-1) main.c -o main
```
