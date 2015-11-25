#!/bin/bash
#
# Copies contents of html doc dir to base dir of temp branch
# Append temp branch to top of gh-pages and commit gh-pages.
#
# run make html in docs first!

# def vars
REPONAME=nukecluster
BASEDIR=/root
SRCREPO=$BASEDIR/$REPONAME
SRCDOCS=$SRCREPO/doc/build/html
TMPREPO=/tmp/docs/$REPONAME
MSG="gh-pages docs for `git log -1 --pretty=short --abbrev-commit`"

# clean tmprepo
rm -rf $TMPREPO
mkdir -p -m 0755 $TMPREPO

# create temp repo and cd into it
git clone git@github.com:wgurecky/nukecluster.git $TMPREPO
cd $TMPREPO

# checkout gh-pages in tmp repo
git checkout gh-pages

# update gh-pages branch with new html docs
cp -r $SRCDOCS/ $TMPREPO

# Ensure all files get added to gh-pages branch
git add -A

# commit gh-pages
git commit -m "$MSG"
git push origin gh-pages

# cd back to where we started
cd $SRCREPO
