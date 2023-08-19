package main

import (
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"time"
)

const (
	BlockSize = 1 * 1024 * 1024
	RunTime   = 10 * 1024
)

func main() {
	buf := make([]byte, BlockSize)
	rand.Read(buf)
	h := sha256.New()
	t1 := time.Now()
	for i := 0; i < RunTime; i++ {
		h.Write(buf)
	}
	t2 := time.Now()
	speed := float64(RunTime) / t2.Sub(t1).Seconds()
	fmt.Printf("SHA256 on 1MB block: %.2f MB/s\n", speed)
}
