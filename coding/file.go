package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	// 获取当前工作目录
	dir, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	// 使用 Fileserver 提供文件服务
	fileServer := http.FileServer(http.Dir(dir))

	// 处理所有的 HTTP 请求
	http.Handle("/", fileServer)

	// 定义监听端口
	port := 8080
	fmt.Printf("Serving files from %s on HTTP port: %d\n", dir, port)

	// 启动服务
	err = http.ListenAndServe(fmt.Sprintf(":%d", port), nil)
	if err != nil {
		log.Fatal(err)
	}
}
