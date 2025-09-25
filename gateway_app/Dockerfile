# ===========================
# 1. 基础镜像
# ===========================
FROM python:3.10-slim

WORKDIR /app

# ===========================
# 2. 系统依赖
# ===========================
RUN apt-get update && apt-get install -y \
    ffmpeg curl \
    && rm -rf /var/lib/apt/lists/*

# ===========================
# 3. 安装依赖
# ===========================
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ===========================
# 4. 拷贝源码 (只拷 gateway_app)
# ===========================
COPY gateway_app/ .

# ===========================
# 5. 环境变量
# ===========================
ENV PYTHONUNBUFFERED=1 \
    UVICORN_HOST=0.0.0.0 \
    UVICORN_PORT=22800 \
    UVICORN_WORKERS=2

# ===========================
# 6. 启动命令
# ===========================
CMD ["uvicorn", "gateway_app.main:app", "--host", "0.0.0.0", "--port", "22800"]