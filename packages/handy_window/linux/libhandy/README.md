# libhandy

The `handy_window` package includes:

- `linux/libhandy/CMakeLists.txt` - build config for libhandy
- `linux/libhandy/src` - libhandy subtree
- `linux/libhandy/build` - generated libhandy headers and sources
- `linux/libhandy/upgrade.sh` - script to upgrade libhandy

A Flutter-compatible CMake build config and pre-generated headers and sources
are included to avoid a dependency on the Meson build system used by libhandy.

### Upgrading libhandy

Run the `upgrade.sh` script in `handy_window/linux/libhandy`:
```sh
$ ./path/to/handy_window/linux/libhandy/upgrade.sh 1.2.3
```

Or manually:

```sh
# pull libhandy
$ git -C /path/to/ubuntu-flutter-plugins subtree pull \
    --prefix packages/handy_window/linux/libhandy/src
    https://gitlab.gnome.org/GNOME/libhandy.git 1.2.3 --squash

# build libhandy
$ cd /path/to/handy_window/linux/libhandy/src
$ meson ../build
$ ninja -C ../build
$ git status

# commit generated headers and sources
$ git commit /path/to/handy_window/linux/libhandy/build
```
