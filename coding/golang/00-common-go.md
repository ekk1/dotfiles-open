# Some common tasks in go

## Make HTTP Requests

```go
var req *http.Request
// sendJSON, err := json.Marshal(q.SendStruct)
req, err = http.NewRequest("GET", "url", bytes.NewBuffer(sendJSON))
req, err = http.NewRequest("GET", "url", nil)

req.Header.Set("Content-Type", "application/json; charset=UTF-8") 
req.SetBasicAuth("user", "pass")

dialer := &net.Dialer{
    Timeout:   30 * time.Second,
    KeepAlive: 30 * time.Second,
}

ts := &http.Transport{
    DialContext:           dialer.DialContext,
    ForceAttemptHTTP2:     true,
    MaxIdleConns:          100,
    IdleConnTimeout:       90 * time.Second,
    TLSHandshakeTimeout:   10 * time.Second,
    ExpectContinueTimeout: 1 * time.Second,
}

// proxyURL, err := url.Parse("socks5h://127.0.0.1")
// In golang's std http, socks5 acts like socks5h
// ts.Proxy = http.ProxyURL(proxyURL)

certPool := x509.NewCertPool()
pem, err := os.ReadFile(certfile)
ok := certPool.AppendCertsFromPEM(pem)
ts.TLSClientConfig = &tls.Config{RootCAs: certPool}

c := &http.Client{}
c.Transport = ts

ret, err := c.Do(req)
if err != nil {
    return err
}
defer ret.Body.Close()

data, err := io.ReadAll(ret.Body)

// json.Unmarshal(data, q.RecvStruct)
```



## Simple HTTP server

* check sensible_server.go

## Run cmd

```go
func RunCmd(command string) (string, error) {
    cmd := exec.Command("bash", "-c", command)
    ret, err := cmd.CombinedOutput()
    if err != nil {
        return "", err
    }
    return string(ret), nil
}
```


## Proper log

```go
var programLevel = new(slog.LevelInfo)
logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: programLevel}))
logger.Info("starting request", "url", &r.URL) // calls URL.String only if needed

```



