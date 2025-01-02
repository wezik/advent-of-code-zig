#!/bin/bash

# export SESSION_COOKIE="aoc-session-cookie"

aoc() {
        if [[ "$1" == "r" || "$1" == "release" ]]; then
                shift
                zig build -Doptimize=ReleaseFast && ./zig-out/bin/advent-of-code-zig $1 $SESSION_COOKIE
        else
                zig build && ./zig-out/bin/advent-of-code-zig $1 $SESSION_COOKIE
        fi
}

