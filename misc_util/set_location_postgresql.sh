#!/bin/env bash

# lrwxrwxrwx.  1 vinnix vinnix   33 Mar 14 06:34 pg-17-stable-data -> DATA/REL_17_STABLE-20250311-0803
# lrwxrwxrwx.  1 vinnix vinnix   27 Mar 14 06:33 pg-17-stable-home -> REL_17_STABLE-20250311-0803


VERSION="REL_17_STABLE-20250311-0803"
PGPREFIX="$HOME/pg-versions"
PGHOME="$PGPREFIX/$VERSION"
PGDATA="$PGPREFIX/DATA/$VERSION"

cd $HOME/pg-versions
ln -s $PGHOME pg-17-stable-home
ln -s $PGDATA pg-17-stable-data
