cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "handy_window")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "handy_window_plugin")

add_library(${PLUGIN_NAME} SHARED
  "handy_window_plugin.cc"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# libhandy requires g_atomic_ref_count_init/inc/dec available since 2.58
pkg_check_modules(GLIB glib-2.0>=2.58)
if(GLIB_FOUND)
  # List of absolute paths to libraries that should be bundled with the plugin
  set(handy_window_bundled_libraries
    "$<TARGET_FILE:handy>"
    PARENT_SCOPE
  )

  add_subdirectory(libhandy)
  add_definitions(-DHAVE_LIBHANDY)
  target_link_libraries(${PLUGIN_NAME} PRIVATE handy)
else()
  message(WARNING "The `handy_window` package requires libglib2.0-0 >= 2.58 available in Ubuntu 20.04 and later. Using normal Flutter window instead.")
endif()
