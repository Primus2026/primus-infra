# Primus 2026 Infrastructure

This directory handles the orchestration of the entire Primus System.

## Services
- **backend**: FastAPI application.
- **frontend**: React application.
- **db**: PostgreSQL database (Port 5432).
- **mqtt**: Mosquitto Broker (Port 1883).
- **mock-sensor**: Python script simulating IoT devices.

## Usage
To start the entire system:
```bash
docker-compose up --build
```
