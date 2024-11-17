from typing import List, Union, Type

from beanie import Document, init_beanie, View
from motor.motor_asyncio import AsyncIOMotorClient

from app.core.config import settings

async def init_db(document_models: List[Union[Type[Document], Type[View], str]] = None):
    if hasattr(settings, "db"):
        kwargs = {
            "host": settings.db.host,
            "port": settings.db.port,
        }
        if settings.db.auth.enabled:
            kwargs['username'] = settings.db.auth.username
            kwargs['password'] = settings.db.auth.password

        client = AsyncIOMotorClient(
            **kwargs,
            uuidRepresentation="standard"
        )
        await init_beanie(
            database=client['userdb'],
            document_models=document_models,
        )
