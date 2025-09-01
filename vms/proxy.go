package main

import (
	"bufio"
	"crypto/rand"
	"encoding/hex"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/url"
	"strings"
	"sync/atomic"
	"time"
)

var (
	listenAddr    = flag.String("l", "127.0.0.1:9902", "Address to listen on")
	upstreamProxy = flag.String("p", "http://127.0.0.1:8119", "Upstream proxy URL")
	whitelist     = flag.String("w", "", "Comma-separated list of domains to whitelist")
)

// Whitelist for domain checking
type Whitelist struct {
	exactMatches  map[string]struct{}
	suffixMatches []string
}

// CounterConn wraps a net.Conn to count bytes read and written.
type CounterConn struct {
	net.Conn
	readBytes    atomic.Int64
	writtenBytes atomic.Int64
}

// NewCounterConn creates a new CounterConn.
func NewCounterConn(conn net.Conn) *CounterConn {
	return &CounterConn{Conn: conn}
}

// Read wraps the underlying Read method to count bytes.
func (c *CounterConn) Read(b []byte) (int, error) {
	n, err := c.Conn.Read(b)
	if n > 0 {
		c.readBytes.Add(int64(n))
	}
	return n, err
}

// Write wraps the underlying Write method to count bytes.
func (c *CounterConn) Write(b []byte) (int, error) {
	n, err := c.Conn.Write(b)
	if n > 0 {
		c.writtenBytes.Add(int64(n))
	}
	return n, err
}

// GetReadBytes returns the total bytes read.
func (c *CounterConn) GetReadBytes() int64 {
	return c.readBytes.Load()
}

// GetWrittenBytes returns the total bytes written.
func (c *CounterConn) GetWrittenBytes() int64 {
	return c.writtenBytes.Load()
}

func parseWhitelist(list string) *Whitelist {
	wl := &Whitelist{
		exactMatches:  make(map[string]struct{}),
		suffixMatches: []string{},
	}

	domains := strings.Split(list, ",")
	for _, domain := range domains {
		domain = strings.TrimSpace(strings.ToLower(domain))
		if domain == "" {
			continue
		}

		if strings.HasPrefix(domain, "*.") {
			suffix := domain[2:] // Remove "*." prefix
			wl.suffixMatches = append(wl.suffixMatches, suffix)
		} else {
			wl.exactMatches[domain] = struct{}{}
		}
	}

	return wl
}

func (wl *Whitelist) isAllowed(domain string) bool {
	domain = strings.TrimSpace(strings.ToLower(domain))

	// Check exact match
	if _, ok := wl.exactMatches[domain]; ok {
		return true
	}

	// Check suffix match
	for _, suffix := range wl.suffixMatches {
		if domain == suffix || strings.HasSuffix(domain, "."+suffix) {
			return true
		}
	}

	return false
}

func main() {
	flag.Parse()

	// Parse the whitelist
	wl := parseWhitelist(*whitelist)

	// Parse the upstream proxy URL
	upstreamURL, err := url.Parse(*upstreamProxy)
	if err != nil {
		log.Fatalf("Failed to parse upstream proxy URL: %v", err)
	}

	// Create the proxy server
	server := &ProxyServer{
		whitelist:   wl,
		upstreamURL: upstreamURL,
	}

	// Start listening
	log.Printf("HTTP proxy server listening on %s", *listenAddr)
	log.Fatal(http.ListenAndServe(*listenAddr, server))
}

// ProxyServer handles both CONNECT tunneling and standard HTTP proxying
type ProxyServer struct {
	whitelist   *Whitelist
	upstreamURL *url.URL
}

func (p *ProxyServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// Extract the domain from the request
	var domain string
	if r.Method == http.MethodConnect {
		host, _, err := net.SplitHostPort(r.Host)
		if err != nil {
			domain = r.Host
		} else {
			domain = host
		}
	} else {
		if r.URL.Host != "" {
			host, _, err := net.SplitHostPort(r.URL.Host)
			if err != nil {
				domain = r.URL.Host
			} else {
				domain = host
			}
		} else {
			host, _, err := net.SplitHostPort(r.Host)
			if err != nil {
				domain = r.Host
			} else {
				domain = host
			}
		}
	}

	// Check if the domain is in the whitelist
	if !p.whitelist.isAllowed(domain) {
		log.Printf("Domain %s is not in the whitelist", domain)
		http.Error(w, "Domain not allowed", http.StatusForbidden)
		return
	}

	// Handle the request based on the method
	if r.Method == http.MethodConnect {
		p.handleConnect(w, r)
	} else {
		p.handleStandardRequest(w, r)
	}
}

