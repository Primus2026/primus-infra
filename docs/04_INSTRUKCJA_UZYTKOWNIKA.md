# Primus Inter Pares 2026 — Instrukcja Użytkownika

> **Ogólnopolskie Zawody Techniczne Primus Inter Pares 2026**
> System Magazynowy Primus — Podręcznik Użytkownika

---

## Spis treści

1. Wprowadzenie
2. Wymagania systemowe
3. Logowanie i rejestracja
4. Nawigacja w systemie
5. Panel główny (Dashboard)
6. Zarządzanie magazynem
7. Zarządzanie asortymentem
8. Operacje magazynowe
9. Raporty
10. Alerty i monitorowanie
11. Kopie zapasowe
12. Profil i bezpieczeństwo
13. Zarządzanie użytkownikami
14. Funkcje finałowe (Etap 3)
15. Rozwiązywanie problemów

---

## 1. Wprowadzenie

**Primus** to zaawansowany system zarządzania magazynem, łączący aplikację webową z fizycznym magazynem opartym na zmodernizowanej drukarce 3D. System umożliwia:

- Definiowanie struktury magazynu (regały MxN)
- Zarządzanie asortymentem z identyfikacją QR/barcode
- Przyjmowanie i wydawanie towarów (FIFO)
- Monitorowanie dat ważności i parametrów środowiskowych
- Automatyczną inwentaryzację z rozpoznawaniem wizualnym
- Sterowanie fizycznym magazynem (drukarka 3D + elektromagnes)

### Role użytkowników

| Rola | Uprawnienia |
|---|---|
| **Administrator** | Pełne zarządzanie: definicja magazynu, użytkownicy, backupy, model AI |
| **Użytkownik Magazynu** | Operacje magazynowe, raporty, profil (bez dostępu do ustawień systemu) |

---

## 2. Wymagania systemowe

### Dostęp do aplikacji
- Przeglądarka: Chrome 90+, Firefox 90+, Edge 90+
- Adres: `https://localhost:8443` (lub adres serwera)
- Wymagany certyfikat TLS (możliwe ostrzeżenie przeglądarki przy self-signed)

### Sprzęt (tryb finałowy — Etap 3)
- Drukarka 3D podłączona przez USB (port COM)
- Kamera USB zamontowana na głowicy
- ESP32S3 Matrix jako joystick (opcjonalnie)

---

## 3. Logowanie i rejestracja

### 3.1 Logowanie
1. Otwórz aplikację w przeglądarce
2. Na ekranie logowania wprowadź **Login** i **Hasło**
3. Kliknij **„Zaloguj się"**
4. Jeśli masz włączone 2FA, wprowadź 6-cyfrowy kod z aplikacji uwierzytelniającej

### 3.2 Rejestracja pracownika
1. Na ekranie logowania kliknij **„Zarejestruj się jako pracownik"**
2. Wypełnij formularz rejestracji (login, email, hasło)
3. Wniosek trafia do Administratora, który musi go zatwierdzić
4. Po zatwierdzeniu możesz się zalogować

### 3.3 Domyślne konto administratora
- **Login**: `SUPER_ADMIN`
- **Hasło**: `Asdf#1234`

> [!CAUTION]
> Zmień domyślne hasło administratora natychmiast po pierwszym logowaniu!

---

## 4. Nawigacja w systemie

Po zalogowaniu widoczna jest nawigacja boczna (sidebar) z następującymi sekcjami:

### Menu główne
| Ikona | Element | Opis |
|---|---|---|
| 📊 | **Panel** | Dashboard — przegląd magazynu |
| 👥 | **Użytkownicy** | Zarządzanie kontami *(Administrator)* |
| 🏭 | **Magazyn** | Definicja regałów *(Administrator)* |
| 📦 | **Produkty** | Zarządzanie asortymentem |
| 📈 | **Raporty** | Generowanie i pobieranie raportów |
| 🔔 | **Alerty** | Powiadomienia systemowe (z licznikiem) |
| 💾 | **Kopie Zapasowe** | Backup / przywracanie *(Administrator)* |
| 🧠 | **Model AI** | Zarządzanie modelami *(Administrator)* |
| 👤 | **Profil** | Ustawienia konta, hasło, 2FA |

