#!/bin/bash
set -e

cd "$(dirname "$0")/.."

luarocks test --local --lua-version 5.1 "$@"
