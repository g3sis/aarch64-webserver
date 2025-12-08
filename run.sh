#!/bin/bash

# Build and run the aarch64 webserver
python ./images.py
make
./server