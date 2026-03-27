# Primus Inter Pares 2026 — Dokumentacja Techniczna Backend

> **Ogólnopolskie Zawody Techniczne Primus Inter Pares 2026**
> Temat: Magazyn — Zadanie FINAŁOWE (ETAP 3)

---

## 1. Przegląd backendu

Backend systemu Primus to aplikacja **FastAPI** (Python 3.11) uruchamiana przez **Uvicorn**, z asynchronicznym dostępem do bazy danych przez **SQLAlchemy (asyncpg)** i systemem zadań w tle opartym na **Celery + Redis**.

**Repozytorium**: `primus-backend/`

---

## 2. Struktura katalogów

```
primus-backend/
├── app/
│   ├── main.py                   # Punkt wejścia FastAPI
│   ├── api/
│   │   └── v1/
│   │       ├── api.py            # Rejestracja routerów
│   │       └── endpoints/        # Kontrolery (endpointy REST)
│   │           ├── auth.py
│   │           ├── users.py
│   │           ├── rack_CRUD.py
│   │           ├── product_definition_CRUD.py
│   │           ├── stock.py
│   │           ├── stock_inbound.py
│   │           ├── stock_outbound.py
│   │           ├── reports.py
│   │           ├── backups.py
│   │           ├── alerts.py
│   │           ├── ai.py
│   │           ├── voice.py
│   │           ├── camera.py
│   │           ├── gcode.py
│   │           ├── joystick.py
│   │           ├── qr_generator.py
│   │           ├── inventory.py
│   │           ├── chess.py
│   │           └── ttt.py
│   ├── services/                 # Logika biznesowa
│   │   ├── auth_service.py
│   │   ├── user_service.py
│   │   ├── rack_service.py
│   │   ├── product_definition_service.py
│   │   ├── stock_service.py
│   │   ├── allocation_service.py
│   │   ├── report_service.py
│   │   ├── report_storage.py
│   │   ├── backup_service.py
│   │   ├── alert_service.py
│   │   ├── ai_service.py
│   │   ├── voice_service.py
│   │   ├── camera_service.py
│   │   ├── gcode_service.py
│   │   ├── joystick_service.py
│   │   ├── inventory_service.py
│   │   ├── chess_service.py
│   │   ├── tic_tac_toe_service.py
│   │   ├── weight_service.py
│   │   └── product_stats_service.py
│   ├── database/
│   │   ├── session.py            # Async SessionLocal
│   │   ├── init_db.py            # Inicjalizacja bazy
│   │   └── models/               # Modele SQLAlchemy
│   │       ├── user.py
│   │       ├── rack.py
│   │       ├── product_definition.py
│   │       ├── stock_item.py
│   │       ├── alert.py
│   │       ├── product_stats.py
│   │       └── base.py
│   ├── schemas/                  # Pydantic (walidacja I/O)
│   │   ├── auth.py
│   │   ├── user.py
│   │   ├── rack.py
│   │   ├── product_definition.py
│   │   ├── stock.py
│   │   ├── allocation.py
│   │   ├── report.py
│   │   ├── alert.py
│   │   ├── gcode.py
│   │   └── ai.py
│   ├── core/
│   │   ├── config.py             # Konfiguracja (env vars)
│   │   ├── security.py           # JWT, hashowanie
│   │   ├── deps.py               # Zależności (DI)
│   │   ├── celery_worker.py      # Konfiguracja Celery
│   │   ├── redis_client.py       # Klient Redis
│   │   └── storage/              # Adapter MinIO/S3
│   └── tasks/                    # Zadania Celery
│       ├── backup_tasks.py
│       ├── report_tasks.py
│       ├── csv_import.py
│       ├── ai_tasks.py
│       ├── product_definition_tasks.py
│       └── product_stats_tasks.py
├── alembic/                      # Migracje bazy danych
├── tests/                        # Testy
├── scripts/                      # Skrypty pomocnicze
├── Dockerfile                    # Multi-stage build
└── pyproject.toml                # Poetry config
```

---

## 3. Endpointy API (`/api/v1`)

### 3.1 Autentykacja i użytkownicy

