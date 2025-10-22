#!/usr/bin/env bash

echo "Syncing system config files"
cd ~/.config
git pull
echo "Syncing complete!"

