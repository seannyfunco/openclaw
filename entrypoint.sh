#!/bin/bash
set -e

# Create data directories if they don't exist
mkdir -p /data/.openclaw /data/workspace

# Fix ownership so the node user can write to the volume
chown -R node:node /data

# Export state/workspace dirs so OpenClaw uses the volume
export OPENCLAW_STATE_DIR=/data/.openclaw
export OPENCLAW_WORKSPACE_DIR=/data/workspace
export OPENCLAW_CONFIG_DIR=/data/.openclaw
export HOME=/home/node

exec gosu node node openclaw.mjs gateway --allow-unconfigured --host 0.0.0.0 --port 8080
