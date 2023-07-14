package main

import _ "embed"

//go:embed static/index.html
var indexHTML string

//go:embed static/js/base.js
var baseJSFile string

//go:embed static/js/user_index.js
var userIndexJSFile string

var assetFileList map[string]string

func prepareAssetDict() {
        assetFileList = make(map[string]string)

        assetFileList["static/js/base.js"] = baseJSFile
        assetFileList["static/js/user_index.js"] = userIndexJSFile
        assetFileList["static/js/admin_index.js"] = adminIndexJSFile
}

func quickServerLog(req *http.Request, caller string) {
    utils.LogPrintInfo(fmt.Sprintf("%s got %s connection from: %s for %s on %s", caller, req.Method, req.RemoteAddr, req.URL.Path, req.Host))
}

func handleStatic(w http.ResponseWriter, req *http.Request) {
    quickServerLog(req, "handleStatic")

    dataBytes, ok := assetFileList[req.URL.Path[1:]]
    if !ok {
        w.WriteHeader(http.StatusNotFound)
        w.Write([]byte(""))
        return
    }   
    w.Write([]byte(dataBytes))
}

func denyUnDefinedResouce(w http.ResponseWriter, req *http.Request) error {
    if req.URL.Path != "/" {
        w.WriteHeader(http.StatusNotFound)
        w.Write([]byte(""))
        return errors.New(fmt.Sprintf("Resource not defined for %s on %s", req.URL.Path, req.Host))
    }
    return nil
}

func handleRoot(w http.ResponseWriter, req *http.Request) {
    quickServerLog(req, "handleRoot")

    if err := denyUnDefinedResouce(w, req); err != nil {
        utils.LogPrintError(err)
        return
    }   
}

func main() {
        prepareAssetDict()
        muxUser := http.NewServeMux()
        muxUser.HandleFunc("/", handleRoot)
        muxUser.HandleFunc("/static/", handleStatic)
        addrUser := "127.0.0.1:8080"
        serverUser := http.Server{
                Addr:    addrUser,
                Handler: muxUser,
        }
        var wg sync.WaitGroup
        wg.Add(1)
        go func() {
                utils.LogPrintInfo("User page listening on " + addrUser)
                utils.LogPrintError(serverUser.ListenAndServe())
                wg.Done()
        }()
        wg.Wait()
}

