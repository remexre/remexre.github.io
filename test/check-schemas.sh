#!/bin/bash

set -eu

cd "$(dirname "${BASH_SOURCE[0]}")/../content"

function testDir() {
	pushd "${1}" > /dev/null
	for file in *.json; do
		echo "Checking ${file}..."
		jv "${file}" "examples/${file}"
	done
	popd > /dev/null
}

command -v jv >/dev/null || go get -u github.com/santhosh-tekuri/jsonschema/cmd/jv

testDir draft01/messages
testDir draft01/products
testDir draft02/messages
testDir draft02/products
