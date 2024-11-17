from beanie import Document

from app.domain.model import User


class UserModel(User, Document):
    # id: UUID4 = Field(default_factory=uuid4)
    # name: str


    class Settings:
        name = "users"
