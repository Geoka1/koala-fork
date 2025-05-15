#!/bin/bash

cd "$(realpath "$(dirname "$0")")" || exit 1
REPO_TOP=$(git rev-parse --show-toplevel)   
eval_dir="${REPO_TOP}/ray-tracing"
outputs_dir="${eval_dir}/outputs"
hash_folder="${eval_dir}/hashes"
generate=false

[ ! -d "$outputs_dir" ] && echo "Directory '$outputs_dir' does not exist" && exit 1

size=full
for arg in "$@"; do
    case "$arg" in
        --generate) generate=true ;;
        --small) size=small ;;
        --min) size=min ;;
    esac
done

hash_folder="$hash_folder/$size"
outputs_dir="$outputs_dir/$size"
mkdir -p "$hash_folder"

if $generate; then
    ray_csv_file="$outputs_dir/rays.csv"
    ray_csv_hash=$(shasum -a 256 "$ray_csv_file" | awk '{ print $1 }')
    echo "$ray_csv_hash" > "$hash_folder/rays.csv.hash"

    for file in "$outputs_dir"/*.log; do
        filename=$(basename "$file" .log)
        hash=$(shasum -a 256 "$file" | awk '{ print $1 }')
        echo "$hash" > "$hash_folder/$filename.hash"
        echo "$hash_folder/$filename.hash $hash"
    done
    exit 0
fi

all_ok=0

ray_csv_file="$outputs_dir/rays.csv"
ray_csv_hash=$(shasum -a 256 "$ray_csv_file" | awk '{ print $1 }')
ray_csv_hash_file="$hash_folder/rays.csv.hash"
if [[ ! -f "$ray_csv_hash_file" ]]; then
    echo "Missing hash file: $ray_csv_hash_file"
    all_ok=1
else
    expected_hash=$(cat "$ray_csv_hash_file")
    if [[ "$ray_csv_hash" != "$expected_hash" ]]; then
        echo "rays.csv 1"
        all_ok=1
    else
        echo "rays.csv 0"
    fi
fi

for file in "$outputs_dir"/*.log; do
    filename=$(basename "$file" .log)
    actual_hash=$(shasum -a 256 "$file" | awk '{ print $1 }')
    expected_hash_file="$hash_folder/$filename.hash"

    if [[ ! -f "$expected_hash_file" ]]; then
        echo "Missing hash file: $expected_hash_file"
        all_ok=1
        continue
    fi

    expected_hash=$(cat "$expected_hash_file")
    if [[ "$actual_hash" != "$expected_hash" ]]; then
        echo "$filename 1"
        all_ok=1
    else
        echo "$filename 0"
    fi
done
exit $all_ok
