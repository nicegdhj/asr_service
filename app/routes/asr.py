import time
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from fastapi.responses import JSONResponse
from ..auth import verify_api_key
from ..asr_client import convert_to_pcm16, asr_request
from ..usage import log_usage

router = APIRouter()


@router.post("/asr")
async def asr_api(file: UploadFile = File(...), user: str = Depends(verify_api_key)):
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
        raise HTTPException(status_code=500, detail=str(e))
