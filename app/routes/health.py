from fastapi import APIRouter
from ..config import SERVICE_VERSION

router = APIRouter()


@router.get("/")
async def root():
    return {
        "service": "ASR Gateway",
        "status": "running",
        "version": SERVICE_VERSION,
        "endpoints": {
            "/healthz": "健康检查",
            "/version": "服务版本",
            "/asr": "语音识别（POST，需 X-API-Key 和文件）",
            "/summary": "调用统计（GET，需 X-API-Key）"
        }
    }


@router.get("/healthz")
async def healthz():
    return {"status": "ok"}


@router.get("/version")
async def version():
    return {"service": "ASR Gateway", "version": SERVICE_VERSION}
