import os

# 服务配置
FUNASR_SERVER = os.getenv("FUNASR_SERVER", "wss://127.0.0.1:10095")
USE_SSL = os.getenv("USE_SSL", "true").lower() == "true"
MAX_CONCURRENCY = int(os.getenv("MAX_CONCURRENCY", "8"))
SERVICE_VERSION = "1.0.0"

# API Keys 多用户
ASR_API_KEYS = os.getenv("ASR_API_KEYS", "hejia:hejiaASR")
API_KEY_MAP = {}
for pair in ASR_API_KEYS.split(","):
    if ":" in pair:
        user, key = pair.split(":", 1)
        API_KEY_MAP[key.strip()] = user.strip()
