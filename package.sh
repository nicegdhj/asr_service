#!/bin/bash
set -e

# ===============================
# 配置
# ===============================
FUNASR_IMAGE="registry.cn-hangzhou.aliyuncs.com/funasr_repo/funasr:funasr-runtime-sdk-cpu-0.4.7"
GATEWAY_IMAGE="asr-gateway:prod"
NGINX_IMAGE="nginx:alpine"

OUTPUT_DIR="./deploy_package"
MODELS_DIR="./funasr_resources/models"

# ===============================
# 准备输出目录
# ===============================
echo "📦 准备输出目录..."
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/images
mkdir -p $OUTPUT_DIR/models

# ===============================
# Step 1: 拉取/构建镜像
# ===============================
echo "🐳 检查并准备 FunASR 镜像..."
docker pull $FUNASR_IMAGE

echo "🐳 构建 Gateway 镜像..."
docker build -t $GATEWAY_IMAGE -f gateway_app/Dockerfile gateway_app/

echo "🐳 拉取 Nginx 镜像..."
docker pull $NGINX_IMAGE

# ===============================
# Step 2: 保存镜像为 tar
# ===============================
echo "📦 保存 Docker 镜像..."
docker save -o $OUTPUT_DIR/images/funasr.tar $FUNASR_IMAGE
docker save -o $OUTPUT_DIR/images/asr-gateway.tar $GATEWAY_IMAGE
docker save -o $OUTPUT_DIR/images/nginx.tar $NGINX_IMAGE

# ===============================
# Step 3: 打包模型
# ===============================
if [ -d "$MODELS_DIR" ]; then
    echo "📦 打包模型文件..."
    tar -czf $OUTPUT_DIR/models/models.tar.gz -C $MODELS_DIR .
else
    echo "⚠️ 模型目录 $MODELS_DIR 不存在，跳过打包"
fi

# ===============================
# Step 4: 打包配置文件和脚本
# ===============================
echo "📦 复制配置文件..."
cp infra/docker-compose.yml $OUTPUT_DIR/
cp infra/bak.yml $OUTPUT_DIR/
cp -r infra/nginx $OUTPUT_DIR/
cp scripts/*.sh $OUTPUT_DIR/

# ===============================
# 完成
# ===============================
echo "✅ 打包完成，结果在 $OUTPUT_DIR"
ls -lh $OUTPUT_DIR/images
ls -lh $OUTPUT_DIR/models