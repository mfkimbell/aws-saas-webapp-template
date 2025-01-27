# Variables
FRONTEND_DIR=./frontend

# Targets
install:
	cd $(FRONTEND_DIR) && npm install

dev:
	cd $(FRONTEND_DIR) && npm run dev

build:
	cd $(FRONTEND_DIR) && npm run build

start:
	cd $(FRONTEND_DIR) && npm run start

lint:
	cd $(FRONTEND_DIR) && npm run lint

lapi:
	pdm run python -m uvicorn src.saas_backend.app:app --reload --host 0.0.0.0 --port 8000

# Help
help:
	@echo "Available commands:"
	@echo "  make install   - Install dependencies"
	@echo "  make dev       - Start the development server"
	@echo "  make build     - Build the app for production"
	@echo "  make start     - Start the production server"
	@echo "  make lint      - Run linting"