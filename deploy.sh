#!/usr/bin/env sh

set -e

npm run build

cd dist

git init
git add -A
git commit -m 'New Deployment'
git push -f git@github.com:Stuurrgis/Last.fm-Vue-Data-Retrieval-and-Preprocessor.git master:gh-pages

cd -