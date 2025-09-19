FROM python:3.9-slim

WORKDIR /app

# 安装系统依赖（pydub 需要 ffmpeg，soundfile 需要 libsndfile）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY ./app ./app
COPY run.sh .

# 默认环境变量（在 docker-compose.yml 会覆盖）
ENV FUNASR_SERVER="wss://funasr:10095"
ENV ASR_API_KEYS="hejia:hejia123"
ENV MAX_CONCURRENCY=8

EXPOSE 22800

CMD ["bash", "run.sh"]