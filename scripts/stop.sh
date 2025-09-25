#!/bin/bash
set -e

echo "🛑 停止 ASR 系统..."

docker-compose down

echo "✅ 系统已停止。"