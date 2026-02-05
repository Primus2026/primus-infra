# Infrastruktura Primus 2026

Ten katalog odpowiada za orkiestrację całego Systemu Primus.

## Przegląd Usług

| Usługa | Opis | Port |
| :--- | :--- | :--- |
| **backend** | Aplikacja FastAPI (Logika Biznesowa) | `8000` |
| **frontend** | Aplikacja React (Interfejs Webowy) | `5173` |
| **db** | Baza danych PostgreSQL | `5432` |
| **mqtt** | Broker Mosquitto | `1883` |
| **worker** | Celery Worker (Zadania w tle) | - |
| **ollama** | Serwer Modelu AI (Qwen3 4B) | `11434` |
| **mqtt-listener** | Pobiera dane z czujników MQTT | - |
| **mock-sensor** | Symulator urządzeń IoT | - |

## Jak zacząć

### 1. Wymagania wstępne
- Zainstalowany **Docker** i **Docker Compose**.
- **Konfiguracja**: Utwórz plik `.env`.
    ```bash
    cp .env.example .env
    ```

### 2. Wybierz swoją konfigurację
Wybierz przewodnik pasujący do Twojego sprzętu:
- [🟢 Konfiguracja NVIDIA](#-konfiguracja-nvidia) - Dla systemów z kartami NVIDIA.
- [🔴 Konfiguracja AMD](#-konfiguracja-amd) - Dla systemów z kartami AMD (Tryb Natywny lub Hybrydowy).
- [🔵 Konfiguracja Standardowa](#-konfiguracja-standardowa-bez-gpu) - Dla środowisk bez GPU / tylko CPU.

### 3. Dostęp do aplikacji
- **API Backend**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **Frontend UI**: [http://localhost:5173](http://localhost:5173)

### 4. Wyłączanie
```bash
docker compose down
```

---

## 🟢 Konfiguracja NVIDIA

### 1. Instalacja
**Użytkownicy Linux / WSL2:**
Musisz zainstalować **NVIDIA Container Toolkit**, aby Docker miał dostęp do Twojej karty graficznej.

```bash
# 1. Konfiguracja repozytorium
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 2. Instalacja
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit

# 3. Konfiguracja Dockera
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### 2. Uruchamianie
Użyj dedykowanej konfiguracji NVIDIA:
```bash
docker compose -f docker-compose-nvidia.yml up --build
```

---

## 🔴 Konfiguracja AMD

### Opcja A: Tryb Hybrydowy (Zalecany dla WSL2)
Opcja dla Windows/WSL2.
1.  **Zainstaluj**: Pobierz [Ollama dla Windows](https://ollama.com/download/windows).
2.  **Uruchom**: Otwórz terminal w Windows i wpisz`$env:OLLAMA_VULKAN="1"` i `ollama serve`.
3.  **Skonfiguruj**: Edytuj plik `primus-infra/.env`:
    ```bash
    VOICE_LLM_PROVIDER=ollama
    OLLAMA_URL=http://host.docker.internal:11434/api/generate
    ```
4.  **Uruchomienie**: Użyj standardowej konfiguracji dla CPU (Docker obsługuje logikę, Windows obsługuje AI).
    ```bash
    docker compose up --build
    ```

### Opcja B: Tryb Natywny (Linux)
Użyj tej opcji tylko, jeśli masz natywne wsparcie ROCm (wymaga obecności `/dev/kfd`).

1.  **Instalacja**:
    - Zainstaluj odpowiednie sterowniki AMD
    - Komenda `rocminfo` musi wyświetlić Twoją kartę graficzną.

2.  **Uruchamianie**:
    ```bash
    docker compose -f docker-compose-amd.yml up --build
    ```

---

## 🔵 Konfiguracja Standardowa (Bez GPU)
Do testowania na urządzeniach bez dedykowanego sprzętu AI, lub z zewnętrznym serwisem do obsługi LLM.
1.  **Skonfiguruj**: Ustaw zewnętrzne LLM w `.env` (np. klucz OpenAI).
2.  **Uruchom**:
    ```bash
    docker compose up --build
    ```
