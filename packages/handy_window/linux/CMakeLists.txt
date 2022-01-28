cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "handy_window")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "handy_window_plugin")

add_library(${PLUGIN_NAME} SHARED
  "handy_window.cc"
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

cmake_policy(SET CMP0077 NEW)
option(LIBHANDY_ENABLED "Enable libhandy" ON)
if(LIBHANDY_ENABLED)
  pkg_check_modules(LIBHANDY IMPORTED_TARGET libhandy-1)
  if(LIBHANDY_FOUND)
    add_definitions("-DHAVE_LIBHANDY")
    target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::LIBHANDY)
  endif(LIBHANDY_FOUND)
endif(LIBHANDY_ENABLED)

# List of absolute paths to libraries that should be bundled with the plugin
set(handy_window_bundled_libraries
  ""
  PARENT_SCOPE
)