| Metoda | Endpoint | Opis | Rola |
|---|---|---|---|
| `POST` | `/auth/login` | Logowanie (JWT) | Wszyscy |
| `POST` | `/auth/register` | Rejestracja | Wszyscy |
| `GET` | `/auth/me` | Dane zalogowanego użytkownika | Zalogowany |
| `GET` | `/users/` | Lista użytkowników | Administrator |
| `PUT` | `/users/{id}` | Edycja użytkownika | Administrator |
| `DELETE` | `/users/{id}` | Usunięcie użytkownika | Administrator |
<!-- TODO: Uzupełnić pełną listę endpointów auth/users -->

### 3.2 Zarządzanie regałami

| Metoda | Endpoint | Opis |
|---|---|---|
| `GET` | `/racks/` | Lista regałów |
| `POST` | `/racks/` | Dodanie regału (MxN, temp, waga, wymiary) |
| `PUT` | `/racks/{id}` | Edycja regału |
| `DELETE` | `/racks/{id}` | Usunięcie regału |
- **Format CSV**: Półka;M;N;TempMin;TempMax;MaxWagaKg;MaxSzerokoscMm;MaxWysokoscMm;MaxGlebokoscMm;Komentarz
- **Walidacja**: System sprawdza, czy nowe parametry nie kolidują z produktami aktualnie znajdującymi się na regale.

### 3.4 Operacje magazynowe

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/stock-inbound/scan` | Przyjęcie towaru (skan QR/barcode) |
| `POST` | `/stock-outbound/scan` | Wydanie towaru (FIFO) |
| `GET` | `/stock/` | Stan magazynu |
**Algorytm alokacji (A-B-C Strategy)**:
1. Filtrowanie regałów po wymaganiach fizycznych (temp, wymiary, waga).
2. Sprawdzenie możliwości składowania (stacking) — jeśli ten sam produkt jest już w slocie na poziomie 0, system sugeruje poziom 1.
3. Sortowanie według klasy rotacji (`FrequencyClass`):
   - **Klasa A (High)**: Stackerowanie, potem najbliżej wejścia (Inbound).
   - **Klasa B (Medium)**: Stackerowanie, potem środkowa strefa.
   - **Klasa C (Low)**: Stackerowanie, potem najdalsze zakątki magazynu.

### 3.5 Raporty

| Metoda | Endpoint | Opis |
|---|---|---|
| `GET` | `/reports/` | Lista raportów |
| `POST` | `/reports/generate/{type}` | Generowanie raportu (PDF) |
| `GET` | `/reports/download/{id}` | Pobranie raportu |

**Typy raportów**:
- Asortyment ze zbliżającą się datą ważności
- Przekroczone zakresy temperatur
- Pełna inwentaryzacja

### 3.6 Backupy

| Metoda | Endpoint | Opis |
|---|---|---|
| `GET` | `/backups/` | Lista backupów |
| `POST` | `/backups/create` | Ręczne tworzenie backupu |
| `POST` | `/backups/restore/{id}` | Przywrócenie stanu |

- Automatyczne backupy: Celery Beat (domyślnie: 03:00)
- Szyfrowanie: Fernet (AES-128-CBC)

### 3.7 Alerty i monitorowanie

| Metoda | Endpoint | Opis |
|---|---|---|
| `GET` | `/alerts/` | Lista alertów |
| `PUT` | `/alerts/{id}/dismiss` | Odrzucenie alertu |

**Typy alertów**: zbliżająca data ważności, przekroczona data ważności, anomalia wagi regału

### 3.8 Sterowanie drukarką 3D (G-code)

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/gcode/connect` | Połączenie z COM |
| `POST` | `/gcode/disconnect` | Rozłączenie |
| `POST` | `/gcode/send` | Wysłanie komendy G-code |
| `POST` | `/gcode/home` | Homing (G28) |
| `POST` | `/gcode/move` | Ruch do pozycji (G0/G1) |
| `POST` | `/gcode/magnet/on` | Włączenie elektromagnesu |
| `POST` | `/gcode/magnet/off` | Wyłączenie elektromagnesu |
| `POST` | `/gcode/pick` | Pobranie obiektu |
| `POST` | `/gcode/place` | Odłożenie obiektu |
**Limity bezpieczeństwa**:
- X: `[0.0, 280.0]`, Y: `[0.0, 280.0]`, Z: `[0.0, 50.0]`
- Prędkość: XY: `3000 mm/min`, Z: `1000 mm/min`
- Wysokość bezpieczna (Z_SAFE): `14.0 mm`
- Poziomy chwytania: Dno: `0.0 mm`, Stack: `4.2 mm`

