# Some tools for better golang web programming

```bash
# runs at 127.0.0.1:5000/post
# suited for checking post params and etc
python3 -m httpbin.core

# runs at 127.0.0.1:8889/test.html
# suited for serving changing html content
livereload -p 8889

# monitors changes to source files, and run build or test command
fswatch -m poll_monitor --event Updated -0 *.go | while read -d "" event ;do go test . ; done

```

