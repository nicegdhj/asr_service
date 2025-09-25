#!/bin/bash
set -e

echo "🔄 重启 ASR 系统..."

# 先停止
docker-compose down

# 再启动（可以修改 scale 数量）
docker-compose up -d --build --scale asr_gateway=2

echo "✅ 系统已重启。"

# 简单健康检查
sleep 5
curl -s http://127.0.0.1:8080/healthz || echo "❌ 健康检查失败，请检查日志。"