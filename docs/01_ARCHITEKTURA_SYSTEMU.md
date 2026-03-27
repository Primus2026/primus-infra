# Primus Inter Pares 2026 — Architektura Systemu

## 1. Architektura ogólna
```mermaid
graph TB
    subgraph Klienci
        FE["React SPA<br/>(TypeScript + Vite)"]
        MOB["Aplikacja mobilna"]
        ESP["ESP32S3 Joystick<br/>(WiFi)"]
    end

    subgraph Reverse_Proxy["Reverse Proxy"]
        NGINX["Nginx Alpine<br/>:8080 HTTP / :8443 HTTPS"]
    end

    subgraph Backend["Backend Services"]
        API["FastAPI<br/>(Uvicorn :8000)"]
        WORKER["Celery Worker<br/>+ Beat Scheduler"]
    end

    subgraph Data["Bazy danych i Cache"]
        PG[("PostgreSQL 15")]
        REDIS[("Redis TLS")]
    end

    subgraph Storage["Object Storage"]
        MINIO[("MinIO S3<br/>:9000")]
    end

    subgraph IoT["IoT / MQTT"]
        MQTT["Mosquitto<br/>TLS :8883"]
        LISTENER["MQTT Listener"]
        MOCK["Mock Sensor<br/>(Streamlit :8501)"]
    end

    subgraph Hardware["Fizyczny magazyn"]
        PRINTER["Drukarka 3D<br/>(COM / G-code)"]
        MAGNET["Elektromagnes<br/>(hotend pin)"]
        CAM["Kamera USB<br/>(inspekcyjna)"]
    end

    FE -->|"HTTPS :8443"| NGINX
    MOB -->|"HTTPS :8443"| NGINX
    ESP -->|"WebSocket / HTTP"| API

    NGINX -->|"proxy_pass"| API
    NGINX -->|"static files"| FE

    API --> PG
    API --> REDIS
    API --> MINIO
    API -->|"pyserial COM"| PRINTER
    API -->|"OpenCV"| CAM

    WORKER --> PG
    WORKER --> REDIS
    WORKER --> MINIO

    LISTENER --> MQTT
    LISTENER --> REDIS
    LISTENER -->|"REST API"| NGINX

    MOCK -->|"publish"| MQTT

    PRINTER --- MAGNET

    style FE fill:#3b82f6,color:#fff;
    style API fill:#10b981,color:#fff;
    style WORKER fill:#10b981,color:#fff;
    style PG fill:#6366f1,color:#fff;
    style REDIS fill:#ef4444,color:#fff;
    style MINIO fill:#f59e0b,color:#000;
    style NGINX fill:#64748b,color:#fff;
    style MQTT fill:#8b5cf6,color:#fff;
    style PRINTER fill:#f97316,color:#fff;
    style MAGNET fill:#f97316,color:#fff;
    style CAM fill:#f97316,color:#fff;
```

---

## 2. Repozytoria projektu
```mermaid
graph LR
    subgraph Repozytoria
        BE["primus-backend<br/>Python 3.11 / FastAPI"]
        FE["primus-web-frontend<br/>React 19 / TypeScript"]
        INFRA["primus-infra<br/>Docker Compose / Nginx"]
        MQTT_L["primus-mqtt-listener<br/>Python"]
        MOCK_S["primus-mock-sensor<br/>Python / Streamlit"]
        MOBILE["primus-mobile"]
    end

    INFRA -->|"buduje"| BE
    INFRA -->|"buduje"| FE
    INFRA -->|"image"| MQTT_L
    INFRA -->|"image"| MOCK_S

    style BE fill:#10b981,color:#fff;
    style FE fill:#3b82f6,color:#fff;
    style INFRA fill:#64748b,color:#fff;
    style MQTT_L fill:#8b5cf6,color:#fff;
    style MOCK_S fill:#8b5cf6,color:#fff;
    style MOBILE fill:#a3a3a3,color:#fff;
```

---

## 3. Stos technologiczny

