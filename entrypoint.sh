#!/bin/bash
set -e

mkdir -p /data/.openclaw /data/workspace
chown -R node:node /data

export OPENCLAW_STATE_DIR=/data/.openclaw
export OPENCLAW_WORKSPACE_DIR=/data/workspace
export OPENCLAW_CONFIG_DIR=/data/.openclaw
export OPENCLAW_GATEWAY_BIND=lan
export HOME=/home/node

CONFIG_FILE=/data/.openclaw/openclaw.json
if [ -f "$CONFIG_FILE" ]; then
  gosu node node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8'));
    cfg.gateway = cfg.gateway || {};
    cfg.gateway.bind = 'lan';
    cfg.gateway.trustedProxies = ['100.64.0.0/10', '10.0.0.0/8', '172.16.0.0/12'];
    cfg.gateway.auth = cfg.gateway.auth || {};
    cfg.gateway.auth.mode = cfg.gateway.auth.mode || 'token';
    cfg.gateway.auth.token = cfg.gateway.auth.token || process.env.OPENCLAW_GATEWAY_TOKEN || 'railway-default-token';
    cfg.gateway.controlUi = cfg.gateway.controlUi || {};
    cfg.gateway.controlUi.allowInsecureAuth = true;
    cfg.channels = cfg.channels || {};
    cfg.channels.telegram = cfg.channels.telegram || {};
    cfg.channels.telegram.botToken = process.env.TELEGRAM_BOT_TOKEN || cfg.channels.telegram.botToken;
    cfg.channels.telegram.dmPolicy = cfg.channels.telegram.dmPolicy || 'pairing';
    cfg.env = cfg.env || {};
    cfg.env.ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY || cfg.env.ANTHROPIC_API_KEY;
    cfg.agents = cfg.agents || {};
    cfg.agents.defaults = cfg.agents.defaults || {};
    cfg.agents.defaults.model = cfg.agents.defaults.model || {};
    cfg.agents.defaults.model.primary = cfg.agents.defaults.model.primary || 'anthropic/claude-opus-4-6';
    delete cfg.agent;
    delete cfg.agents.defaults.auth;
    fs.writeFileSync('$CONFIG_FILE', JSON.stringify(cfg, null, 2));
  "
else
  gosu node node -e "
    const fs = require('fs');
    const cfg = {
      env: {
        ANTHROPIC_API_KEY: process.env.ANTHROPIC_API_KEY
      },
      gateway: {
        bind: 'lan',
        trustedProxies: ['100.64.0.0/10', '10.0.0.0/8', '172.16.0.0/12'],
        auth: { mode: 'token', token: process.env.OPENCLAW_GATEWAY_TOKEN || 'railway-default-token' },
        controlUi: { allowInsecureAuth: true }
      },
      channels: {
        telegram: {
          botToken: process.env.TELEGRAM_BOT_TOKEN,
          dmPolicy: 'pairing'
        }
      },
      agents: {
        defaults: {
          model: {
            primary: 'anthropic/claude-opus-4-6'
          }
        }
      }
    };
    fs.writeFileSync('$CONFIG_FILE', JSON.stringify(cfg, null, 2));
  "
fi

exec gosu node "$@"
