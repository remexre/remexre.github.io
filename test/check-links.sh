#!/bin/bash

set -eu

cd "$(dirname "${BASH_SOURCE[0]}")/.."

command -v htmltest >/dev/null || go get -u github.com/wjdp/htmltest
command -v hugo >/dev/null || go get -u github.com/gohugoio/hugo

hugo
htmltest public
