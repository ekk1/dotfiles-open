vim9script


import autoload "../lib/ftfunctions/go.vim"

b:FilterOutline = go.FilterOutline
b:CurrentItem = go.CurrentItem

# OBS! b:OutlinePreProcess (user-defined) shall be placed in the main
# /ftplugin folder
