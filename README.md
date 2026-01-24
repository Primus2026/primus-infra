# Primus 2026 Infrastructure

This directory handles the orchestration of the entire Primus System.

## Services
- **backend**: FastAPI application.
- **frontend**: React application.
- **db**: PostgreSQL database (Port 5432).
- **mqtt**: Mosquitto Broker (Port 1883).
- **mqtt-listener**: Service ingesting sensor data.
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
Nvidia gpu support:
```bash
cd primus-infra
docker compose -f docker-compose-gpu.yml up --build
```



- **Backend**: [http://localhost:8000](http://localhost:8000)
- **Frontend**: [http://localhost:5173](http://localhost:5173)

### Shutdown
```bash
docker compose down
```

### GPU Support Setup
If you need to run the worker with GPU support (using `docker-compose-gpu.yml`), you must install the NVIDIA Container Toolkit.

#### Linux (Ubuntu/Debian)


**1. Configure the repository**
```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

**2. Install the toolkit**
```bash
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

**3. Configure Docker**
```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

#### Windows (WSL2)
1.  **Windows Host**: Install the latest [NVIDIA Drivers](https://www.nvidia.com/Download/index.aspx) on Windows. Do **not** install drivers inside WSL2.
2.  **WSL2**: Ensure you are running WSL2 (`wsl --install`).
3.  **Docker Desktop Users**: Enable the WSL2 backend in Docker Desktop settings. GPU support should work out of the box.
4.  **Native Docker in WSL2**: If you installed Docker Engine directly inside WSL2 (without Docker Desktop):
    *   Open your WSL2 terminal.
    *   Run the **Host Configuration** and **Installation** commands listed in the **Linux** section above.
    *   Configure the runtime as shown above.
