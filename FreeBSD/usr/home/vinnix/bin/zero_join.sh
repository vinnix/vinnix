#!/usr/bin/env bash


cat analysis.leaf.output | grep " 0 dep" | grep "0 that" | awk '{print $4}' | sort | uniq        >  analysis.zero.output
cat analysis.autoremove.output | grep " 0 dep" | grep "0 that" | awk '{print $4}' | sort | uniq  >> analysis.zero.output

cat analysis.zero.output | sort  > analysis.zero.sorted.output
rm analysis.zero.output

awk 'FNR==NR{col4[$4]; next} $4 in col4{print $4}' analysis.autoremove.output analysis.leaf.output 


# Simple test to verify if packages on autoremove are not present on leaf
awk -f notin.awk - analysis.leaf.output  < analysis.autoremove.output
