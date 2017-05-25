#!/usr/bin/env bash

set -e -x

git fetch -vp

changed_files=$(git diff --name-only origin/master..HEAD)

for changed_file in $changed_files; do
    master_file=$(mktemp)
    curr_file=$(mktemp)
    git show -s origin/master:$changed_file > $master_file
    mv $changed_file $curr_file
    latexdiff --exclude-textcmd="chapter,section,subsection" $master_file $curr_file > $changed_file
    rm $master_file
    rm $curr_file
done

make

git reset HEAD --hard
