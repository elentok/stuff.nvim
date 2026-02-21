#!/usr/bin/env bash

set -euo pipefail

brew install luarocks

luarocks --lua-version 5.1 install busted --local
luarocks --lua-version 5.1 install luassert --local
