package main

import (
	cr "crypto/rand"
	"crypto/sha256"
	"fmt"
	mr "math/rand"
	"os"
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	BlockSize = 1 * 1024 * 1024
	RunTime   = 2 * 1024
)

func calcSHA256(factor int) {
	buf := make([]byte, BlockSize)
	cr.Read(buf)
	h := sha256.New()
	for i := 0; i < RunTime; i++ {
		h.Write(buf)
	}
	h.Sum(nil)
}

func calcIntMath(factor int) {
	n1 := mr.Int63()
	n2 := mr.Int63()
	var ret int64
	for i := 0; i < RunTime*factor; i++ {
		ret = n1 + n2
	}
	fmt.Println(ret)
}

func calcFloatMath(factor int) {
	n1 := mr.Float64()
	n2 := mr.Float64()
	var ret float64
	for i := 0; i < RunTime*factor; i++ {
		ret = n1 + n2
	}
	fmt.Println(ret)
}

func runBenchmark(runThread []int, benchFunc func(int), unit string, resultFactor float64, runtimeFactor int) {
	for _, tr := range runThread {
		resultChan := make(chan float64, tr)
		fmt.Printf("Running %d threads:\n", tr)
		var wg sync.WaitGroup
		for i := 0; i < tr; i++ {
			wg.Add(1)
			go func() {
				defer wg.Done()
				t1 := time.Now()
				benchFunc(runtimeFactor)
				t2 := time.Now()
				speed := float64(RunTime*runtimeFactor) / t2.Sub(t1).Seconds()
				resultChan <- speed
			}()
		}
		wg.Wait()

		var totalSpeed float64 = 0
		var perSpeed []float64 = []float64{}
		for i := 0; i < tr; i++ {
			spd := <-resultChan
			totalSpeed += spd
			perSpeed = append(perSpeed, spd)
		}
		close(resultChan)

		fmt.Printf(
			"Per thread speed: Min: %.2f , Max: %.2f, Avg: %.2f\n",
			slices.Min(perSpeed)/resultFactor,
			slices.Max(perSpeed)/resultFactor,
			totalSpeed/float64(len(perSpeed))/resultFactor,
		)
		fmt.Printf("Total %d threads speed: %.2f %s/s\n", tr, totalSpeed/resultFactor, unit)
	}
}

func main() {
	var runThread []int = []int{}
	var testSuite []string = []string{}
	if len(os.Args) < 3 {
		runThread = append(runThread, 1)
		fmt.Println("Invoke with xxx sha,int,float 1,2,4")
	} else {
		suiteStr := os.Args[1]
		for _, v := range strings.Split(suiteStr, ",") {
			testSuite = append(testSuite, v)
		}
		threadStr := os.Args[2]
		for _, v := range strings.Split(threadStr, ",") {
			tr, err := strconv.Atoi(v)
			if err != nil {
				panic("failed to decode")
			}
			runThread = append(runThread, tr)
		}
	}
	for _, v := range testSuite {
		switch v {
		case "sha":
			fmt.Printf("Running %s\n", v)
			runBenchmark(runThread, calcSHA256, "MB", 1, 1)
		case "int":
			fmt.Printf("Running %s\n", v)
			runBenchmark(runThread, calcIntMath, "MOps", 1000000, 3000000)
		case "float":
			fmt.Printf("Running %s\n", v)
			runBenchmark(runThread, calcFloatMath, "MOps", 1000000, 3000000)
		}
	}
}