### Dodatkowe (Etap 3)
Rozwijalna sekcja **„Dodatkowe (Etap 3)"** zawiera:

| Element | Opis |
|---|---|
| **Plansza Magazynu** | Sterowanie drukarką 3D, joystick, kamera |
| **Szachownica** | Rozstawianie figur szachowych |
| **Kółko i Krzyżyk** | Gra (PvP lub SI) |
| **Generowanie QR** | Tworzenie kodów QR dla nowych obiektów |
| **Budowa Logo OZT** | Układanie materiałów w logo |
| **Inwentaryzacja Magazynu** | Automatyczny audyt stanu |

---

## 5. Panel główny (Dashboard)

Dashboard wyświetla wizualizację magazynu w formie interaktywnej siatki regałów.

### Opis widoku
- **Kolorowa mapa regałów** — kolory odzwierciedlają stopień obłożenia
- **Tabela regałów** — lista regałów z parametrami
- **Podgląd zawartości** — kliknij regał, aby zobaczyć jego sloty

### Akcje
- ➕ **Dodaj regał** — otwiera formularz (rozmiar MxN, temperatury, waga, wymiary)
- 📥 **Import CSV** — masowe dodawanie regałów z pliku
- ✏️ **Edytuj** — zmiana parametrów istniejącego regału
- 🗑️ **Usuń** — usunięcie regału (z potwierdzeniem)

<!-- TODO: Screenshot dashboardu -->

---

## 6. Zarządzanie magazynem

### 6.1 Dodawanie regału
Przejdź do **Magazyn** (menu boczne) lub kliknij **„Dodaj Regał"** na Dashboardzie.

Wypełnij wymagane pola:

| Pole | Opis | Przykład |
|---|---|---|
| Oznaczenie | Unikalna nazwa regału | `A-01` |
| Rozmiar (MxN) | Wiersze × Kolumny | `4 x 6` |
| Temperatura min. | Minimalna temperatura [°C] | `-5` |
| Temperatura maks. | Maksymalna temperatura [°C] | `25` |
| Maks. waga | Maksymalne obciążenie [kg] | `100` |
| Maks. wymiary (XxYxZ) | Maksymalny rozmiar przedmiotów [mm] | `200x300x500` |
| Komentarz | Dowolna notatka | `Regał chłodniczy` |

### 6.2 Import regałów z CSV
1. Przejdź do **Magazyn** lub **Dashboard**
2. Kliknij **„Import CSV"**
3. Wybierz plik CSV z definicjami
4. System zaimportuje regały automatycznie

**Format CSV (Półki)**: `Oznaczenie;M;N;TempMin;TempMax;MaxWagaKg;MaxSzerokoscMm;MaxWysokoscMm;MaxGlebokoscMm;Komentarz`
- `Oznaczenie`: np. `R-101`
- `M`, `N`: wymiary siatki (np. 5x10)
- `TempMin/Max`: np. `5;25`
- `Wymiary`: w milimetrach

### 6.3 Edycja i usuwanie
- Kliknij **ikonę edycji** ✏️ przy regale → zmień parametry → **Zapisz**
- Kliknij **ikonę usuwania** 🗑️ przy regale → potwierdź operację

---

## 7. Zarządzanie asortymentem

### 7.1 Lista produktów
Przejdź do **Produkty** — widoczne są karty produktów z miniaturkami zdjęć.

Dostępne akcje:
- Wyszukiwanie po nazwie
- Filtrowanie
- Dodawanie, edycja, usuwanie produktów

### 7.2 Dodawanie produktu
Kliknij **„Dodaj produkt"** i wypełnij formularz:

