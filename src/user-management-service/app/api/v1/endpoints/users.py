from typing import List, Annotated

from fastapi import APIRouter, HTTPException
from fastapi.params import Query
from pydantic import BaseModel, Field, UUID4
from starlette import status

from app.adapters.object_model import UserModel
from app.domain.model import User

router = APIRouter(
    responses={404: {"description": "User not found"}},
)


class UserCreateRequest(BaseModel):
    name: str


class UserUpdateRequest(BaseModel):
    name: str


class UserGetRequest(BaseModel):
    id: UUID4 = Field(alias="user-id")


class UserDeleteRequest(BaseModel):
    id: UUID4 = Field(alias="user-id")


class UserListRequest(BaseModel):
    limit: int = Field(100, gt=0, le=100)
    offset: int = Field(0, ge=0)
    name: str | None = None
    order_by: str = "name"


class UserResponse(User):
    pass


@router.post("/", response_model=UserResponse)
async def create(
    request: UserCreateRequest
):
    user = UserModel(**request.model_dump())
    await user.create()
    return user

@router.patch("/{user_id}/", response_model=UserResponse)
async def update(
    user_id: UUID4,
    name :str
):
    user = await UserModel.find(UserModel.id == user_id).first_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user = await user.set({"name": name})
    return user

@router.get("/{user_id}/", response_model=UserResponse)
async def get(
    user_id: UUID4,
):
    user = await UserModel.find(UserModel.id == user_id).first_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.get("/", response_model=List[UserResponse])
async def list(
    request: Annotated[UserListRequest, Query()]
):
    query = UserModel.find(limit=request.limit, skip=request.offset)
    if request.name:
        query = query.find(UserModel.name == request.name)
    if request.order_by:
        query.sort(request.order_by)
    users = await query.to_list()
    return users

@router.delete("/{user_id}/", status_code=status.HTTP_204_NO_CONTENT)
async def delete(
    user_id: UUID4,
):
    res = await UserModel.find(UserModel.id == user_id).delete()
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="User not found")