### 3.1 Backend
```mermaid
graph LR
    subgraph Backend_Stack["Backend Stack"]
        direction TB
        FAST["FastAPI ^0.109"]
        SQL["SQLAlchemy ^2.0 (async)"]
        ALEM["Alembic ^1.17"]
        CEL["Celery ^5.6"]
        PG2["PostgreSQL 15 (asyncpg)"]
        RED["Redis TLS"]
        MIN["MinIO (S3)"]
    end

    subgraph Auth_Stack["Autentykacja"]
        JWT["JWT (python-jose)<br/>HS256"]
        ARG["Argon2 (hasla)"]
        TOTP["PyOTP (2FA)"]
    end

    subgraph Hardware_Stack["Sprzet"]
        SER["pyserial ^3.5<br/>(G-code COM)"]
        CV["OpenCV ^4.10<br/>(kamera)"]
        PZ["pyzbar (QR)"]
        YOLO["YOLO Ultralytics<br/>(piktogramy)"]
    end

    subgraph Utils["Narzedzia"]
        RL["ReportLab (PDF)"]
        QR["qrcode (generator)"]
    end

    style FAST fill:#10b981,color:#fff;
    style SQL fill:#6366f1,color:#fff;
    style CEL fill:#ef4444,color:#fff;
    style JWT fill:#f59e0b,color:#000;
    style SER fill:#f97316,color:#fff;
    style CV fill:#f97316,color:#fff;
    style YOLO fill:#f97316,color:#fff;
```

### 3.2 Frontend
```mermaid
graph LR
    subgraph Frontend_Stack["Frontend Stack"]
        direction TB
        REACT["React ^19.2"]
        TS["TypeScript ~5.9"]
        VITE["Vite ^7.2"]
        TW["Tailwind CSS ^4.1"]
    end

    subgraph UI_Components["UI i Formularze"]
        RADIX["Radix UI Primitives"]
        CVA["class-variance-authority"]
        LUCIDE["Lucide React (ikony)"]
        RHF["React Hook Form ^7.70"]
        ZOD["Zod ^4.3 (walidacja)"]
    end

    subgraph Data_Layer["Warstwa danych"]
        RQ["TanStack React Query ^5.90"]
        AXIOS["Axios ^1.13"]
        RR["React Router DOM ^7.12"]
    end

    subgraph Notifications["Powiadomienia"]
        TOAST["React Toastify ^11.0"]
        QRCODE["react-qr-code ^2.0"]
    end

    style REACT fill:#3b82f6,color:#fff;
    style TS fill:#3178c6,color:#fff;
    style VITE fill:#646cff,color:#fff;
    style TW fill:#06b6d4,color:#fff;
    style RQ fill:#ef4444,color:#fff;
```

---

## 4. Serwisy Docker Compose
```mermaid
graph TB
    IC["init-certs<br/>(generowanie TLS)"]

    subgraph Core["Aplikacja"]
        BE["backend<br/>FastAPI :8000"]
        FE["frontend<br/>(SPA build)"]
        W["worker<br/>Celery + Beat"]
        NG["nginx<br/>:8080 / :8443"]
    end

    subgraph Databases["Bazy danych"]
        PG[("postgres<br/>:5432")]
        RED[("redis TLS<br/>:6379")]
    end

    subgraph Storage_Layer["Storage"]
        MIN[("minio<br/>:9000 / :9001")]
        CB["createbuckets<br/>(init job)"]
    end

    subgraph IoT_Layer["IoT"]
        MQ["mosquitto<br/>:8883 TLS"]
        MS["mock-sensor<br/>Streamlit :8501"]
        ML["mqtt-listener"]
    end

    IC -.->|"certyfikaty"| RED
    IC -.->|"certyfikaty"| MQ
    IC -.->|"certyfikaty"| BE
    IC -.->|"certyfikaty"| W
    IC -.->|"certyfikaty"| NG

    PG --> BE
    RED --> BE
    RED --> W
    MIN --> BE
    MIN --> W
    PG --> W
    MQ --> ML

    CB -.->|"init"| MIN

    BE --> NG
    FE --> NG

    MS -->|"publish weight"| MQ
    ML --> RED

    style IC fill:#a3a3a3,color:#fff;
    style BE fill:#10b981,color:#fff;
    style FE fill:#3b82f6,color:#fff;
    style W fill:#10b981,color:#fff;
    style NG fill:#64748b,color:#fff;
    style PG fill:#6366f1,color:#fff;
    style RED fill:#ef4444,color:#fff;
    style MIN fill:#f59e0b,color:#000;
    style MQ fill:#8b5cf6,color:#fff;
    style MS fill:#8b5cf6,color:#fff;
    style ML fill:#8b5cf6,color:#fff;
    style CB fill:#a3a3a3,color:#fff;
```

---