### 3.9 Kamera inspekcyjna

| Metoda | Endpoint | Opis |
|---|---|---|
| `GET` | `/camera/snapshot` | Pobranie zdjęcia z kamery |
| `POST` | `/camera/scan-qr` | Skanowanie kodu QR |
<!-- TODO: Opisać rozpoznawanie piktogramów -->

### 3.10 Joystick ESP32S3

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/joystick/move` | Ruch joystickiem |
| `GET` | `/joystick/status` | Status joysticka |
- **Tryb WebSocket**: Wysoka wydajność (fire-and-forget) dla płynnego sterowania (jogging).
- **Protokół**: JSON przez WS na porcie 8000.

### 3.11 Generator QR

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/qr_generator/generate` | Generowanie kodu QR (PNG) |

### 3.12 Szachy

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/chess/setup` | Rozstawienie figur szachowych |
| `GET` | `/chess/status` | Status rozstawienia |
- **Sekwencja**: Skanowanie planszy (inventory) -> Obliczenie brakujących figur -> Pobieranie z magazynu -> Rozstawianie na docelowych polach.
- **Weryfikacja**: Każdy ruch potwierdzany wizualnie przez kamerę.

### 3.13 Kółko i krzyżyk

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/ttt/new` | Nowa gra |
| `POST` | `/ttt/move` | Wykonanie ruchu |
| `GET` | `/ttt/state` | Stan gry |
- **Algorytm**: Proces decyzyjny SI oparty o model LLM **Qwen** (serwowany przez Ollama), analizujący stan planszy i zwracający ruch w formacie JSON.

### 3.14 Inwentaryzacja automatyczna

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/inventory/start` | Uruchomienie inwentaryzacji |
| `GET` | `/inventory/status` | Status inwentaryzacji |
| `GET` | `/inventory/report` | Raport rozbieżności |

### 3.15 AI / Rozpoznawanie

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/ai/recognize` | Rozpoznawanie obiektu (kamera) |
| `POST` | `/ai/train` | Rozpoczęcie treningu modelu |
| `GET` | `/ai/models` | Lista modeli |

### 3.16 Asystent głosowy

| Metoda | Endpoint | Opis |
|---|---|---|
| `POST` | `/voice-command/process` | Przetwarzanie komendy głosowej |

- Provider: Ollama (domyślne) lub OpenAI
- Model: `qwen3:4b`
- **Komendy**: `Dodaj [Produkt]`, `Wydaj [Produkt]`, `Wygeneruj raport [Typ]`, `Sprawdź stan [Półka]`.
- **Flow**: Mowa -> STT (Frontend) -> Intent Extraction (LLM) -> Action Execution.

---

## 4. Modele bazy danych

### 4.1 Model User
| Pole | Typ | Opis |
|---|---|---|
| id | UUID | Klucz główny |
| login | String | Login użytkownika |
| email | String | Adres email |
| hashed_password | String | Hash hasła (Argon2) |
| role | Enum | `admin` / `worker` |
| totp_secret | String | Sekret 2FA (opcjonalnie) |
| is_active | Boolean | Czy konto aktywne |
<!-- TODO: Pełna dokumentacja pól -->

### 4.2 Model Rack
| Pole | Typ | Opis |
|---|---|---|
| id | UUID | Klucz główny |
| label | String | Oznaczenie regału |
| rows (M) | Integer | Liczba wierszy |
| columns (N) | Integer | Liczba kolumn |
| temp_min / temp_max | Float | Zakres temperatur [°C] |
| max_weight | Float | Maks. waga [kg] |
| max_size_x/y/z | Float | Maks. wymiary [mm] |
| comment | Text | Komentarz |

