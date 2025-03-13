#!/bin/env bash

PATH_SUFFIX="$(date +"%Y%m%d-%H%m")"
POSTGRESQL_BRANCH="REL_17_STABLE"
POSTGRESQL_SOURCE_PATH="/home/vinnix/Sources/Gitlab/postgres"
POSTGRESQL_EXEC_PATH="$HOME/pg-versions/$POSTGRESQL_BRANCH-$PATH_SUFFIX"
POSTGRESQL_DATA_PATH="$HOME/pg-versions/DATA/$POSTGRESQL_BRANCH-$PATH_SUFFIX"

cd $POSTGRESQL_SOURCE_PATH
 
git switch $POSTGRESQL_BRANCH
git pull 

mkdir $POSTGRESQL_EXEC_PATH
mkdir $POSTGRESQL_DATA_PATH

make maintainer-clean
CC=clang $POSTGRESQL_SOURCE_PATH/configure --prefix="$POSTGRESQL_EXEC_PATH" \
       	--with-openssl --enable-dtrace --enable-debug

make -j2
make install

$POSTGRESQL_EXEC_PATH/bin/initdb -D $POSTGRESQL_DATA_PATH --locale-provider="icu" \
	--icu-locale=ga \
	--data-checksums \
	--pwprompt \
	--auth="scram-sha-256"


