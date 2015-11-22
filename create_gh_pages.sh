#!/bin/bash
#
# This script switches to the github-pages doc branch,
# auto generates html from .rst files using sphinx 
# pushes the resulting html files to github and finally
# switches back to the master branch
#
# Notes:
# ------
# Requires sphinx is installed: auto html doc builder
# Requires the following var is set in the sphinx makefile:
# GH_PAGES_SOURCES = source Makefile

if [-n "$git status --porcelain)" ]; then
  echo "Commit master changes before building docs.";
else
  echo "Master is clean. Building docs...";
  GH_PAGES_SOURCES="source Makefile"
  git checkout gh-pages
  #rm -rf build _sources _static
  touch ./.nojekyll
  git checkout master doc/source doc/Makefile
  git reset HEAD
  cd doc
  make html
  mv -fv build/html/* ../.
  rm -rf source Makefile build
  cd ..
  git add -A
  git commit -m "Gen gh-pages for `git log master -1 --pretty=short --abbrev-commit`" && git push origin gh-pages ; git checkout master
fi
