vim9script


import autoload "../lib/ftfunctions/markdown.vim"

b:FilterOutline = markdown.FilterOutline
b:CurrentItem = markdown.CurrentItem

# OBS! b:OutlinePreProcess (user-defined) shall be placed in the main
# /ftplugin folder
