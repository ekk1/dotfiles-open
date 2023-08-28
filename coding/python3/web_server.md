# Some ways to implement a python web server

## 01. Run a web server in embeddable version python under WINDOWS

```python
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
# using waitress will solve this problem, and it's pure python with no additional dependencies, makes it perfect for embed python in windows 
```

## 02. Use flask to create a minial web app

## 03. Use aiohttp to create a web web

* This did present a better performance
