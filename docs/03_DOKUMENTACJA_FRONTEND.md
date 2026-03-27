# Primus Inter Pares 2026 — Dokumentacja Techniczna Frontend

> **Ogólnopolskie Zawody Techniczne Primus Inter Pares 2026**
> Temat: Magazyn — Zadanie FINAŁOWE (ETAP 3)

---

## 1. Przegląd frontendu

Frontend systemu Primus to **Single Page Application (SPA)** zbudowana w **React 19** z **TypeScript**, bundlowana przez **Vite 7** i stylowana za pomocą **Tailwind CSS 4**. Aplikacja komunikuje się z backendem przez REST API za pośrednictwem nginx (HTTPS).

**Repozytorium**: `primus-web-frontend/`

---

## 2. Struktura katalogów

```
primus-web-frontend/
├── src/
│   ├── App.tsx                        # Router, providers
│   ├── main.tsx                       # Punkt wejścia
│   ├── index.css                      # Style globalne, Tailwind
│   ├── config/
│   │   └── constants.ts               # API_URL
│   ├── context/
│   │   └── AuthProvider.tsx           # Kontekst autentykacji (JWT)
│   ├── hooks/                         # Custom hooks (logika API)
│   │   ├── useAuthUser.ts
│   │   ├── useRacks.ts
│   │   ├── useProducts.ts
│   │   ├── useStock.ts
│   │   ├── useReports.ts
│   │   ├── useBackups.ts
│   │   ├── useAlerts.ts
│   │   ├── useAI.ts
│   │   ├── use2FA.ts
│   │   └── ...
│   ├── types/                         # Definicje TypeScript
│   ├── layouts/
│   │   ├── RootLayout.tsx             # Layout główny (nawigacja)
│   │   ├── AuthLayout.tsx             # Layout logowania
│   │   └── ProtectedRoute.tsx         # Guard autentykacji
│   ├── pages/
│   │   ├── Authentication/
│   │   │   └── AuthPage.tsx           # Logowanie / Rejestracja
│   │   ├── AlertsPage.tsx             # Alerty systemowe
│   │   ├── AdminAIPage.tsx            # Panel AI (admin)
│   │   └── features/                  # Strony funkcjonalności
│   │       ├── Dashboard/
│   │       ├── WarehouseDefinition/
│   │       ├── ProductDefinitions/
│   │       ├── Reports/
│   │       ├── Backups/
│   │       ├── Profile/
│   │       ├── WarehouseUsers/
│   │       ├── PrinterControl/
│   │       ├── ChessSetup/
│   │       ├── TicTacToe/
│   │       ├── QRGenerator/
│   │       ├── LogoOzt/
│   │       └── WarehouseAudit/
│   ├── components/
│   │   ├── Authentication/            # Formularze logowania
│   │   ├── Navigation/                # Nawigacja boczna
│   │   ├── ErrorBoundary.tsx          # Obsługa błędów
│   │   ├── common/                    # Wspólne komponenty
│   │   ├── ui/                        # Radix UI primitives
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── input.tsx
│   │   │   ├── select.tsx
│   │   │   ├── table.tsx
│   │   │   ├── form.tsx
│   │   │   ├── badge.tsx
│   │   │   ├── alert.tsx
│   │   │   ├── avatar.tsx
│   │   │   ├── checkbox.tsx
│   │   │   └── label.tsx
│   │   └── features/                  # Komponenty per-feature
│   │       ├── Dashboard/
│   │       ├── ProductDefinitions/
│   │       ├── Backups/
│   │       ├── Reports/
│   │       ├── InventoryReports/
│   │       ├── Profile/
│   │       ├── Racks/
│   │       └── WarehouseUsers/
│   ├── lib/                           # Utilities
│   ├── mocks/                         # Mock data
│   └── assets/                        # Zasoby statyczne
├── Dockerfile                         # Build produkcyjny
├── package.json
├── vite.config.ts
├── tailwind.config.ts
└── tsconfig.json
```

---

## 3. Routing

Aplikacja używa **React Router DOM v7** z `createBrowserRouter`:

| Ścieżka | Strona | Opis | Rola |
|---|---|---|---|
| `/signin` | `AuthPage` | Logowanie / Rejestracja | Publiczna |
| `/` | `DashboardPage` | Dashboard magazynu | Zalogowany |
| `/warehouse-definition` | `WarehouseDefinitionPage` | Definiowanie regałów | Administrator |
| `/product-definitions` | `ProductDefinitionsPage` | Zarządzanie asortymentem | Zalogowany |
| `/users-manager` | `WarehouseUsersPage` | Zarządzanie użytkownikami | Administrator |
| `/reports` | `ReportsPage` | Raporty (PDF) | Zalogowany |
| `/backups` | `BackupsPage` | Backupy bazy danych | Administrator |
| `/profile` | `ProfilePage` | Profil, hasło, 2FA | Zalogowany |
| `/alerts` | `AlertsPage` | Alerty systemowe | Zalogowany |
| `/printer-control` | `PrinterControlPage` | Sterowanie drukarką / Joystick | Zalogowany |
| `/chess-setup` | `ChessSetupPage` | Rozstawianie szachów | Zalogowany |
| `/tictactoe` | `TicTacToePage` | Kółko i krzyżyk | Zalogowany |
| `/qr-generator` | `QRGeneratorPage` | Generator kodów QR | Zalogowany |
| `/logo-ozt` | `LogoOztPage` | Układanie Logo OZT | Zalogowany |
| `/warehouse-inventory` | `WarehouseAuditPage` | Inwentaryzacja automatyczna | Zalogowany |
| `/admin/ai` | `AdminAIPage` | Panel AI | Administrator |

