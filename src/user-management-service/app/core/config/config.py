"""Project settings.

The module defines the project settings and the configuration of dependent applications.


References:
    https://docs.pydantic.dev/latest/concepts/pydantic_settings
    https://fastapi.tiangolo.com/advanced/settings/#creating-the-settings-only-once-with-lru_cache
    https://docs.pydantic.dev/2.0/usage/computed_fields/

    Field validators:
    https://docs.pydantic.dev/latest/concepts/validators/#field-validators
"""
import os
from typing import Type, Tuple

from pydantic import BaseModel, field_validator, Field
from pydantic_core.core_schema import ValidationInfo
from pydantic_settings import (
    BaseSettings,
    SettingsConfigDict,
    PydanticBaseSettingsSource,
    YamlConfigSettingsSource
)

__all__ = ["settings"]


class MongoDBAuthConfig(BaseModel):
    enabled: bool = False
    username: str = Field(validate_default=True, default='')
    password: str = Field(validate_default=True, default='')

    @field_validator('username', 'password')
    @classmethod
    def validate_auth(cls, value: str,  info: ValidationInfo) -> str:
        if info.data['enabled']:
            if value == '':
                raise ValueError(f'Field {info.field_name} can not be empty')
        return value



class MongoDBConfig(BaseSettings):
    port: int = '27017'
    host: str = 'mongo'
    auth: MongoDBAuthConfig = Field(default_factory=MongoDBAuthConfig)

    model_config = SettingsConfigDict(env_prefix='MONGO_', env_ignore_empty=True, env_nested_delimiter='__')


class PathConfig(BaseSettings):
    config_path: str = ''


class AppConfig(BaseSettings):
    api_prefix: str = '/api'

    model_config = SettingsConfigDict(yaml_file=PathConfig().config_path)

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls: Type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> Tuple[PydanticBaseSettingsSource, ...]:
        return (YamlConfigSettingsSource(settings_cls),)


class Settings(BaseSettings):
    app: AppConfig = Field(default_factory=AppConfig)
    db: MongoDBConfig = Field(default_factory=MongoDBConfig)


settings = Settings()

if __name__ == '__main__':
    os.environ.setdefault('mongo_port', '27017')
    os.environ.setdefault('MONGO_HOST', 'mongo')
    os.environ.setdefault('MONGO_AUTH__ENABLED', 'true')
    os.environ.setdefault('MONGO_AUTH__USERname', 'user')
    os.environ.setdefault('MONGO_AUTH__password', '123')



    settings = Settings()
    print(settings.model_dump())
