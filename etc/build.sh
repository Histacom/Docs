#!/usr/bin/env bash

DOCS_REPO=${DOCS_REPO:-"git@github.com:Histacom/Docs.git"}
LEX_DEPLOY=https://github.com/LexBot/Deploy.git
DEPLOY_SCRIPTS=/tmp/histacom/deploy

# Get the deploy scripts
git clone $LEX_DEPLOY $DEPLOY_SCRIPTS

# Initialize the ssh-agent so we can use Git later for deploying
eval $(ssh-agent)

# Set up our Git environment
$DEPLOY_SCRIPTS/setup_git

# Clone repo
mkdir build
cd build
git init
git remote add origin $DOCS_REPO
git fetch
git checkout gh-pages

# Build the docs
sphinx-build -b html ../source .

# If we're on the master branch, do deploy
if [[ $TRAVIS_BRANCH = master ]]; then
    # Deploy
    git add --all .
    git commit -q -m "Deploy $(date)"
    git push -q -f origin gh-pages
    echo "Done! Successfully published docs!"
fi

# Kill the ssh-agent because we're done with deploying
eval $(ssh-agent -k)

exit 0