| Pole | Opis | Wymagane |
|---|---|---|
| Nazwa | Nazwa asortymentu | ✅ |
| Identyfikator | Kod QR lub kreskowy | ✅ |
| Zdjęcie | Upload zdjęcia | ❌ |
| Temperatura min./maks. | Zakres przechowywania [°C] | ✅ |
| Waga | Waga jednostki [kg] | ✅ |
| Wymiary (XxYxZ) | Wymiary [mm] | ✅ |
| Termin ważności | Ilość dni od przyjęcia | ❌ |
| Materiał niebezpieczny | Oznaczenie niebezpieczeństwa | ❌ |
| Komentarz | Dodatkowe informacje | ❌ |

### 7.3 Import z CSV
1. Kliknij **„Importuj z CSV"**
2. Wybierz plik CSV
3. System przetworzy dane w tle (zadanie Celery)
4. Powiadomienie toast o zakończeniu

### 7.4 Import zdjęć
- Kliknij **„Importuj zdjęcia"**
- Wybierz pliki graficzne
- System przypisze je do produktów na podstawie nazw plików

---

## 8. Operacje magazynowe

### 8.1 Przyjęcie towaru (Inbound)
1. Zeskanuj **kod QR/kreskowy** produktu
2. System automatycznie:
   - Dodaje produkt do magazynu z datą i godziną
   - Przypisuje użytkownika przyjmującego
   - **Wskaże regał** spełniający wymagania (temperatura, wymiary, waga)
   - Oblicza datę ważności
3. Jeśli brak miejsca — system wyświetla komunikat

### 8.2 Wydanie towaru (Outbound)
1. Zeskanuj **kod QR/kreskowy** produktu
2. System zdejmie towar ze stanu według zasady **FIFO** (First In, First Out)
3. Najstarszy egzemplarz danego produktu zostaje wydany

<!-- TODO: Screenshoty procesu przyjęcia/wydania -->

---

## 9. Raporty

Przejdź do **Raporty** w menu bocznym.

### Dostępne raporty
| Typ raportu | Opis |
|---|---|
| **Zbliżająca data ważności** | Produkty z bliskim terminem przydatności |
| **Przekroczone temperatury** | Zdarzenia przekroczenia zakresu temperatur |
| **Pełna inwentaryzacja** | Kompletny stan magazynu |

### Generowanie
1. Wybierz typ raportu
2. Kliknij **„Generuj"**
3. Raport jest tworzony w tle (format PDF)
4. Po wygenerowaniu kliknij **„Pobierz"**

Raporty są automatycznie generowane codziennie wg harmonogramu.

---

## 10. Alerty i monitorowanie

Przejdź do **Alerty** — ikona dzwonka z licznikiem nieprzeczytanych.

### Typy alertów
| Alert | Opis |
|---|---|
| 🟡 **Zbliżająca data ważności** | Produkt wkrótce straci ważność |
| 🔴 **Przekroczona data ważności** | Produkt po terminie |
| ⚠️ **Anomalia wagi** | Nieautoryzowane pobranie z regału |

### Akcje
- **Oznacz jako przeczytany** — odrzuć alert
- Alerty są generowane automatycznie przez system monitoringu

---

## 11. Kopie zapasowe

Przejdź do **Kopie Zapasowe** *(wymaga roli Administrator)*.

### Tworzenie backupu
1. Kliknij **„Utwórz kopię zapasową"**
2. System tworzy zaszyfrowany backup bazy danych
3. Backup jest przechowywany w bezpiecznym storage (MinIO)

### Przywracanie
1. Wybierz backup z listy
2. Kliknij **„Przywróć"**
3. Potwierdź operację

> [!WARNING]
> Przywrócenie backupu nadpisze aktualny stan bazy danych!

### Automatyczne backupy
- System automatycznie tworzy backupy codziennie (domyślnie o 03:00)
- Backupy są szyfrowane kluczem AES

---

## 12. Profil i bezpieczeństwo

Przejdź do **Profil** w menu bocznym.

### 12.1 Informacje o koncie
- Podgląd loginu, emaila i roli
- Inicjały wyświetlane na awatarze

### 12.2 Zmiana hasła
1. Kliknij **„Zmień hasło"**
2. Wprowadź aktualne hasło
3. Wprowadź nowe hasło (min. 6 znaków)
4. Potwierdź nowe hasło
5. Kliknij **„Zapisz"**

