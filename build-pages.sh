#!/bin/bash

set -eu

echo "==================================="
echo "Publishing website"
echo "==================================="

BUILD_PATH="/run/build"
WEBSITE_PATH="/run/static"

echo "=> Cleanup build path"
rm -rf $BUILD_PATH
mkdir -p $BUILD_PATH
cd $BUILD_PATH

echo "=> Checkout repo"
git clone "/app/data/repo.git/" .

if [[ -f Gemfile ]]; then
    echo "=> Install gems"
    sudo bundle install
fi

if [[ -f _config.yml ]]; then
    echo "=> jekyll build"
    bundle exec jekyll build

    echo "=> Publish website"
    rm -rf $WEBSITE_PATH
    cp -rf $BUILD_PATH/_site $WEBSITE_PATH
else
    echo "=> Publish website"
    rm -rf $WEBSITE_PATH
    cp -rf $BUILD_PATH $WEBSITE_PATH
fi

