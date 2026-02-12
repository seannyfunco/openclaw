#!/bin/bash
set -e
mkdir -p /data/.openclaw /data/workspace
chown -R node:node /data
exec gosu node "$@"
