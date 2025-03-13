#!/bin/env bash


for p in $(cat installed_packages_centos_9_20250313.log | awk '{print $1}')
do
    sudo yum install $p -y
done
