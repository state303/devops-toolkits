#!/bin/sh

mkdir -p data
touch data/config.json
# Owned by user ID of Docker container (1000)
chown -R 1000 data
# all access (for creating json database file data/updates.json)
chmod 700 data
# used to be 400 for read access only
chmod 700 data/config.json
