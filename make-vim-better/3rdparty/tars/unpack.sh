mkdir -p content

ar x vim-airline_0.11-2_all.deb
tar -xJvf data.tar.xz
mv usr/share/vim-airline content/
rm -rf data.tar.xz usr/ control.tar.xz debian-binary

ar x vim-airline-themes_0+git.20220712-55bad92-1_all.deb
tar -xJvf data.tar.xz
mv usr/share/vim-airline/plugin/airline-themes.vim content/vim-airline/plugin/
mv usr/share/vim-airline/autoload/airline/themes/* content/vim-airline/autoload/airline/themes/
rm -rf data.tar.xz usr/ control.tar.xz debian-binary

ar x vim-ctrlp_1.81+git20220803-1_all.deb
tar -xJvf data.tar.xz
mv usr/share/vim-ctrlp content/
rm -rf data.tar.xz usr/ control.tar.xz debian-binary

ar x vim-ale_3.3.0-1_all.deb
tar -xJvf data.tar.xz
mv usr/share/vim-ale content/
rm -rf data.tar.xz usr/ control.tar.xz debian-binary

# find content/ -type f -exec shasum {} \; > checksums
