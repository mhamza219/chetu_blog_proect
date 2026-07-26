#!/usr/bin/env python3
"""
Python Microservice Framework for Document & Resume Parsing (Compatible with Python 3.13+)
Runs a lightweight REST API server using Python's built-in http.server.
Usage: python3 lib/scripts/python_parser_server.py [port]
Default Port: 8000

Endpoints:
  GET  /status       -> Service health check
  POST /api/parse    -> Accepts JSON payload {"file_path": "/path/to/resume.pdf"} or raw document bytes
"""

import sys
import os
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse

# Import parser functions from resume_parser.py in the same directory
sys.path.append(os.path.dirname(__file__))
from resume_parser import extract_text, parse_candidate_info

class DocumentParserHandler(BaseHTTPRequestHandler):
    def _send_json_response(self, data, status=200):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

    def do_OPTIONS(self):
        self._send_json_response({"status": "ok"})

    def do_GET(self):
        parsed_url = urlparse(self.path)
        if parsed_url.path in ['/status', '/']:
            self._send_json_response({
                "service": "Python Document Parser Microservice",
                "status": "online",
                "python_version": sys.version,
                "framework": "Python HTTP Microservice"
            })
        else:
            self._send_json_response({"error": "Endpoint not found"}, status=404)

    def do_POST(self):
        parsed_url = urlparse(self.path)
        if parsed_url.path in ['/api/parse', '/parse']:
            content_length = int(self.headers.get('Content-Length', 0))
            content_type = self.headers.get('Content-Type', '')

            if content_length == 0:
                self._send_json_response({"success": False, "error": "Empty request body"}, status=400)
                return

            body = self.rfile.read(content_length)

            if 'application/json' in content_type or not content_type:
                try:
                    payload = json.loads(body.decode('utf-8'))
                    file_path = payload.get('file_path')
                    if file_path and os.path.exists(file_path):
                        raw_text = extract_text(file_path)
                        parsed = parse_candidate_info(raw_text)
                        self._send_json_response({"success": True, "data": parsed})
                    else:
                        self._send_json_response({"success": False, "error": f"File path not found: {file_path}"}, status=400)
                except Exception as e:
                    self._send_json_response({"success": False, "error": f"JSON parsing error: {str(e)}"}, status=400)
            elif 'multipart/form-data' in content_type or 'application/x-www-form-urlencoded' in content_type:
                try:
                    # Save raw binary stream to temporary upload file
                    temp_dir = os.path.join(os.path.dirname(__file__), '../../tmp/uploads')
                    os.makedirs(temp_dir, exist_ok=True)
                    saved_path = os.path.join(temp_dir, f"uploaded_{os.getpid()}_doc.tmp")
                    with open(saved_path, 'wb') as f:
                        f.write(body)
                    
                    raw_text = extract_text(saved_path)
                    parsed = parse_candidate_info(raw_text)
                    self._send_json_response({"success": True, "data": parsed})
                except Exception as e:
                    self._send_json_response({"success": False, "error": f"Upload processing error: {str(e)}"}, status=500)
            else:
                self._send_json_response({"success": False, "error": "Unsupported Content-Type"}, status=400)
        else:
            self._send_json_response({"error": "Endpoint not found"}, status=404)

def run(port=8000):
    server_address = ('', port)
    httpd = HTTPServer(server_address, DocumentParserHandler)
    print(f"🚀 Python Parsing Microservice active at http://localhost:{port}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server.")
        httpd.server_close()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    run(port)
