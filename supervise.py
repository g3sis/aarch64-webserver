#!/usr/bin/env python3
"""Run ./server and restart it when it stops answering HTTP.

The server is a single-threaded accept loop, so one stuck request wedges it:
the socket still accepts, nothing ever replies. That is what we detect.
"""
import socket
import subprocess
import sys
import time
from pathlib import Path

HOST, PORT = "127.0.0.1", 80
CHECK = 10     # seconds between checks
TIMEOUT = 5    # seconds to wait for a reply
FAILS = 2      # consecutive failed checks before restart


def alive(timeout=TIMEOUT, host=HOST, port=PORT):
    """True if the server answers a bare GET within `timeout`."""
    try:
        with socket.create_connection((host, port), timeout=timeout) as s:
            s.settimeout(timeout)
            s.sendall(b"GET / HTTP/1.0\r\n\r\n")
            return b"HTTP/" in s.recv(512)
    except OSError:
        return False


def start():
    return subprocess.Popen(["./server"], cwd=Path(__file__).resolve().parent)


def main():
    proc = start()
    fails = 0
    print(f"started ./server pid={proc.pid}", flush=True)
    while True:
        time.sleep(CHECK)
        if proc.poll() is None and alive():
            fails = 0
            continue
        fails += 1
        print(f"unresponsive ({fails}/{FAILS})", flush=True)
        if fails >= FAILS or proc.poll() is not None:
            proc.kill()
            proc.wait()
            proc = start()
            fails = 0
            print(f"restarted pid={proc.pid}", flush=True)


def _selftest():
    import http.server
    import threading

    class Quiet(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.end_headers()

        def log_message(self, format, *args):
            pass

    srv = http.server.HTTPServer(("127.0.0.1", 0), Quiet)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    assert alive(timeout=2, port=srv.server_port), "live server seen as dead"
    srv.shutdown()

    silent = socket.socket()
    silent.bind(("127.0.0.1", 0))
    silent.listen()
    assert not alive(timeout=1, port=silent.getsockname()[1]), "silent listen seen as alive"
    silent.close()

    assert not alive(timeout=1, port=1), "closed port seen as alive"
    print("selftest ok")


if __name__ == "__main__":
    _selftest() if "--selftest" in sys.argv else main()
