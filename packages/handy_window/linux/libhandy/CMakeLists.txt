cmake_minimum_required(VERSION 3.10)
project(handy LANGUAGES C)

set(LIBHANDY_BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/build")
set(LIBHANDY_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

add_library(handy SHARED
  "${LIBHANDY_BUILD_DIR}/src/hdy-enums-private.c"
  "${LIBHANDY_BUILD_DIR}/src/hdy-enums.c"
  "${LIBHANDY_BUILD_DIR}/src/hdy-public-types.c"
  "${LIBHANDY_BUILD_DIR}/src/hdy-resources.c"
  
  "${LIBHANDY_SOURCE_DIR}/src/gtkprogresstracker.c"
  "${LIBHANDY_SOURCE_DIR}/src/gtk-window.c"

  "${LIBHANDY_SOURCE_DIR}/src/hdy-action-row.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-animation.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-application-window.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-avatar.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-avatar-icon.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-bidi.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-carousel-box.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-carousel.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-carousel-indicator-dots.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-carousel-indicator-lines.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-clamp.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-combo-row.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-css.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-deck.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-enum-value-object.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-expander-row.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-fading-label.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-flap.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-header-bar.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-header-group.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-keypad-button.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-keypad.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-leaflet.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-main.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-navigation-direction.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-nothing.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-preferences-group.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-preferences-page.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-preferences-row.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-preferences-window.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-search-bar.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-settings.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-shadow-helper.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-squeezer.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-stackable-box.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-status-page.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-style-manager.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-swipeable.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-swipe-group.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-swipe-tracker.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-tab-bar.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-tab-box.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-tab.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-tab-view.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-title-bar.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-value-object.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-view-switcher-bar.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-view-switcher-button.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-view-switcher.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-view-switcher-title.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-window.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-window-handle.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-window-handle-controller.c"
  "${LIBHANDY_SOURCE_DIR}/src/hdy-window-mixin.c"
)

target_compile_definitions(handy PRIVATE HANDY_COMPILATION)

target_include_directories(handy PUBLIC
  "${LIBHANDY_BUILD_DIR}/src"
  "${LIBHANDY_SOURCE_DIR}/src"
)

target_include_directories(handy PRIVATE
  "${LIBHANDY_BUILD_DIR}"
)

set_target_properties(handy PROPERTIES
    SOVERSION 0
    PREFIX lib
    OUTPUT_NAME handy-1
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
target_link_libraries(handy PRIVATE PkgConfig::GTK)
