# A tiny aarch64 "webserver"

Pretty basic implementation of opening and binding a socket, then accepting a connection and sending selected files.
Built using [man pages](https://www.man7.org/linux/man-pages/index.html), [syscall tables](https://arm.syscall.sh) and a few hours of my time. Not optimized at all.

---

## Usage:
```
python images.py
make
sudo ./server
```

---

## Yet to come:
- local https in some way
