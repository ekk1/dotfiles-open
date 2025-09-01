import argparse
import logging
import os
import select
import shutil
import socket
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse
from urllib import request as urllib_request
from urllib import error as urllib_error

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
log = logging.getLogger(__name__)

class Whitelist:
    """处理域名白名单的类"""
    def __init__(self, list_str: str):
        self.exact_matches = set()
        self.suffix_matches = []

        domains = [d.strip().lower() for d in list_str.split(',') if d.strip()]
        for domain in domains:
            if domain.startswith('*.'):
                self.suffix_matches.append(domain[2:])
            else:
                self.exact_matches.add(domain)

    def is_allowed(self, domain: str) -> bool:
        """检查域名是否在白名单内"""
        domain = domain.strip().lower()

        # 1. 检查精确匹配
        if domain in self.exact_matches:
            return True

        # 2. 检查后缀匹配
        for suffix in self.suffix_matches:
            if domain == suffix or domain.endswith(f".{suffix}"):
                return True

        return False

class CounterSocketWrapper:
    """一个包装 socket 的类，用于统计读写的字节数"""
    def __init__(self, sock: socket.socket):
        self._socket = sock
        self.read_bytes = 0
        self.written_bytes = 0

    def recv(self, bufsize: int) -> bytes:
        data = self._socket.recv(bufsize)
        self.read_bytes += len(data)
        return data

    def sendall(self, data: bytes):
        self._socket.sendall(data)
        self.written_bytes += len(data)

    # 将其他 socket 方法委托给内部的 socket 对象
    def __getattr__(self, name):
        return getattr(self._socket, name)

def format_bytes(b: int) -> str:
    """将字节数格式化为可读的字符串 (KB, MB, etc.)"""
    if b < 1024:
        return f"{b} B"
    unit = 1024
    exp = 0
    div = unit
    n = b / unit
    while n >= unit:
        div *= unit
        exp += 1
        n /= unit
    return f"{b/div:.2f} {'KMGTPE'[exp]}iB"

