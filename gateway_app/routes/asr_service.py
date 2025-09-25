import time
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from fastapi.responses import JSONResponse
from ..auth import verify_api_key
from ..asr_client import convert_to_pcm16, asr_request
from ..usage import log_usage
from ..config import SERVICE_VERSION
from ..usage import get_summary
from ..logging_conf import logger

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


@router.post("/asr")
async def asr_api(file: UploadFile = File(...), user: str = Depends(verify_api_key)):
    logger.info(f"收到 ASR 请求: user={user}, filename={file.filename}, content_type={file.content_type}")
    start_time = time.time()
    try:
        raw_bytes = await file.read()


        pcm_bytes = convert_to_pcm16(raw_bytes, file.filename)
        
        result = await asr_request(pcm_bytes, file.filename)
        elapsed = round(time.time() - start_time, 3)
        
      
        log_usage(user, file.filename, elapsed, result)
        
        return JSONResponse(content={
            "code": 0,
            "message": "success",
            "data": {
                "user": user,
                "filename": file.filename,
                "elapsed": elapsed,
                "result": result
            }
        })
    except Exception as e:
        logger.error(f"ASR 处理失败: {str(e)}", exc_info=True)
        # 捕获所有异常并返回统一格式
        return JSONResponse(
            status_code=500,
            content={
                "code": 500,
                "message": "internal server error",
                "detail": str(e),
                "data": None
            }
        )


@router.get("/healthz")
async def healthz():
    logger.info("收到健康检查请求")
    return {"status": "ok"}


@router.get("/version")
async def version():
    return {"service": "ASR Gateway", "version": SERVICE_VERSION}


@router.get("/summary")
async def summary_api(user: str = Depends(verify_api_key)):
    return get_summary(user)
