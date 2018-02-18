#!/bin/bash

set -eu

REPO_PATH="/app/data/repo.git"
WEBSITE_PATH="/app/data/website"

if [[ ! -d $REPO_PATH ]]; then
    echo "=> First run, create bare repo"
    mkdir -p $REPO_PATH
    git init --bare $REPO_PATH

    echo "=> Install welcome page"
    rm -rf $WEBSITE_PATH
    mkdir -p $WEBSITE_PATH
    cp /app/code/welcome.html $WEBSITE_PATH/index.html
fi

if grep "cloudron-welcome-page" $WEBSITE_PATH/index.html; then
    echo "=> Update welcome page"
    sed -e "s,##REPO_URL##,${APP_ORIGIN}/_git/page," /app/code/welcome.html > $WEBSITE_PATH/index.html
fi

echo "=> Ensure git hook"
# cp /app/code/post-receive $REPO_PATH/hooks/post-receive
rm -f $REPO_PATH/hooks/post-receive
cp /app/code/pre-receive $REPO_PATH/hooks/pre-receive

echo "=> Ensure permissions"
chown cloudron:cloudron -R $REPO_PATH /run /app/data

echo "=> Run server"
export REPO_PATH
export WEBSITE_PATH
exec /usr/local/bin/gosu cloudron:cloudron node /app/code/index.js
