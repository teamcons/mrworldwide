# project name and programming language
project(
  'io.github.teamcons.mrworldwide',
  'vala', 'c',
  version: '0.1'
)

# Include Gnome and the translations module
gnome = import('gnome')
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

## Set de config data
config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

gresource = gnome.compile_resources(
    'as-resources',
    'data' / 'mrworldwide.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# List the dependencies we need
deps = [
    dependency('granite-7'),
    dependency('gtk4')
]

# Create a new executable, list the files we want to compile, and install
executable(
    meson.project_name(),
    config_file,
    gresource,
    'src' / 'Constants.vala',
    'src' / 'Objects' / 'Lang.vala',
    'src' / 'Widgets' / 'Menu.vala',
    'src' / 'Widgets' / 'ShowLangs.vala',
    'src' / 'Widgets' / 'Pane.vala',
    'src' / 'Windows' / 'Window.vala',
    'src' / 'Application.vala',
    dependencies: deps,
    install: true
)

subdir('data')
subdir('po')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)