## 5. Bezpieczeństwo
```mermaid
graph TB
    subgraph TLS_Layer["Szyfrowanie komunikacji"]
        HTTPS["HTTPS :8443<br/>(Nginx termination)"]
        REDIS_TLS["Redis TLS<br/>(rediss://)"]
        MQTT_TLS["MQTT TLS :8883"]
        CERTS["Self-signed Root CA<br/>(init-certs auto-gen)"]
    end

    subgraph Auth_Layer["Uwierzytelnianie"]
        JWT["JWT Token<br/>HS256 / 30 min"]
        ARGON["Argon2 hash<br/>(hasla)"]
        TOTP2FA["TOTP 2FA<br/>(PyOTP)"]
    end

    subgraph Roles["Role uzytkownikow"]
        ADMIN["Administrator<br/>- Zarzadzanie uzytkownikami<br/>- Definicja magazynu<br/>- Backupy, AI"]
        WORKER_ROLE["Uzytkownik Magazynu<br/>- Operacje magazynowe<br/>- Raporty<br/>- Zmiana hasla"]
    end

    subgraph Backup_Security["Backupy"]
        FERNET["Fernet / AES<br/>szyfrowanie"]
        MINIO_B[("MinIO<br/>bucket: backups")]
        CELERY_B["Celery Beat<br/>automatyczny harmonogram"]
    end

    CERTS --> HTTPS
    CERTS --> REDIS_TLS
    CERTS --> MQTT_TLS

    JWT --> ADMIN
    JWT --> WORKER_ROLE

    FERNET --> MINIO_B
    CELERY_B --> FERNET

    style HTTPS fill:#10b981,color:#fff;
    style REDIS_TLS fill:#ef4444,color:#fff;
    style MQTT_TLS fill:#8b5cf6,color:#fff;
    style JWT fill:#f59e0b,color:#000;
    style ARGON fill:#f59e0b,color:#000;
    style ADMIN fill:#6366f1,color:#fff;
    style WORKER_ROLE fill:#3b82f6,color:#fff;
    style FERNET fill:#ef4444,color:#fff;
```

---

## 6. Integracja sprzetowa (ETAP FINALOWY)
```mermaid
graph LR
    subgraph Drukarka_3D["Drukarka 3D / Magazyn fizyczny"]
        COM["Port COM<br/>/dev/ttyUSB0<br/>250000 baud"]
        GCODE["Komendy G-code<br/>(Marlin firmware)"]
        ELECTRO["Elektromagnes<br/>(pin hotend M104/M109)"]
    end

    subgraph Kamera["Kamera inspekcyjna USB"]
        OPENCV["OpenCV<br/>(CAMERA_INDEX=0)"]
        PYZBAR["pyzbar<br/>(QR decoding)"]
        YOLO_HW["YOLO Ultralytics<br/>(rozpoznawanie piktogramow)"]
    end

    subgraph Joystick["ESP32S3 Matrix"]
        WIFI["WiFi HTTP/WS"]
        ESP_CONF["ESP_IP: 192.168.1.100"]
        LED["Matryca LED<br/>(wizualizacja pozycji)"]
    end

    subgraph Backend_Services["Serwisy Backend"]
        GS["gcode_service.py"]
        CS["camera_service.py"]
        JS["joystick_service.py"]
    end

    GS -->|"pyserial"| COM
    COM --> GCODE
    GCODE --> ELECTRO

    CS -->|"OpenCV"| OPENCV
    OPENCV --> PYZBAR
    OPENCV --> YOLO_HW

    JS -->|"HTTP/WS"| WIFI
    WIFI --> ESP_CONF
    ESP_CONF --> LED

    style COM fill:#f97316,color:#fff;
    style GCODE fill:#f97316,color:#fff;
    style ELECTRO fill:#f97316,color:#fff;
    style OPENCV fill:#06b6d4,color:#fff;
    style PYZBAR fill:#06b6d4,color:#fff;
    style YOLO_HW fill:#06b6d4,color:#fff;
    style WIFI fill:#8b5cf6,color:#fff;
    style GS fill:#10b981,color:#fff;
    style CS fill:#10b981,color:#fff;
    style JS fill:#10b981,color:#fff;
```

---

