```go
func formValue(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, r.FormValue("name"))
}

func upload(w http.ResponseWriter, r * http.Request) {
    file, fHeader, err := req.FormFile("uploadfile")
    if err != nil {
        return
    }
    defer file.Close()
    fmt.Fprintf(w, "%v", fHeader.Header)
    f, err := os.OpenFile("./xxxx", os.O_WRONLY|os.O_CREATE, 0666)
    if err != nil {
        return
    }
    defer f.Close()
    io.Copy(f, file)
}
```

```bash
curl -F "uploadfile=@xxx.png" http://127.0.0.1:8000/upload

```

