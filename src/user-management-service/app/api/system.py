from fastapi import APIRouter
from starlette import status

router = APIRouter()

@router.get("/health", status_code=status.HTTP_200_OK)
async def health():
    return {"status": "ok"}

@router.get("/error/", status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
async def error():
    pass