### 12.3 Uwierzytelnianie dwupoziomowe (2FA)
1. Kliknij **„Konfiguruj 2FA"**
2. Zeskanuj wyświetlony kod QR aplikacją uwierzytelniającą (np. Google Authenticator, Authy)
3. Wprowadź 6-cyfrowy kod weryfikacyjny z aplikacji
4. Kliknij **„Aktywuj"**

Po włączeniu 2FA, przy każdym logowaniu będzie wymagane podanie kodu z aplikacji.

---

## 13. Zarządzanie użytkownikami

Przejdź do **Użytkownicy** *(wymaga roli Administrator)*.

### 13.1 Lista użytkowników
- Przegląd wszystkich kont z rolami
- Edycja ról i danych użytkowników
- Usuwanie kont

### 13.2 Zatwierdzanie rejestracji
- Nowi użytkownicy rejestrujący się jako pracownicy pojawiają się jako **wnioski rejestracyjne**
- Administrator może **zatwierdzić** lub **odrzucić** wniosek

---

## 14. Funkcje finałowe (Etap 3)

Rozwiń sekcję **„Dodatkowe (Etap 3)"** w menu bocznym.

### 14.1 Plansza Magazynu (Sterowanie drukarką)

Strona umożliwia bezpośrednie sterowanie fizycznym magazynem (drukarka 3D).

**Dostępne funkcje:**
- **Joystick programowy** — ruch głowicy w 6 kierunkach (X+, X−, Y+, Y−, Z+, Z−)
- **Elektromagnes** — włączanie/wyłączanie (pobieranie/odkładanie metalowych płytek)
- **Pick & Place** — zautomatyzowane sekwencje pobrania i odłożenia
- **Homing (G28)** — powrót do pozycji bazowej
- **Podgląd kamery** — obraz na żywo z kamery inspekcyjnej USB
- **Status drukarki** — monitoring pozycji i stanu

> [!IMPORTANT]
> System posiada zabezpieczenia uniemożliwiające wyjście poza bezpieczny obszar pracy drukarki.

### 14.2 Szachownica — Rozstawianie figur

Automatyczne rozstawianie figur szachowych na planszy 8x8.

**Tryby:**
1. **Rozpoznawanie kodów QR** — kamera skanuje kody QR na płytkach
2. **Rozpoznawanie piktogramów** — model AI (YOLO) rozpoznaje naklejone figury szachowe

**Kody QR figur:**

| Kod | Figura | Kod | Figura |
|---|---|---|---|
| HB | Hetman Biały | HC | Hetman Czarny |
| KB | Król Biały | KC | Król Czarny |
| WB | Wieża Biała | WC | Wieża Czarna |
| GB | Goniec Biały | GC | Goniec Czarny |
| SB | Skoczek Biały | SC | Skoczek Czarny |
| PB | Pion Biały | PC | Pion Czarny |

**Sekwencja rozstawiania**:
1. Wybierz rozstawienie (początkowe lub dowolne).
2. System skanuje aktualną planszę i magazyn.
3. Drukarka precyzyjnie przenosi figury na docelowe pola.
4. Całość procesu zajmuje ok. 5-8 minut dla pełnego zestawu.

### 14.3 Kółko i krzyżyk

Fizyczna gra w kółko i krzyżyk realizowana przez magazyn.

| Tryb | Opis |
|---|---|
| **Człowiek vs Człowiek** | Dwóch graczy na przemian wykonuje ruchy |
| **SI vs Człowiek** | Gra przeciwko sztucznej inteligencji **Qwen** (Ollama) |

Ruchy są realizowane fizycznie — drukarka przesuwa odpowiednie płytki na planszę 3x3.

**Rozpoczęcie gry**:
1. Wybierz tryb (PvP lub SI).
2. Wykonaj ruch na planszy 3x3 na ekranie.
3. Drukarka pobierze płytkę (Kółko lub Krzyżyk) z magazynu i umieści ją na planszy.
4. W trybie SI system odpowie automatycznie, wykonując swój ruch fizycznie.

