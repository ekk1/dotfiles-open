# Some ways to implement a python web server

## 01. Run a web server in embeddable version python under WINDOWS

```python
# This should works in Linux and Windows
# Put bottle.py and waitress in python-3.11.5-embed-amd64\Libs
import sys
sys.path.append("python-3.11.5-embed-amd64\Libs")

import bottle
app = bottle.Bottle()

@app.route('/')
def hello():
    return "Hello World!"

from waitress import serve
serve(app, host='127.0.0.1', port=8080)
# Tip:
# Using bottle.run in this environmen will cause a warning like this
# <frozen importlib._bootstrap>:1047: ImportWarning: _ImportRedirect.find_spec() not found; falling back to find_module()
# although somethings bottle seems to work fine, but seems very hard to terminate the web server, this might be a problem
# using waitress will solve this problem
# it's also pure python with no additional dependencies, makes it perfect for embed python in windows
# Windows cmd programs will freeze when text is selected, de-select to restore, whis is expected
```

## 02. Use flask to create a minial web app

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

if __name__ == "__main__":
    app.run("127.0.0.1", 9099)

# 一般建议用 gunicorn 来运行，最简单的就是
# gunicorn -w 1 'index:app'
# 如果需要支持 keepalive 的话，则需要用 eventlet 的 worker, 具体可以参考 nbd 下面的 index 的实现
```
## 03. Use aiohttp to create a web web

* This did present a better performance
