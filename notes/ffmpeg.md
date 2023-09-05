# Common ffmpeg things

```bash
# Convert video to gif
# loop 1 means loop once (play twice)
ffmpeg -i test.mp4 -vf "transpose=2,fps=15,scale=720:-1" -loop 1 test.gif
```