## 7. Przyjecie towaru (Inbound)
```mermaid
sequenceDiagram
    participant U as Uzytkownik
    participant FE as Frontend
    participant API as FastAPI
    participant ALLOC as AllocationService
    participant DB as PostgreSQL
    participant REDIS as Redis

    U->>FE: Skan kodu QR/barcode
    FE->>API: POST /stock-inbound/scan
    API->>DB: Znajdz ProductDefinition
    API->>ALLOC: Znajdz pasujacy regal
    ALLOC->>DB: Sprawdz temp, waga, wymiary, wolne sloty
    ALLOC-->>API: Regal + slot
    API->>DB: Utworz StockItem (data, uzytkownik)
    API->>REDIS: Aktualizuj cache wag
    API-->>FE: Sukces + info o regale
    FE-->>U: Komunikat: umieszczono w regale X, slot Y
```

---

## 8. Wydanie towaru (Outbound FIFO)
```mermaid
sequenceDiagram
    participant U as Uzytkownik
    participant FE as Frontend
    participant API as FastAPI
    participant DB as PostgreSQL

    U->>FE: Skan kodu QR/barcode
    FE->>API: POST /stock-outbound/scan
    API->>DB: Znajdz najstarszy StockItem (FIFO)
    API->>DB: Oznacz removed_at = teraz
    API-->>FE: Sukces + info o produkcie
    FE-->>U: Produkt wydany z regalu X
```

---

## 9. Fizyczny Pick and Place
```mermaid
sequenceDiagram
    participant API as FastAPI
    participant GS as GcodeService
    participant COM as Port COM
    participant PRINTER as Drukarka 3D
    participant MAG as Elektromagnes

    API->>GS: pick(x, y, z)
    GS->>COM: G0 X{x} Y{y} F3000
    COM->>PRINTER: Ruch do pozycji
    GS->>COM: G0 Z{z}
    COM->>PRINTER: Opuszczenie glowicy
    GS->>COM: M104 S200
    COM->>MAG: Wlacz elektromagnes
    GS->>COM: G0 Z{safe_z}
    COM->>PRINTER: Podniesienie z obiektem
    GS-->>API: OK

    API->>GS: place(x2, y2, z2)
    GS->>COM: G0 X{x2} Y{y2} F3000
    COM->>PRINTER: Ruch do celu
    GS->>COM: G0 Z{z2}
    COM->>PRINTER: Opuszczenie
    GS->>COM: M104 S0
    COM->>MAG: Wylacz elektromagnes
    GS->>COM: G0 Z{safe_z}
    COM->>PRINTER: Podniesienie glowicy
    GS-->>API: OK
```

---

## 10. Flow monitorowania (IoT)
```mermaid
sequenceDiagram
    participant SENSOR as Czujnik wagi
    participant MOCK as Mock Sensor
    participant MQTT as Mosquitto TLS
    participant LISTENER as MQTT Listener
    participant REDIS as Redis
    participant API as FastAPI
    participant DB as PostgreSQL

    SENSOR->>MQTT: Publish warehouse/rack/{id}/weight
    Note over MOCK: Symulacja w Streamlit
    MOCK->>MQTT: Publish warehouse/rack/{id}/weight
    MQTT->>LISTENER: Message
    LISTENER->>REDIS: Cache nowej wagi
    LISTENER->>API: POST /alerts (anomalia?)
    API->>DB: Sprawdz oczekiwana vs rzeczywista waga
    alt Niezgodnosc
        API->>DB: Utworz Alert (anomalia wagi)
    end
```

---

## 11. Warstwa danych (ERD)
```mermaid
erDiagram
    USER {
        uuid id PK
        string login
        string email
        string hashed_password
        enum role "admin | worker"
        string totp_secret
        boolean is_active
    }

    RACK {
        uuid id PK
        string label
        int rows
        int columns
        float temp_min
        float temp_max
        float max_weight
        float max_size_x
        float max_size_y
        float max_size_z
        text comment
    }

    PRODUCT_DEFINITION {
        uuid id PK
        string name
        string identifier
        string image_url
        float temp_min
        float temp_max
        float weight
        float size_x
        float size_y
        float size_z
        text comment
        int expiry_days
        boolean is_hazardous
    }

    STOCK_ITEM {
        uuid id PK
        uuid product_definition_id FK
        uuid rack_id FK
        int slot_row
        int slot_col
        datetime received_at
        uuid received_by FK
        datetime expires_at
        datetime removed_at
    }

    ALERT {
        uuid id PK
        string type
        string message
        boolean is_read
        datetime created_at
        uuid rack_id FK
    }

    PRODUCT_STATS {
        uuid id PK
        uuid product_definition_id FK
        int total_in
        int total_out
        datetime last_updated
    }

    USER ||--o{ STOCK_ITEM : "przyjmuje"
    RACK ||--o{ STOCK_ITEM : "przechowuje"
    PRODUCT_DEFINITION ||--o{ STOCK_ITEM : "definiuje"
    RACK ||--o{ ALERT : "generuje"
    PRODUCT_DEFINITION ||--o{ PRODUCT_STATS : "statystyki"
```

