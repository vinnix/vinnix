#!/usr/bin/env bash


cat analysis.leaf.output | grep " 0 dep" | grep "0 that" | awk '{print $4}' | sort | uniq        >  analysis.zero.output
cat analysis.autoremove.output | grep " 0 dep" | grep "0 that" | awk '{print $4}' | sort | uniq  >> analysis.zero.output

cat analysis.zero.output | sort  > analysis.zero.sorted.output
rm analysis.zero.output

