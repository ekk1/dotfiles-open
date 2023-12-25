# Some useful tools

```bash
## Adding watermarks to image
apt install imagemagick
## Fonts are usually under /usr/share/fonts
convert -size 140x80 xc:none -font /path/to/font.ttc -pointsize 20 -fill "rgba(255,255,255,0.3)" -gravity center -draw "translate 0,0 rotate 45 text 0,0 'watermark text'" miff:- | composite -tile - input.jpg output.jpg
```
