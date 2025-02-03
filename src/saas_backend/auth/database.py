from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy import create_engine
from collections.abc import Generator
import os

from dotenv import load_dotenv

_ = load_dotenv()


database_env_value = os.getenv("DATABASE_URL")

if not database_env_value:
    print("⚠️ DATABASE_URL is missing or empty! Using default SQLite database.")
    DATABASE_URL = "sqlite:///./test.db"
else:
    DATABASE_URL = database_env_value

engine = create_engine(
    DATABASE_URL,
    pool_size=10,
    max_overflow=20,
    pool_timeout=30,
    pool_recycle=1800,
)

Base = declarative_base()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
