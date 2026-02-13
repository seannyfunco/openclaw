#!/bin/bash
set -e

mkdir -p /data/.openclaw /data/workspace
chown -R node:node /data

export OPENCLAW_STATE_DIR=/data/.openclaw
export OPENCLAW_WORKSPACE_DIR=/data/workspace
export OPENCLAW_CONFIG_DIR=/data/.openclaw
export OPENCLAW_GATEWAY_BIND=lan
export HOME=/home/node

# Force bind and auth in the config file
CONFIG_FILE=/data/.openclaw/openclaw.json
if [ -f "$CONFIG_FILE" ]; then
  # Patch existing config to set bind=lan
  gosu node node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8'));
    cfg.gateway = cfg.gateway || {};
    cfg.gateway.bind = 'lan';
    cfg.gateway.auth = cfg.gateway.auth || {};
    cfg.gateway.auth.mode = cfg.gateway.auth.mode || 'token';
    cfg.gateway.auth.token = cfg.gateway.auth.token || process.env.OPENCLAW_GATEWAY_TOKEN || 'railway-default-token';
    fs.writeFileSync('$CONFIG_FILE', JSON.stringify(cfg, null, 2));
  "
else
  # Create minimal config
  gosu node node -e "
    const fs = require('fs');
    const cfg = {
      gateway: {
        bind: 'lan',
        auth: { mode: 'token', token: process.env.OPENCLAW_GATEWAY_TOKEN || 'railway-default-token' }
      }
    };
    fs.writeFileSync('$CONFIG_FILE', JSON.stringify(cfg, null, 2));
  "
fi

exec gosu node "$@"
