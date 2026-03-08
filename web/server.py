#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = 30088
DIRECTORY = "/root/.copaw/xplan/web/dist"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def do_GET(self):
        # 处理 SPA 路由
        if not self.path.startswith('/assets/') and '.' not in self.path:
            self.path = '/index.html'
        return super().do_GET()

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    print(f" Serving at http://0.0.0.0:{PORT} ")
    print(f" Directory: {DIRECTORY} ")
    httpd.serve_forever()
