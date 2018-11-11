#!/usr/bin/env bash

echo "Syncing config files from System to Git repository"

find ./boot -type f -exec echo "syncing ... " {} \;
