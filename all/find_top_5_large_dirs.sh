#!/bin/env bash

find -type f -exec du -Sh {} + | sort -rh | head -n 5

