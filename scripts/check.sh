#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 检查 ASR 系统状态...${NC}"

# ==============================
# Step 1: Docker 容器状态
# ==============================
echo "🐳 正在运行的容器:"
docker ps --filter "name=funasr" --filter "name=asr_gateway" --filter "name=asr_nginx" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# ==============================
# Step 2: 健康检查接口
# ==============================
echo "🌐 健康检查 (Nginx -> Gateway):"
if curl -s http://127.0.0.1:8080/healthz > /dev/null; then
  echo "✅ 健康检查通过"
else
  echo "❌ 健康检查失败，请检查 Gateway 日志"
fi
echo ""

# ==============================
# Step 3: Nginx 日志
# ==============================
echo "📜 最近 Nginx 访问日志:"
tail -n 10 nginx/logs/access.log || echo "⚠️ 没有 access.log 日志"
echo ""

echo "📜 最近 Nginx 错误日志:"
tail -n 10 nginx/logs/error.log || echo "⚠️ 没有 error.log 日志"
echo ""

# ==============================
# Step 4: Gateway 日志
# ==============================
echo "📜 最近 Gateway 日志 (asr_gateway 容器):"
docker logs --tail 20 $(docker ps -q --filter "name=asr_gateway") || echo "⚠️ 没有 Gateway 日志"
echo ""

# ==============================
# Step 5: FunASR 日志
# ==============================
echo "📜 最近 FunASR 日志 (funasr 容器):"
docker logs --tail 20 $(docker ps -q --filter "name=funasr") || echo "⚠️ 没有 FunASR 日志"
echo ""

echo "✅ 状态检查完成。"
