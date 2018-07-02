project('rivalgui', 'd',
    version: '0.0.1',
    license: 'AGPLv3')

# Declare required directories
datadir = get_option('datadir')
prefix = get_option('prefix')
appdatadir = join_paths (datadir, 'appdata')
desktopdir = join_paths (datadir, 'applications')
pkgdatadir = join_paths(prefix, datadir, meson.project_name())

# Dependencie Versions
gtkd_ver = '>=3.6'
hidapid_ver = '>=1.0.2'
#schemas_ver = '>=3.8.0'
libratbag_ver = '>=0.9.901'

# Dependencies
gtkd_dep = dependency('gtkd-3', version: gtkd_ver)
hidapid_dep = dependency('hidapid', version: hidapid_ver)
#gsettings_desktop_schemas_dep = dependency('gsettings-desktop-schemas',
#                                            version: schemas_ver)
libratbag_dep = dependency('libratbag', version: libratbag_ver) # We only need the assets

if not libratbag_dep.found()
    warning('Libratbag not found! Assets are missing...')
endif

# Declare the app id
app_id = 'org.aurorafoss.rivalgui'

# Subdirs
subdir('data')
subdir('source')

# Postbuild
meson.add_install_script('build-aux/meson/postinstall.py')