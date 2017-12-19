#!/usr/bin/env bash

set -x

if [[ `git status --porcelain` ]]; then
    git stash save
    CHANGED=true
else
    CHANGED=false
fi

git fetch -vp

if [[ $# == 0 ]]; then
    ORIG="origin/master"
else
    ORIG=$1
fi

changed_files=$(git diff --name-only ${ORIG}..HEAD)

for changed_file in $changed_files; do
    if [[ $changed_file == *.tex ]]; then
        orig_file=$(mktemp)
        curr_file=$(mktemp)
        git show -s ${ORIG}:$changed_file > $orig_file
        if [ $? -ne 0 ]; then
            echo > $orig_file
        fi
        mv $changed_file $curr_file
        latexdiff --exclude-textcmd="chapter,section,subsection" $orig_file $curr_file > $changed_file
        rm $orig_file
        rm $curr_file
    fi
done

make

mv main.pdf diffed.pdf

git reset HEAD --hard

if [[ $CHANGED ]]; then
    git stash pop
fi
