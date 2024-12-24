#!/bin/bash

DEVICE=${DEVICE:-"cuda"}
TAG=${TAG:-"latest"}

if [ "$DEVICE" = "cuda" ]; then
    docker build -t mlc-llm-compiler:${TAG}-cuda -f Dockerfile.cuda .
elif [ "$DEVICE" = "rocm" ]; then
    docker build -t mlc-llm-compiler:${TAG}-rocm -f Dockerfile.rocm .
else
    echo "Error: Unsupported device type: $DEVICE"
    exit 1
fi