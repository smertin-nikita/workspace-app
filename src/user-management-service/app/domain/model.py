from uuid import uuid4

from pydantic import Field, UUID4, BaseModel


class User(BaseModel):
    id: UUID4 = Field(default_factory=uuid4)
    name: str

