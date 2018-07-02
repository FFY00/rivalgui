source_dir = include_directories('.')

rivalgui_sources = [
    'rivalgui/app.d',
#    'rivalgui/appwindow.d',
    'rivalgui/buttons.d',
    'rivalgui/util/ledcolor.d'
]

#rivalgui_lib = static_library('rivalgui', rivalgui_sources,
#                                include_directories: inc,
#                                dependencies: [gtkd_dep, hidapid_dep])

# 
conf = configuration_data()
conf.set('VERSION', meson.project_version())
conf.set('pkgdatadir', pkgdatadir)

generated_main = configure_file(input:  'main.d.in',
                                output: 'main.d',
                                configuration: conf,
                                install: true,
                                install_dir: get_option('bindir'))
rivalgui_sources += generated_main

# Executables
rivalgui_exe = executable('rivalgui', [rivalgui_sources, resources],
                            include_directories: source_dir,
                            dependencies: [gtkd_dep, hidapid_dep],
                            d_args: '-g', # DEBUG (gdb)
                            install: true)