### 14.4 Generator kodów QR

1. Przejdź do **Generowanie QR**
2. Wprowadź dane dla nowego obiektu
3. System wygeneruje kod QR w formacie PNG
4. Pobierz lub wydrukuj kod

### 14.5 Budowa Logo OZT

Automatyczne ułożenie metalowych płytek w kształt **logo Ogólnopolskich Zawodów Technicznych**.

1. Kliknij **„Rozpocznij"**
2. System automatycznie pobiera i układa płytki wg wzorca
3. Obserwuj postęp na ekranie i na żywo przez kamerę

**Wzorzec logo**:
- Logo składa się z 12 precyzyjnie ułożonych płytek metalowych.
- Sekwencja jest zoptymalizowana, aby zminimalizować ruchy jałowe głowicy.
- Czas ułożenia: ok. 4 minuty.

### 14.6 Inwentaryzacja automatyczna

Automatyczne skanowanie całego magazynu z porównaniem stanu systemu ze stanem fizycznym.

1. Kliknij **„Rozpocznij inwentaryzację"**
2. Drukarka przesuwa kamerę nad każdym slotem
3. Kamera skanuje QR kody / rozpoznaje piktogramy
4. System generuje **raport rozbieżności**

**Raport rozbieżności**:
- Wyświetla listę slotów, w których stan fizyczny (skan) różni się od systemowego.
- Pozwala na szybką synchronizację bazy danych z rzeczywistością jednym kliknięciem.

### 14.7 Model AI (Panel Administratora)

Panel zarządzania modelami sztucznej inteligencji.

- **Rozpoznawanie przedmiotów** — identyfikacja na podstawie wyglądu (np. z uszkodzonym kodem)
- **Trening modelu** — możliwość re-trenowania modelu YOLO na nowych danych
- **Lista modeli** — przegląd wytrenowanych modeli

### 14.8 Asystent głosowy

System rozpoznaje komendy głosowe do kontroli aplikacji:
- *„Dodaj produkt na półkę"*
- *„Usuń produkt ze stanu"*
- *„Pokaż stan magazynu"*
- „Odbierz produkty” — otwiera stronę przyjmowania towaru.
- „Wydaj [Nazwa Produktu]” — rozpoczyna proces wydawania.
- „Sprawdź temperaturę regału A” — odczytuje parametry regału.
- „Wygeneruj raport inwentaryzacji” — zleca zadanie do Celery.

### 14.9 Joystick ESP32S3

Opcjonalny fizyczny joystick zbudowany na ESP32S3 Matrix, umożliwiający:
- Poruszanie głowicą w dowolnym kierunku
- Sterowanie elektromagnesem
- Wizualizację pozycji na matrycy LED

**Konfiguracja**:
1. Podłącz urządzenie do tej samej sieci WiFi co serwer.
2. Ustaw `ESP_IP` w ustawieniach systemu.
3. Joystick pozwala na sterowanie z dokładnością do 0.1mm.

---

## 15. Rozwiązywanie problemów

| Problem | Rozwiązanie |
|---|---|
| Nie mogę się zalogować | Sprawdź login i hasło. Jeśli masz 2FA — upewnij się, że kod jest aktualny |
| Brak połączenia z drukarką | Sprawdź kabel USB, port COM i baudrate (250000) |
| Kamera nie wyświetla obrazu | Sprawdź podłączenie USB kamery, indeks kamery w konfiguracji |
| Raporty się nie generują | Sprawdź status workera Celery w logach Docker |
| Nie widzę pewnych opcji menu | Elementy są ukryte na podstawie roli — skontaktuj się z Administratorem |
| Błąd certyfikatu TLS | Zaakceptuj certyfikat self-signed w przeglądarce lub dodaj wyjątek |
| ESP32 joystick nie reaguje | Sprawdź IP ESP32 w konfiguracji, upewnij się, że jest w tej samej sieci |

---

> **Dokument**: 04 — Instrukcja Użytkownika
> **Ostatnia aktualizacja**: <!-- TODO: Data -->
> **Autorzy**: Drużyna Primus
