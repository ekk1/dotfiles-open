# Some useful tools

```bash
## Adding watermarks to image
apt install imagemagick
apt install fonts-noto-cjk
## Fonts are usually under /usr/share/fonts
convert -size 260x200 xc:none -font /usr/share/fonts/opentypes/noto/font.ttc -pointsize 22 -fill "rgba(255,255,255,0.5)" -gravity center -draw "translate 0,0 rotate 45 text 0,0 'watermark text'" miff:- | composite -tile - input.jpg output.jpg


# tig
# :toggle wrap-lines


## pdf to image
# get pdf page count
identify -format "%n\n" xxx.pdf | head -1
# cause this outputs number for every page ...
convert -density 200 1.pdf[0] output.jpg
convert -density 200 1.pdf[1-2] output.jpg
convert -density 200 1.pdf[1-2] output_%d.jpg
convert -density 300 -trim test.pdf -quality 100 test.jpg
convert -density 300 -trim test.pdf[0] -quality 100 test.jpg

# AI
./llama.cpp/build/bin/llama-minicpmv-cli -m ../../Model-7.6B-Q8_0.gguf --mmproj ../../mmproj-model-f16.gguf -c 4096 --temp 0.7 --top-p 0.8 --top-k 100 --repeat-penalty 1.05 --image ../../output.jpg  -p "请识别图中的文字，按 markdown 的格式写出来，不要遗漏任何信息"

./llama.cpp/build/bin/llama-cli \
    --model DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf \
    --cache-type-k q8_0 \
    --threads 4 \
    --temp 0.6 \
    --prompt "<｜User｜>$1<｜Assistant｜>" \
    -no-cnv
```
