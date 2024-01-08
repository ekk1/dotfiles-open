# Common ffmpeg things

```bash
# Convert video to gif
# loop 1 means loop once (play twice)
ffmpeg -i test.mp4 -vf "transpose=2,fps=15,scale=720:-1" -loop 1 test.gif

# cut videos
ffmpeg -ss 0 -i xxx -t 60 -c copy output.mp4
```
