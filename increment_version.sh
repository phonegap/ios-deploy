#!/bin/sh

if [ -z "$1" ] 
then
  echo "Usage: $0 [version_to_set]"
  exit 1
fi

echo "\"$1\"" > src/ios-deploy/version.h
npm version --no-git-tag-version $1