### 4.3 Model ProductDefinition
| Pole | Typ | Opis |
|---|---|---|
| id | UUID | Klucz główny |
| name | String | Nazwa asortymentu |
| identifier | String | Kod QR / kreskowy |
| image_url | String | URL zdjęcia (MinIO) |
| temp_min / temp_max | Float | Zakres temperatur [°C] |
| weight | Float | Waga [kg] |
| size_x/y/z | Float | Wymiary [mm] |
| comment | Text | Komentarz |
| expiry_days | Integer | Termin ważności [dni] |
| is_hazardous | Boolean | Materiał niebezpieczny |

### 4.4 Model StockItem
| Pole | Typ | Opis |
|---|---|---|
| id | UUID | Klucz główny |
| product_definition_id | FK | Relacja do produktu |
| rack_id | FK | Relacja do regału |
| slot_row / slot_col | Integer | Pozycja w regale |
| received_at | DateTime | Data przyjęcia |
| received_by | FK | Użytkownik przyjmujący |
| expires_at | DateTime | Data ważności |
| removed_at | DateTime | Data wydania (null = na stanie) |

### 4.5 Model Alert
<!-- TODO: Pełna dokumentacja modelu alertów -->

### 4.6 Model ProductStats
<!-- TODO: Dokumentacja statystyk produktów -->

---

## 5. Zadania Celery (Background Tasks)

| Zadanie | Moduł | Harmonogram |
|---|---|---|
| Generowanie raportów | `report_tasks.py` | Codziennie (konfigurowalny) |
| Tworzenie backupów | `backup_tasks.py` | Codziennie o 03:00 |
| Import CSV | `csv_import.py` | Na żądanie |
| Rozpoznawanie AI | `ai_tasks.py` | Na żądanie |
| Aktualizacja statystyk | `product_stats_tasks.py` | Okresowo |
| Import definicji produktów | `product_definition_tasks.py` | Na żądanie |

---

## 6. Komunikacja MQTT (IoT)

### 6.1 Czujniki wagi
- **Topic**: `warehouse/rack/{rack_id}/weight`
- **Flow**: Czujnik → Mosquitto → mqtt-listener → Redis cache → Backend API
- **Cel**: Monitorowanie nieautoryzowanego pobrania towaru

### 6.2 Mock Sensor
- Streamlit UI do symulowania odczytów wagi
- Dostępny na porcie 8501
<!-- TODO: Opisać pełny flow MQTT -->

---

## 7. Storage (MinIO)

| Bucket | Zawartość |
|---|---|
| `product-images` | Zdjęcia asortymentu (public read) |
| `reports` | Wygenerowane raporty PDF |
| `datasets` | Datasety dla AI |
| `models` | Wytrenowane modele YOLO |
| `backups` | Szyfrowane backupy bazy |

---

## 8. Konfiguracja środowiskowa

Pełna konfiguracja odbywa się przez zmienne środowiskowe (plik `.env`). Kluczowe zmienne:

| `DATABASE_URL` | URL PostgreSQL | `postgresql+asyncpg://...` |
| `SECRET_KEY` | Klucz JWT | (zmienić w produkcji!) |
| `SERIAL_PORT` | Port COM drukarki | `/dev/ttyUSB0` |
| `SERIAL_BAUDRATE` | Baudrate COM | `250000` |
| `CAMERA_INDEX` | Index kamery USB | `0` |
| `ESP_IP` | Adres IP ESP32S3 | `192.168.1.100` |
| `REDIS_URL` | URL bazy Redis | `redis://redis:6379/0` |
| `MINIO_ENDPOINT` | Endpoint MinIO | `minio:9000` |
| `VOICE_LLM_PROVIDER` | Provider LLM | `ollama` |
| `BACKUP_ENCRYPTION_KEY` | Klucz szyfrowania backupów | (wygenerowany) |

---

## 9. Uruchomienie deweloperskie

```bash
# Wymagane: Python 3.11+, Poetry
cd primus-backend
poetry install

# Uruchomienie serwera (dev)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Uruchomienie workera Celery
celery -A app.core.celery_worker.celery_app worker -l info -c 4 --beat
```

**Dokumentacja API (Swagger)**: `http://localhost:8000/docs` (tylko w trybie dev)

---

> **Dokument**: 02 — Dokumentacja Techniczna Backend
> **Ostatnia aktualizacja**: <!-- TODO: Data -->
> **Autorzy**: Drużyna Primus
