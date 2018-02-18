#!/bin/bash

set -eux

REPO_PATH="/app/data/repo.git"
WEBSITE_PATH="/run/static"

if [[ ! -d $REPO_PATH ]]; then
    echo "=> First run, create bare repo"
    mkdir -p $REPO_PATH
    git init --bare $REPO_PATH

    rm -rf $WEBSITE_PATH
    mkdir -p $WEBSITE_PATH
    echo "Push to https://blabla" > $WEBSITE_PATH/index.html
else
    echo "=> Building pages"
    chown cloudron:cloudron -R $REPO_PATH /run
    /usr/local/bin/gosu cloudron:cloudron /app/code/build-pages.sh
fi

echo "=> Ensure git hook"
cp /app/code/post-receive $REPO_PATH/hooks/post-receive

echo "=> Ensure permissions"
chown cloudron:cloudron -R $REPO_PATH /run

echo "=> Run server"
exec /usr/local/bin/gosu cloudron:cloudron node /app/code/index.js
