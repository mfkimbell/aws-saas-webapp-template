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

# Help
help:
	@echo "Available commands:"
	@echo "  make install   - Install dependencies"
	@echo "  make dev       - Start the development server"
	@echo "  make build     - Build the app for production"
	@echo "  make start     - Start the production server"
	@echo "  make lint      - Run linting"