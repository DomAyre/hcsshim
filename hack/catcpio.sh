#!/bin/sh

set -e

dir="`mktemp -d`"
trap 'rm -rf "$dir"' EXIT

for file; do
    if ! [ -f "$file" ]; then
        echo file not found: "$file"
        exit 1
    fi
    case `file -bz "$file"` in
        "ASCII cpio archive"*"(gzip compressed data"*)
            gunzip -c "$file" | (cd "$dir" && cpio -iud) ;;
        "ASCII cpio archive"*)
            cat "$file" | (cd "$dir" && cpio -iud) ;;
        *)
            tar -xf "$file" -C "$dir" ;;
    esac
done
# Normalize timestamps using SOURCE_DATE_EPOCH
find "$dir" -exec touch -h -d "@$SOURCE_DATE_EPOCH" {} +
cd "$dir" && find . | cpio --create --reproducible --format=newc -R 0:0
