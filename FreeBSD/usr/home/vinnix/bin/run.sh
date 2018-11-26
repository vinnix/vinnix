#!/usr/bin/env bash


./pkgs_analysis.sh -a > analysis.autoremove.output
./pkgs_analysis.sh -l > analysis.leaf.output

pkg info > pkg.info.output

pkg query -e '%m = ports@FreeBSD.org' %o > pkg.unmaintained.output

cat analysis.autoremove.output | grep " 0 dep" | grep "0 that" | awk '{print $4}' | sort | uniq
cat analysis.leaf.output | grep " 0 dep" | grep "0 that" | awk '{print $4}' | sort | uniq

