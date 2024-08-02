#!/bin/bash
./bin/scanner &
Xvfb :1 &
sleep 1
export DISPLAY=:1
export LIBGL_ALWAYS_INDIRECT=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia

start() {
    ./run.sh
    if [ $? -eq 0 ]; then
        start
    fi
}

start

