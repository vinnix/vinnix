#!/usr/bin/env bash

function is_equal () {
	#echo "Param1: $1"
	orig_path=$(echo $1 | sed  's/^\.//')
	echo $orig_path
	diff_result=$(diff $orig_path $1)
	#echo "Diff result: $diff_result"
	if [ -z "$diff_result" ];
	then
	  true
	else
	  false
	fi
}

function verify_directories () {
    echo "$1" | while read -r p ;
    do
       find "$p" -type f -exec bash -c 'is_equal "{}" && echo "yes" || echo "no"' \;
    done
}

export -f is_equal


echo "Syncing config files from System to Git repository"


verify_directories "./boot"
verify_directories "./etc"
verify_directories "./usr/local"
