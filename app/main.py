from fastapi import FastAPI
from .config import SERVICE_VERSION
from .routes import health, asr, summary

app = FastAPI(
    title="ASR Gateway",
    description="HTTP → FunASR WebSocket Gateway",
    version=SERVICE_VERSION,
)

# 注册路由
app.include_router(health.router)
app.include_router(asr.router)
app.include_router(summary.router)
