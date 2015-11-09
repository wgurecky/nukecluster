#!/bin/bash
#
# Notes:
# ------
# Requires sphinx is install, auto html doc builder
# Requires the following var is set in the sphinx makefile:
# GH_PAGES_SOURCES = source Makefile

GH_PAGES_SOURCES="source Makefile"
git checkout gh-pages
#rm -rf build _sources _static
#touch .nojekyll
git checkout master $GH_PAGES_SOURCES
git reset HEAD
make html
mv -fv build/html/* ./
rm -rf $GH_PAGES_SOURCES build
git add -A
git commit -m "Gen gh-pages for `git log master -1 --pretty=short --abbrev-commit`" && git push origin gh-pages ; git checkout master
