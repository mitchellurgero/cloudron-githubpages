#!/bin/bash

set -eu

echo "==================================="
echo "Publishing website"
echo "==================================="

BUILD_PATH="/run/build"
WEBSITE_PATH="/app/data/website"

echo "=> Cleanup build path"
sudo rm -rf $BUILD_PATH
mkdir -p $BUILD_PATH
cd $BUILD_PATH

echo "=> Checkout repo"
git clone "/app/data/repo.git/" .

# Without removing it, the dependencies will be wrong on jekyll build
echo "=> Remove Gemfile.lock"
rm -f Gemfile.lock

if [[ -f _config.yml ]]; then
    echo "=> jekyll build"
    jekyll build

    echo "=> Publish website"
    rm -rf $WEBSITE_PATH
    cp -rf $BUILD_PATH/_site $WEBSITE_PATH
else
    echo "=> Publish website"
    rm -rf $WEBSITE_PATH
    cp -rf $BUILD_PATH $WEBSITE_PATH
fi

