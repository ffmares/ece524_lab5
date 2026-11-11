#!/usr/bin/env bash
# Portable simulation of both custom cores; requires Icarus Verilog.
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT
cd "$build"
src="$root/ece524_lab5.srcs/sources_1/new"
for arch in 0 1; do
    for test_case in 0 1 2 3; do
        iverilog -g2005 -s tb_fir -I "$src" \
            -Ptb_fir.ARCH="$arch" -Ptb_fir.TEST_CASE="$test_case" \
            -o fir_sim "$src/main.v" "$src/fir_parallel.v" "$src/fir_serial.v" \
            "$root/ece524_lab5.srcs/sim_1/new/tb_fir.v"
        vvp fir_sim
    done
done
