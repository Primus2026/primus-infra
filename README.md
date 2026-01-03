# Primus 2026 Infrastructure

This directory handles the orchestration of the entire Primus System.

## Services
- **backend**: FastAPI application.
- **frontend**: React application.
- **db**: PostgreSQL database (Port 5432).
- **mqtt**: Mosquitto Broker (Port 1883).
- **mock-sensor**: Python script simulating IoT devices.

## Usage

### Prerequisites
1.  **Docker** and **Docker Compose** installed.
2.  Configuration file:
    ```bash
    cp .env.example .env  # Or create .env manually
    ```
    > **Note**: A `.env` file or exported environment variables are **required**. See `.env.example` (or the `docker-compose.yml` keys) for reference.

### Running the System
To start all services (Backend, Frontend, Postgres, Redis, Mosquitto, Mock Sensor):

```bash
cd primus-infra
docker compose up --build
```

- **Backend**: [http://localhost:8000](http://localhost:8000)
- **Frontend**: [http://localhost:5173](http://localhost:5173)
- **Mosquitto Dashboard**: [http://localhost:1883](http://localhost:1883) (MQTT)

### Shutdown
```bash
docker compose down
```
