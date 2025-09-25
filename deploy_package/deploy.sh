#!/bin/bash
set -euo pipefail

# 计算脚本所在目录（无论从哪里执行都能找到正确路径）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGES_DIR="$SCRIPT_DIR/images"
MODELS_TGZ="$SCRIPT_DIR/models/models.tar.gz"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

echo "🚀 部署目录: $SCRIPT_DIR"

# ==============================
# Step 1: 加载 Docker 镜像
# ==============================
echo "🐳 导入 Docker 镜像..."
if [ -d "$IMAGES_DIR" ]; then
  for tar in "$IMAGES_DIR"/*.tar; do
    if [ -f "$tar" ]; then
      echo "➡️  加载镜像: $tar"
      docker load -i "$tar"
    fi
  done
else
  echo "❌ 未找到目录: $IMAGES_DIR"
  exit 1
fi
echo "✅ 镜像导入完成"
echo

# ==============================
# Step 2: 解压模型文件
# ==============================
if [ -f "$MODELS_TGZ" ]; then
  echo "📦 解压模型: $MODELS_TGZ"
  mkdir -p "$SCRIPT_DIR/funasr-runtime-resources/models"
  tar -xzf "$MODELS_TGZ" -C "$SCRIPT_DIR/funasr-runtime-resources/models"
  echo "✅ 模型解压完成"
else
  echo "⚠️ 未找到模型压缩包: $MODELS_TGZ，跳过解压"
fi
echo

# ==============================
# Step 3: 启动服务
# ==============================
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "❌ 未找到 docker-compose.yml: $COMPOSE_FILE"
  exit 1
fi

echo "🔧 启动 docker-compose 服务..."
cd "$SCRIPT_DIR"
docker-compose up -d --scale funasr=2 --scale asr_gateway=2
echo "✅ 服务已启动"
echo

# ==============================
# Step 4: 健康检查
# ==============================
echo "🌐 健康检查..."
sleep 5
if curl -s http://127.0.0.1:8080/healthz > /dev/null; then
  echo "✅ 健康检查通过"
else
  echo "❌ 健康检查失败，请运行 ./check.sh 查看日志"
fi

echo "🎉 部署完成。入口: http://<你的服务器IP>:8080/asr"