---

## 12. Zadania asynchroniczne (Celery)
```mermaid
graph TB
    subgraph Scheduler["Celery Beat (harmonogram)"]
        SCHED_RPT["Raporty<br/>codziennie"]
        SCHED_BKP["Backupy<br/>codziennie 03:00"]
        SCHED_AI["Re-trening AI<br/>codziennie 02:00"]
    end

    subgraph Workers["Celery Workers (x4)"]
        W1["report_tasks.py<br/>- Zbliżająca data waznosci<br/>- Przekroczone temperatury<br/>- Pelna inwentaryzacja"]
        W2["backup_tasks.py<br/>- Tworzenie backupu (AES)<br/>- Upload do MinIO"]
        W3["ai_tasks.py<br/>- Trening YOLO<br/>- Rozpoznawanie"]
        W4["csv_import.py<br/>- Import regalow<br/>- Import produktow"]
        W5["product_definition_tasks.py<br/>- Import zdjec<br/>- Przetwarzanie CSV"]
    end

    SCHED_RPT --> W1
    SCHED_BKP --> W2
    SCHED_AI --> W3

    style SCHED_RPT fill:#f59e0b,color:#000;
    style SCHED_BKP fill:#f59e0b,color:#000;
    style SCHED_AI fill:#f59e0b,color:#000;
    style W1 fill:#10b981,color:#fff;
    style W2 fill:#10b981,color:#fff;
    style W3 fill:#10b981,color:#fff;
    style W4 fill:#10b981,color:#fff;
    style W5 fill:#10b981,color:#fff;
```

---

## 13. Mapowanie zadan finalowych
```mermaid
graph LR
    subgraph Etap2["Etap 2 - Aplikacja magazynowa"]
        E2_1["Definiowanie regalow"]
        E2_2["Definiowanie asortymentu"]
        E2_3["Przyjmowanie / Wydawanie"]
        E2_4["Monitorowanie"]
        E2_5["Wizualizacja"]
        E2_6["Raporty"]
        E2_7["Backupy"]
        E2_8["Uzytkownicy i Role"]
        E2_9["AI Rozpoznawanie"]
        E2_10["Asystent glosowy"]
    end

    subgraph Etap3["Etap 3 FINAL - Magazyn fizyczny"]
        E3_1["Sterowanie USB G-code"]
        E3_2["Bezpieczny obszar pracy"]
        E3_3["Szachy QR"]
        E3_4["Szachy piktogramy"]
        E3_5["Inwentaryzacja auto"]
        E3_6["Skladowanie na sobie"]
        E3_7["Optymalizacja FIFO"]
        E3_8["Kolko i krzyzyk"]
        E3_9["Generator QR"]
        E3_10["Logo OZT"]
        E3_11["Joystick programowy"]
        E3_12["Joystick ESP32"]
    end

    style E2_1 fill:#10b981,color:#fff;
    style E2_2 fill:#10b981,color:#fff;
    style E2_3 fill:#10b981,color:#fff;
    style E2_4 fill:#10b981,color:#fff;
    style E2_5 fill:#10b981,color:#fff;
    style E2_6 fill:#10b981,color:#fff;
    style E2_7 fill:#10b981,color:#fff;
    style E2_8 fill:#10b981,color:#fff;
    style E2_9 fill:#10b981,color:#fff;
    style E2_10 fill:#10b981,color:#fff;
    style E3_1 fill:#3b82f6,color:#fff;
    style E3_2 fill:#3b82f6,color:#fff;
    style E3_3 fill:#3b82f6,color:#fff;
    style E3_4 fill:#3b82f6,color:#fff;
    style E3_5 fill:#3b82f6,color:#fff;
    style E3_6 fill:#3b82f6,color:#fff;
    style E3_7 fill:#3b82f6,color:#fff;
    style E3_8 fill:#3b82f6,color:#fff;
    style E3_9 fill:#3b82f6,color:#fff;
    style E3_10 fill:#3b82f6,color:#fff;
    style E3_11 fill:#3b82f6,color:#fff;
    style E3_12 fill:#3b82f6,color:#fff;
```
