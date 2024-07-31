#!/bin/bash
./bin/scanner &

start() {
    xvfb-run ./run.sh
    if [ $? -eq 0 ]; then
        start
    fi
}

start

