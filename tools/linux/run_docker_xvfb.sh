#!/bin/bash
./bin/scanner &
Xvfb :1 &
sleep 1
export DISPLAY=:1

start() {
    ./run.sh
    if [ $? -eq 0 ]; then
        start
    fi
}

start

