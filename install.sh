#!/bin/bash
cd /data/workspace/docs-site
rm -rf node_modules pnpm-lock.yaml .pnpm-workspace-state-v1.json 2>/dev/null
pnpm install --prefer-offline --force > /data/workspace/pnpm-final.log 2>&1
echo "EXIT=$?" >> /data/workspace/pnpm-final.log
