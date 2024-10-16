# Some useful tools

```bash
## Adding watermarks to image
apt install imagemagick
apt install fonts-noto-cjk
## Fonts are usually under /usr/share/fonts
convert -size 260x200 xc:none -font /usr/share/fonts/opentypes/noto/font.ttc -pointsize 22 -fill "rgba(255,255,255,0.5)" -gravity center -draw "translate 0,0 rotate 45 text 0,0 'watermark text'" miff:- | composite -tile - input.jpg output.jpg


# tig
# :toggle wrap-lines
```
