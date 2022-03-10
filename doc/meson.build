if get_option('gtk_doc')

expand_content_md_files = [
  'build-howto.md',
  'hdy-migrating-0-0-to-1.md',
  'visual-index.md',
]

toml_data = configuration_data()
toml_data.set('VERSION', meson.project_version())

libhandy_toml = configure_file(
  input: 'libhandy.toml.in',
  output: 'libhandy.toml',
  configuration: toml_data
)

dependency('gi-docgen', version: '>= 2021.1',
           fallback: ['gi-docgen', 'dummy_dep'],
           native: true,
           required: get_option('gtk_doc'))

gidocgen = find_program('gi-docgen')

docs_dir = datadir / 'doc'

custom_target('libhandy-doc',
  input: [ libhandy_toml, libhandy_gir[0] ],
  output: 'libhandy-@0@'.format(apiversion),
  command: [
    gidocgen,
    'generate',
    '--quiet',
    '--add-include-path=@0@'.format(meson.current_build_dir() / '../../src'),
    '--config=@INPUT0@',
    '--output-dir=@OUTPUT@',
    '--no-namespace-dir',
    '--content-dir=@0@'.format(meson.current_source_dir()),
    '@INPUT1@',
  ],
  depend_files: [ expand_content_md_files ],
  build_by_default: true,
  install: true,
  install_dir: docs_dir,
)

endif
