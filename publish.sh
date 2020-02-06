#!/bin/bash

set -eEufo pipefail

cd "$(dirname $(realpath $0))"

if [[ "$#" -ne 1 ]]; then
	echo >&2 'Usage: ./publish.sh post-relative-url'
	exit 1
elif [[ ! -e "content/$1.md" ]]; then
	echo >&2 "File not found: content/$1.md"
	exit 2
elif [[ ! -z "$(git status --porcelain)" ]]; then
	echo >&2 "Uncommitted changes:"
	git status >&2
	exit 2
fi

git switch -c "publish/$1"
mv "content/$1.md" "content/$(date +'%Y-%m-%d')-$1.md"
sed -zi 's/draft = true\n//' "content/$(date +'%Y-%m-%d')-$1.md"
git add "content/$(date +'%Y-%m-%d')-$1.md"
git commit -m "Publish $1"
git push --set-upstream origin "publish/$1"
echo "$1"
