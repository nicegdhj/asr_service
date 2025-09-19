from fastapi import APIRouter, Depends
from ..auth import verify_api_key
from ..usage import get_summary

router = APIRouter()


@router.get("/summary")
async def summary_api(user: str = Depends(verify_api_key)):
    return get_summary(user)
