import os

# defaults to prod if APP_MODE is not set
APP_MODE = os.environ.get("APP_MODE", "prod")
