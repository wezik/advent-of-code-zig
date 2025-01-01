#!/bin/bash

# export SESSION_COOKIE="aoc-session-cookie"

aoc() {
        zig build && ./zig-out/bin/advent-of-code-zig $1 $SESSION_COOKIE
}