---

## 4. Opis stron i komponentów

### 4.1 Dashboard (`DashboardPage`)
- **Widok**: Wizualizacja magazynu — siatka regałów z kolorową mapą obłożenia
- **Komponenty**: `AdminDashboard`, `WorkerDashboard`, `RackCardGrid`, `RackTable`, `RackFormModal`, `RackInventoryModal`, `ImportRacksModal`
- **Interakcje**: Dodawanie/edycja/usuwanie regałów, import CSV, podgląd zawartości slotów
- **Dane**: `useRacks`, `useStock`
<!-- TODO: Screenshoty wizualizacji -->

### 4.2 Definiowanie asortymentu (`ProductDefinitionsPage`)
- **Widok**: Karty produktów z filtrami i wyszukiwarką
- **Komponenty**: `ProductCard`, `ProductFormModal`, `ProductManagement`, `ImportProductsModal`, `ImportProductPhotosModal`
- **Interakcje**: CRUD produktów, upload zdjęć, import CSV
- **Dane**: `useProducts`
<!-- TODO: Uzupełnić opis formularza -->

### 4.3 Sterowanie drukarką (`PrinterControlPage`)
- **Widok**: Panel sterowania — joystick programowy, kontrola elektromagnesu, podgląd kamery
- **Funkcje**:
  - Joystick programowy (fire-and-forget jogging w 6 kierunkach)
  - Włączanie/wyłączanie elektromagnesu
  - Pick & Place
  - Homing (G28)
  - Podgląd z kamery USB (stream)
  - Status drukarki
<!-- TODO: Opisać implementację joysticka ESP32S3 -->

### 4.4 Rozstawianie szachów (`ChessSetupPage`)
- **Widok**: Szachownica 8x8, status rozstawiania
- **Tryby**:
  - Rozstawianie na podstawie **kodów QR** — skanowanie kamerą
  - Rozstawianie na podstawie **piktogramów** — rozpoznawanie AI (YOLO)
- **Dane**: `useChess` (hook)
<!-- TODO: Screenshoty, opis procesu rozstawiania -->

### 4.5 Kółko i krzyżyk (`TicTacToePage`)
- **Tryby**:
  - Człowiek vs Człowiek (PvP)
  - SI vs Człowiek (AI player)
- **Widok**: Plansza 3x3, fizyczne odwzorowanie ruchów na magazynie
<!-- TODO: Opisać interakcję z drukarką -->

### 4.6 Generator QR (`QRGeneratorPage`)
- **Widok**: Formularz generowania kodu QR z podglądem
- **Funkcja**: Tworzenie kodów QR dla nowych obiektów magazynowych
- **Biblioteka**: `react-qr-code`
<!-- TODO: Opisać integrację z backendem (drukowanie) -->

### 4.7 Logo OZT (`LogoOztPage`)
- **Widok**: Układ materiałów tworzących logo OZT
- **Funkcja**: Automatyczne ułożenie metalowych płytek w kształt logo
<!-- TODO: Opisać pattern logo, sekwencję ruchów -->

### 4.8 Inwentaryzacja (`WarehouseAuditPage`)
- **Widok**: Progres inwentaryzacji, raport rozbieżności
- **Funkcja**: Automatyczne skanowanie magazynu kamerą, porównanie stanu fizycznego z systemowym
- **Komponent**: `WarehouseAudit`
<!-- TODO: Opisać flow inwentaryzacji -->

### 4.9 Raporty (`ReportsPage`)
- **Widok**: Lista raportów, generowanie na żądanie
- **Typy**:
  - Zbliżająca data ważności
  - Przekroczone temperatury
  - Pełna inwentaryzacja
- **Komponent**: `ReportsManager`

### 4.10 Backupy (`BackupsPage`)
- **Widok**: Lista backupów, tworzenie/przywracanie
- **Komponent**: `BackupsManager`

### 4.11 Zarządzanie użytkownikami (`WarehouseUsersPage`)
- **Widok**: Lista użytkowników, zatwierdzanie wniosków rejestracyjnych
- **Komponenty**: `WarehouseUsers`, `UserRegisterRequests`, `RegisterRequest`
- **Dostęp**: Tylko Administrator

### 4.12 Profil (`ProfilePage`)
- **Widok**: Informacje o koncie, zmiana hasła, konfiguracja 2FA
- **Komponenty**: `Profile`, `ProfileInformationCard`, `ProfileSecurityCard`, `EditPasswordModal`, `Setup2FaModal`

