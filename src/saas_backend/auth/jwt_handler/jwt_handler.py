from datetime import timedelta
from typing import Any
from datetime import datetime, timezone
import jwt
from saas_backend.auth.constants import ACCESS_TOKEN_EXPIRE_MINUTES, ALGORITHM, get_secret
from saas_backend.auth.database import get_db
from saas_backend.auth.models import Blacklist
from fastapi import HTTPException
from saas_backend.logger import LOG
import uuid


class JwtHandler:
    def __init__(self):
        pass

    @staticmethod
    def decode(token: str) -> dict[str, Any]:
        try:
            decoded = jwt.decode(token, get_secret(), algorithms=[ALGORITHM])
            return decoded

        except jwt.exceptions.ExpiredSignatureError as e:
            LOG.warning(f"Error: {e}")
            raise HTTPException(
                status_code=401,
                detail="Token expired",
                headers={"expired": "true"},
            ) from e

        except jwt.exceptions.InvalidTokenError as e:
            LOG.warning(f"Error: {e}")
            raise HTTPException(
                status_code=401,
                detail="Invalid token",
            ) from e


    @staticmethod
    def create_access_token(data: dict[str, Any], expires_delta: timedelta | None = None) -> str:
        now = datetime.now(timezone.utc)  # Ensure UTC consistency
        expire = now + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))

        LOG.info(f"🔑 Creating token for user: {data.get('username')}")
        LOG.info(f"🕒 Expiration: {expire} (UTC), Expires in: {expire - now} seconds")

        jti = str(uuid.uuid4())  # Generate a unique token ID
        to_encode = {**data, "exp": expire, "jti": jti}

        encoded_jwt = jwt.encode(to_encode, get_secret(), algorithm=ALGORITHM)

        LOG.info(f"✅ Token successfully created for User ID {data.get('id')}")
        LOG.info(f"🆔 JWT ID (jti): {jti}, Expiration time: {expire} (Epoch: {expire.timestamp()})")

        return encoded_jwt

    @staticmethod
    def expire_token(jti: str):
        db = next(get_db())
        _ = (
            db.query(Blacklist)
            .filter(Blacklist.jti == jti)
            .update({"expires_at": datetime.now()})
        )

        db.commit()

    @staticmethod
    def blacklist_token(jti: str, expires_at: datetime):
        db = next(get_db())
        _ = (
            db.query(Blacklist)
            .filter(Blacklist.jti == jti)
            .update({"expires_at": expires_at})
        )

        db.commit()

    @staticmethod
    def remove_token(jti: str):
        db = next(get_db())
        _ = db.query(Blacklist).filter(Blacklist.jti == jti).delete()
        db.commit()

    @staticmethod
    def is_expired(jti: str):
        db = next(get_db())
        blacklist = db.query(Blacklist).filter(Blacklist.jti == jti).first()

        if blacklist is None:
            return False

        if blacklist.expires_at < datetime.now():
            return False

        raise HTTPException(
            status_code=401,
            detail="Token expired",
            headers={"expired": "true"},
        )