class ProxyRequestHandler(BaseHTTPRequestHandler):
    """代理请求处理器"""
    # 这些类属性将在 main 函数中被设置
    whitelist: Whitelist = None
    upstream_url: 'urllib.parse.ParseResult' = None

    # 覆盖默认的 server header
    server_version = "PythonProxy/0.1"
    sys_version = ""

    def log_message(self, format: str, *args):
        # 禁用默认的 BaseHTTPRequestHandler 日志，我们使用自己的 logging 模块
        pass

    def do_CONNECT(self):
        """处理 HTTPS 的 CONNECT 请求"""
        trace_id = os.urandom(16).hex()
        start_time = time.monotonic()

        try:
            host, port_str = self.path.split(':', 1)
            port = int(port_str)
        except ValueError:
            self.send_error(400, "Bad CONNECT request")
            return

        log.info(f"[{trace_id}] New TCP connection for {self.path} from {self.client_address}")

        if not self.whitelist.is_allowed(host):
            log.warning(f"[{trace_id}] Domain {host} is not in the whitelist")
            self.send_error(403, "Domain not allowed")
            return

        # 1. 连接到上游代理
        try:
            upstream_socket = socket.create_connection(
                (self.upstream_url.hostname, self.upstream_url.port or 80)
            )
        except Exception as e:
            log.error(f"[{trace_id}] Failed to connect to upstream proxy: {e}")
            self.send_error(502, "Upstream connection failed")
            return

        try:
            # 2. 向上游代理发送 CONNECT 请求以建立隧道
            connect_req = f"CONNECT {self.path} HTTP/1.1\r\nHost: {self.path}\r\n\r\n"
            upstream_socket.sendall(connect_req.encode('utf-8'))

            # 3. 读取上游代理的响应
            upstream_file = upstream_socket.makefile('rb', 0)
            status_line = upstream_file.readline().decode('utf-8').strip()
            version, code, message = status_line.split(' ', 2)
            if int(code) != 200:
                log.error(f"[{trace_id}] Upstream proxy failed: {status_line}")
                self.send_error(int(code), message)
                return

            # 读取并忽略剩余的 header
            while True:
                if upstream_file.readline() in (b'\r\n', b'\n', b''):
                    break

            # 4. 向上游隧道建立成功，向客户端发送成功响应
            self.send_response(200, 'Connection established')
            self.end_headers()
        except Exception as e:
            log.error(f"[{trace_id}] Failed to establish tunnel with upstream: {e}")
            self.send_error(502, "Tunnel establishment failed")
            return
        finally:
            if 'upstream_file' in locals():
                # makefile() 会缓冲数据, 关闭它确保所有数据都被处理
                upstream_file.close()

        # 5. 在客户端和上游代理之间双向转发数据
        client_conn = self.connection
        client_counter = CounterSocketWrapper(client_conn)
        upstream_counter = CounterSocketWrapper(upstream_socket)

        try:
            sockets = [client_counter, upstream_counter]
            while sockets:
                readable, _, exceptional = select.select(sockets, [], sockets, 60)
                if exceptional:
                    break

                for sock in readable:
                    other_sock = upstream_counter if sock is client_counter else client_counter
                    data = sock.recv(8192)
                    if not data:
                        # 连接已关闭，停止转发
                        sockets.clear()
                        break
                    other_sock.sendall(data)
        except Exception as e:
            log.debug(f"[{trace_id}] Data transfer error: {e}")
        finally:
            # 6. 清理连接并记录统计信息
            duration = time.monotonic() - start_time
            uploaded = client_counter.read_bytes
            downloaded = client_counter.written_bytes
            log.info(
                f"[{trace_id}] Connection closed. Duration: {duration:.3f}s, "
                f"Upload: {format_bytes(uploaded)}, Download: {format_bytes(downloaded)}"
            )
            client_conn.close()
            upstream_socket.close()

    def handle_standard_request(self):
        """处理标准的 HTTP 请求 (GET, POST, etc.)"""
        # 1. 解析 URL 并检查白名单
        parsed_path = urlparse(self.path)
        host = parsed_path.hostname or self.headers.get('Host', '').split(':', 1)[0]

        if not self.whitelist.is_allowed(host):
            log.warning(f"Domain {host} is not in the whitelist")
            self.send_error(403, "Domain not allowed")
            return

        log.info(f"Handling standard HTTP request for {host} from {self.client_address}")

        # 2. 配置 urllib 使用上游代理
        proxy_handler = urllib_request.ProxyHandler({
            'http': self.upstream_url.geturl(),
            'https': self.upstream_url.geturl(),
        })

        # 禁用重定向，以匹配 Go 程序的行为
        class NoRedirectHandler(urllib_request.HTTPRedirectHandler):
            def redirect_request(self, req, fp, code, msg, headers, newurl):
                return None
            http_error_301 = http_error_302 = http_error_303 = http_error_307 = redirect_request

        opener = urllib_request.build_opener(proxy_handler, NoRedirectHandler)

        # 3. 构建发往上游的请求
        body = None
        if 'Content-Length' in self.headers:
            content_len = int(self.headers['Content-Length'])
            body = self.rfile.read(content_len)

        # 客户端发来的通常是相对路径，需要构造成完整 URL
        url_to_fetch = self.path
        if not url_to_fetch.startswith(('http://', 'https://')):
            url_to_fetch = f"http://{host}{self.path}"

        out_req = urllib_request.Request(
            url_to_fetch,
            data=body,
            headers=dict(self.headers),
            method=self.command
        )

        try:
            # 4. 发送请求并获取响应
            with opener.open(out_req) as resp:
                # 5. 将响应发回给客户端
                self.send_response(resp.code, resp.reason)
                for key, value in resp.getheaders():
                    # 过滤掉逐跳(hop-by-hop)的头信息
                    if key.lower() not in ('transfer-encoding', 'connection', 'content-encoding'):
                        self.send_header(key, value)
                self.end_headers()
                shutil.copyfileobj(resp, self.wfile)

        except urllib_error.HTTPError as e:
            # 处理来自目标服务器的错误响应 (如 404, 500)
            self.send_response(e.code, e.reason)
            for key, value in e.headers.items():
                 if key.lower() not in ('transfer-encoding', 'connection', 'content-encoding'):
                    self.send_header(key, value)
            self.end_headers()
            self.wfile.write(e.read())
        except Exception as e:
            log.error(f"Failed to execute standard request: {e}")
            self.send_error(502, "Proxy request failed")

    # 将所有常见的 HTTP 方法都指向同一个处理器
    def do_GET(self): self.handle_standard_request()
    def do_POST(self): self.handle_standard_request()
    def do_HEAD(self): self.handle_standard_request()
    def do_PUT(self): self.handle_standard_request()
    def do_DELETE(self): self.handle_standard_request()
    def do_OPTIONS(self): self.handle_standard_request()
    def do_PATCH(self): self.handle_standard_request()

def main():
    """主函数，用于解析参数和启动服务器"""
    parser = argparse.ArgumentParser(description="A simple Python HTTP/HTTPS proxy server.")
    parser.add_argument('-l', dest='listen_addr', default='127.0.0.1:9902', help='Address to listen on (default: 127.0.0.1:9902)')
    parser.add_argument('-p', dest='upstream_proxy', default='http://127.0.0.1:8119', help='Upstream proxy URL (default: http://127.0.0.1:8119)')
    parser.add_argument('-w', dest='whitelist', default='', help='Comma-separated list of whitelisted domains (e.g., "example.com,*.google.com")')
    args = parser.parse_args()

    # 将解析后的参数设置到请求处理器类上
    ProxyRequestHandler.whitelist = Whitelist(args.whitelist)
    ProxyRequestHandler.upstream_url = urlparse(args.upstream_proxy)

    if not ProxyRequestHandler.upstream_url.scheme or not ProxyRequestHandler.upstream_url.hostname:
        log.fatal(f"Invalid upstream proxy URL: {args.upstream_proxy}")
        return

    listen_host, listen_port_str = args.listen_addr.split(':')
    server_address = (listen_host, int(listen_port_str))

    httpd = ThreadingHTTPServer(server_address, ProxyRequestHandler)

    log.info(f"HTTP proxy server listening on {args.listen_addr}")
    log.info(f"Upstream proxy configured at {args.upstream_proxy}")
    if args.whitelist:
        log.info(f"Whitelist is active for domains: {args.whitelist}")
    else:
        log.warning("Whitelist is empty. All domains will be rejected unless you add domains with -w.")


    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        log.info("Shutting down server...")
    finally:
        httpd.server_close()

if __name__ == '__main__':
    main()
