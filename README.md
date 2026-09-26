# CAMP — Monorepo

CAMP is an offline-capable telemetry, expedition navigation, and predictive maintenance platform for adventure riders.

---

## Repository Structure

```text
CAMP/
├── mobile/                  # Flutter mobile application
│   ├── android/             # Android native configuration and build scripts
│   ├── ios/                 # iOS native configuration and Xcode workspace
│   ├── assets/              # App assets and static resources
│   │   ├── ai/              # AI models, offline embeddings, and prompts
│   │   ├── icons/           # UI & system icon sets
│   │   ├── images/          # Illustration & raster graphics
│   │   ├── map/             # Map styles, vector tiles & markers
│   │   └── seed_data/       # Mock data and offline catalog seeds
│   ├── lib/
│   │   ├── app/             # Application lifecycle & global setups
│   │   │   ├── config/      # Environment & runtime configurations
│   │   │   ├── router/      # Navigation routing & deep links
│   │   │   └── theme/       # Design tokens, themes & typography
│   │   ├── core/            # Shared cross-cutting modules
│   │   │   ├── constants/   # App-wide constants & assets references
│   │   │   ├── database/    # Local persistence (Drift / Floor / SQLite)
│   │   │   │   ├── daos/    # Data Access Objects
│   │   │   │   └── tables/  # Database schema definitions
│   │   │   ├── network/     # HTTP clients, interceptors & error handlers
│   │   │   ├── services/    # Location, Bluetooth, Sensor & Background services
│   │   │   └── utils/       # Formatters, loggers, validation helpers
│   │   ├── features/        # Feature-first modular domain slices
│   │   │   ├── auth/            # Authentication & Onboarding
│   │   │   ├── dashboard/       # Central status, telemetrics & summary
│   │   │   ├── bike_scan/       # Vision AI vehicle scanner & diagnostics
│   │   │   ├── garage/          # Vehicle inventory & parts registry
│   │   │   ├── navigation/      # Turn-by-turn routing & offline maps (Route Packs)
│   │   │   ├── mechanics/       # Nearby workshops & specialist finder
│   │   │   ├── maintenance/     # Wear-and-tear tracking & service schedules (Predictive Maintenance)
│   │   │   ├── ride_history/    # Trip telemetry, routes & stats (Ride History)
│   │   │   ├── emergency_sos/   # Crash detection & emergency dispatches
│   │   │   ├── voice_copilot/   # Hands-free audio assistant & feedback
│   │   │   └── settings/        # Preferences & profile configuration
│   │   │   # (Each feature includes: controllers/, domain/, presentation/)
│   │   └── main.dart        # Flutter entrypoint
│   ├── test/                # Unit, widget, and integration tests
│   ├── pubspec.yaml         # Flutter dependencies
│   └── analysis_options.yaml# Dart static analysis configuration
│
├── backend/                 # Backend API services & functions
│   ├── config/              # Server configuration & environment validation
│   ├── functions/           # Cloud Functions / Serverless handlers
│   │   └── src/
│   │       ├── maintenance_rules/ # Automated maintenance triggers
│   │       └── sync/        # Cloud-to-local bidirectional sync
│   └── src/
│       ├── middlewares/     # Auth, validation, error-handling middlewares
│       ├── modules/         # Domain modules (elevation, mechanics, routes)
│       └── routes/          # REST & WebSocket endpoint definitions
│
├── firebase/                # Firebase configs, rules, and deployment specs
├── .gitignore               # Root monorepo Git exclusion rules
└── README.md                # Project documentation
```

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13+)
- Dart SDK (included with Flutter)

### Running the Mobile Application
1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the development application:
   ```bash
   flutter run
   ```
   Or for Chrome preview:
   ```bash
   flutter run -d chrome
   ```

### Running Static Analysis
```bash
cd mobile
flutter analyze
```
