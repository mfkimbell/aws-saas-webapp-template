import os
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
# from saas_backend.auth.router import router as auth_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("app")

_ = load_dotenv()

app = FastAPI()

# app.include_router(auth_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check():
    logger.info("Health endpoint hit")
    return {"message": "OK"}

@app.get("/secrets")
def get_secrets():
    # Fetch a variable from the environment
    secret_value = os.getenv("TEST_SECRET", "Secret not found")
    return {"secret_value": secret_value}