### 4.13 Alerty (`AlertsPage`)
- **Widok**: Lista alertów systemowych z akcjami

### 4.14 Panel AI (`AdminAIPage`)
- **Widok**: Zarządzanie modelami AI, trenowanie, rozpoznawanie
- **Dostęp**: Tylko Administrator

---

## 5. Komunikacja z API

### 5.1 Konfiguracja
```typescript
// config/constants.ts
export const API_URL = (import.meta.env.VITE_API_URL || "http://localhost/api/v1/")
    .replace(/\/?$/, '/');
```

### 5.2 HTTP Client
- **Axios** z automatycznym dołączaniem tokenu JWT (interceptor)
- **TanStack React Query** — cache'owanie, invalidacja, refetch

### 5.3 Wzorzec Custom Hooks
Każda funkcjonalność posiada dedykowany hook (`hooks/use*.ts`), który enkapsuluje:
- Zapytania do API (queries)
- Mutacje (mutations)
- Invalidację cache

```typescript
// Przykładowy wzorzec (uproszczony)
export function useRacks() {
    const query = useQuery({ queryKey: ['racks'], queryFn: fetchRacks });
    const createMutation = useMutation({ mutationFn: createRack, onSuccess: invalidate });
    return { racks: query.data, createRack: createMutation.mutate, ... };
}
```

---

## 6. Stylowanie i design system

### 6.1 Tailwind CSS 4
- Konfiguracja: `tailwind.config.ts`
- Plugin: `@tailwindcss/vite`
- Animacje: `tw-animate-css`

### 6.2 Komponenty UI
System komponentów bazujący na **Radix UI Primitives** z wariantami CVA:
- `Button`, `Card`, `Input`, `Select`, `Table`, `Form`
- `Badge`, `Alert`, `Avatar`, `Checkbox`, `Label`
- Stylowanie: `class-variance-authority` + `tailwind-merge` + `clsx`

### 6.3 Ikony
- **Lucide React** — spójna paczka ikon SVG

### 6.4 Formularze
- **React Hook Form** — zarządzanie stanem formularzy
- **Zod** — walidacja schematów (runtime + TS types)

---

## 7. Autentykacja

### 7.1 Flow
1. Użytkownik loguje się przez `AuthPage`
2. Backend zwraca JWT token
3. Token przechowywany w `AuthProvider` (Context API)
4. `ProtectedRoute` — guard sprawdzający ważność tokenu
5. Axios interceptor dołącza `Authorization: Bearer <token>`

### 7.2 2FA (TOTP)
- Konfiguracja w `ProfilePage` → `Setup2FaModal`
- Hook: `use2FA`
- Generowanie kodu QR do zeskanowania aplikacją autentyfikatora
<!-- TODO: Opisać flow weryfikacji 2FA przy logowaniu -->

---

## 8. Responsywność i UX

- **Layout**: Sidebar nawigacja + content area
- **Responsywność**: Tailwind breakpoints (sm/md/lg/xl)
- **Powiadomienia**: React Toastify (success/error/warning)
- **Error Handling**: `ErrorBoundary` component
- **Dark Mode**: <!-- TODO: Opisać wsparcie dark mode -->
<!-- TODO: Screenshoty interfejsu -->

---

## 9. Build i deployment

### 9.1 Development
```bash
cd primus-web-frontend
npm install
npm run dev        # Vite dev server (:5173)
```

### 9.2 Production (Docker)
```dockerfile
# Multi-stage build
# Stage 1: npm install + vite build
# Stage 2: nginx serve static
```

Wynikowa aplikacja serwowana przez nginx w kontenerze Docker.

### 9.3 Zmienne środowiskowe
| Zmienna | Opis | Domyślna |
|---|---|---|
| `VITE_API_URL` | URL backendu API | `http://localhost/api/v1/` |

---

## 10. Biblioteki i zależności

| Biblioteka | Cel | Wersja |
|---|---|---|
| `react` | Framework UI | ^19.2 |
| `typescript` | Typowanie | ~5.9 |
| `vite` | Bundler | ^7.2 |
| `tailwindcss` | Stylowanie | ^4.1 |
| `@tanstack/react-query` | Zarządzanie danymi serwera | ^5.90 |
| `axios` | HTTP client | ^1.13 |
| `react-router-dom` | Routing | ^7.12 |
| `react-hook-form` | Formularze | ^7.70 |
| `zod` | Walidacja schematów | ^4.3 |
| `lucide-react` | Ikony | ^0.562 |
| `@radix-ui/*` | Primitives UI | — |
| `class-variance-authority` | Warianty komponentów | ^0.7 |
| `react-toastify` | Powiadomienia toast | ^11.0 |
| `react-qr-code` | Renderowanie kodów QR | ^2.0 |
| `date-fns` | Operacje na datach | ^4.1 |

---

> **Dokument**: 03 — Dokumentacja Techniczna Frontend
> **Ostatnia aktualizacja**: <!-- TODO: Data -->
> **Autorzy**: Drużyna Primus
