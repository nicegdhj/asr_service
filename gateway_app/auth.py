from fastapi import Depends, HTTPException
from fastapi.security.api_key import APIKeyHeader
from .config import API_KEY_MAP

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)


async def verify_api_key(api_key: str = Depends(api_key_header)):
    if api_key not in API_KEY_MAP:
        raise HTTPException(status_code=401, detail="Invalid or missing API Key")
    return API_KEY_MAP[api_key]