func (p *ProxyServer) handleConnect(w http.ResponseWriter, r *http.Request) {
	// Generate a unique trace ID using the standard library's crypto/rand.
	var traceID string
	randomBytes := make([]byte, 16) // 128 bits of randomness
	if _, err := rand.Read(randomBytes); err != nil {
		// Fallback to a timestamp-based ID if crypto/rand fails.
		log.Printf("WARNING: Could not generate random bytes for traceID: %v. Falling back to timestamp.", err)
		traceID = fmt.Sprintf("fallback-%d", time.Now().UnixNano())
	} else {
		traceID = hex.EncodeToString(randomBytes)
	}

	startTime := time.Now()
	log.Printf("[%s] New TCP connection for %s from %s", traceID, r.Host, r.RemoteAddr)

	// Connect to the upstream proxy
	upstreamConn, err := net.Dial("tcp", p.upstreamURL.Host)
	if err != nil {
		log.Printf("[%s] Failed to connect to upstream proxy: %v", traceID, err)
		http.Error(w, "Failed to connect to upstream proxy", http.StatusBadGateway)
		return
	}

	// Send a CONNECT request to the upstream proxy
	upstreamReq := &http.Request{
		Method: http.MethodConnect,
		URL:    &url.URL{Host: r.Host},
		Host:   r.Host,
		Header: make(http.Header),
	}

	if err := upstreamReq.Write(upstreamConn); err != nil {
		log.Printf("[%s] Failed to write CONNECT request to upstream proxy: %v", traceID, err)
		http.Error(w, "Failed to establish tunnel", http.StatusBadGateway)
		upstreamConn.Close()
		return
	}

	// Read the response from the upstream proxy
	upstreamReader := bufio.NewReader(upstreamConn)
	upstreamResp, err := http.ReadResponse(upstreamReader, upstreamReq)
	if err != nil {
		log.Printf("[%s] Failed to read response from upstream proxy: %v", traceID, err)
		http.Error(w, "Failed to establish tunnel", http.StatusBadGateway)
		upstreamConn.Close()
		return
	}
	defer upstreamResp.Body.Close()

	// Check if the tunnel was established successfully
	if upstreamResp.StatusCode != http.StatusOK {
		log.Printf("[%s] Upstream proxy failed to establish tunnel: %s", traceID, upstreamResp.Status)
		http.Error(w, "Failed to establish tunnel", upstreamResp.StatusCode)
		upstreamConn.Close()
		return
	}

	// Hijack the client connection
	hj, ok := w.(http.Hijacker)
	if !ok {
		log.Printf("[%s] Client connection does not support hijacking", traceID)
		http.Error(w, "Tunnel cannot be established", http.StatusInternalServerError)
		upstreamConn.Close()
		return
	}
	clientConn, _, err := hj.Hijack()
	if err != nil {
		log.Printf("[%s] Failed to hijack client connection: %v", traceID, err)
		http.Error(w, "Tunnel cannot be established", http.StatusInternalServerError)
		upstreamConn.Close()
		return
	}

	// Send 200 OK response to the client to indicate tunnel established
	if _, err := clientConn.Write([]byte("HTTP/1.1 200 Connection established\r\n\r\n")); err != nil {
		log.Printf("[%s] Failed to send 200 OK to client: %v", traceID, err)
		clientConn.Close()
		upstreamConn.Close()
		return
	}

	// Wrap connections to count traffic
	countingClientConn := NewCounterConn(clientConn)
	countingUpstreamConn := NewCounterConn(upstreamConn)

	// Set up bidirectional data transfer
	done := make(chan struct{})

	go func() {
		io.Copy(countingUpstreamConn, countingClientConn)
		done <- struct{}{}
	}()

	go func() {
		io.Copy(countingClientConn, countingUpstreamConn)
		done <- struct{}{}
	}()

	// Wait for either direction to finish
	<-done

	// Close connections
	clientConn.Close()
	upstreamConn.Close()

	// Log the end of the connection and traffic stats
	duration := time.Since(startTime)
	uploadedBytes := countingClientConn.GetReadBytes()
	downloadedBytes := countingClientConn.GetWrittenBytes()

	log.Printf(
		"[%s] Connection closed. Duration: %s, Upload: %s, Download: %s",
		traceID,
		duration.Round(time.Millisecond),
		formatBytes(uploadedBytes),
		formatBytes(downloadedBytes),
	)
}

// formatBytes is a helper to format byte counts into KB, MB, etc.
func formatBytes(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.2f %ciB", float64(b)/float64(div), "KMGTPE"[exp])
}

func (p *ProxyServer) handleStandardRequest(w http.ResponseWriter, r *http.Request) {
	log.Printf("Handling standard HTTP request for %s from %s", r.Host, r.RemoteAddr)
	transport := &http.Transport{
		Proxy: http.ProxyURL(p.upstreamURL),
	}
	client := &http.Client{
		Transport: transport,
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}

	outReq := new(http.Request)
	*outReq = *r
	outReq.RequestURI = ""

	if !r.URL.IsAbs() {
		outReq.URL = &url.URL{
			Scheme:   "http",
			Host:     r.Host,
			Path:     r.URL.Path,
			RawQuery: r.URL.RawQuery,
		}
		if r.TLS != nil {
			outReq.URL.Scheme = "https"
		}
	}

	resp, err := client.Do(outReq)
	if err != nil {
		log.Printf("Failed to execute request: %v", err)
		http.Error(w, "Failed to reach destination", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()

	for key, values := range resp.Header {
		for _, value := range values {
			w.Header().Add(key, value)
		}
	}
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}
