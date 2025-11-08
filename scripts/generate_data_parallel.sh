#!/usr/bin/env bash

# --- 1. Configuration ---
SCALE=10
PARALLELISM=4

# Use the full path for the output directory too
DATA_DIR="/tmp/scale_${SCALE}"

mkdir -p "$DATA_DIR"

for i in $(seq 1 $PARALLELISM); do
    echo "Starting child process $i of $PARALLELISM..."

    dsdgen \
        -SCALE $SCALE \
        -DIR "$DATA_DIR" \
        -parallel $PARALLELISM \
        -child $i \
        -TERMINATE N &
done

wait
echo "All processes finished."
