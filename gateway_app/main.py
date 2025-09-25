from fastapi import FastAPI
from .config import SERVICE_VERSION, FUNASR_SERVER
from .routes.asr_service import router as asr_router
from .logging_conf import logger  # 导入日志配置

app = FastAPI(
    title="ASR Gateway",
    description="HTTP → FunASR WebSocket Gateway",
    version=SERVICE_VERSION,
)

# 注册路由（由 asr_service 统一管理）
app.include_router(asr_router)

@app.on_event("startup")
async def startup_event():
    """应用启动事件"""
    logger.info(f"ASR Gateway 启动成功，版本: {SERVICE_VERSION}")
    logger.info(f"FunASR 服务器: {FUNASR_SERVER}")
    logger.info("服务已准备就绪，等待请求...")

@app.on_event("shutdown")
async def shutdown_event():
    """应用关闭事件"""
    logger.info("ASR Gateway 正在关闭...")
