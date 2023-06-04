* Install
pacman -S xxx

* Search keyword
pacman -Ss xxx

* Query explicit install
pacman -Qe

* Query all install
pacman -Qn

* Query package file
pacman -Ql xxx

* Whole system upgrade
pacman -Syu

* Refresh metadata
pacman -Sy

* show package info
pacman -Q --info vim

* Remove package and dep
pacman -Rs xxx
* apt purge like
pacman -Rn xxx
* together
pacman -Rns xxx
* apt autoremove like
pacman -Qdtq | pacman -Rs -

* search package by file, y is for update meta
pacman -F[y] xxx
