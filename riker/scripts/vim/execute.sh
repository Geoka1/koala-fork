#!/bin/bash

REPO_TOP="$(git rev-parse --show-toplevel)"
eval_dir="${REPO_TOP}/riker"
input_dir="${eval_dir}/inputs/scripts"
scripts_dir="${eval_dir}/scripts"

KOALA_SHELL=${KOALA_SHELL:-bash}
export BENCHMARK_SCRIPT="$(realpath "$scripts_dir/vim/build.sh")"
export BENCHMARK_INPUT_FILE="$(realpath "$input_dir/vim/dev")"
(cd "$input_dir/vim/dev" && $KOALA_SHELL "$scripts_dir/vim/build.sh")


