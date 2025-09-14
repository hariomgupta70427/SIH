# 🚂 Railway Parts Management System - Project Flowchart

## 📊 Complete Codebase Architecture

```
🚂 SIH Railway Parts Management System
│
├── 📱 MOBILE APP (Flutter)
│   ├── lib/
│   │   ├── main.dart                    # 🚀 App Entry Point
│   │   ├── auth_screen.dart             # 🔐 Login/Register UI
│   │   ├── home_screen.dart             # 🏠 Main Dashboard
│   │   ├── qr_scanner_screen.dart       # 📷 QR Code Scanner
│   │   ├── qr_result_screen.dart        # 📋 Part Details Display
│   │   ├── firebase_options.dart        # 🔥 Firebase Config
│   │   └── services/
│   │       └── offline_sync_service.dart # 🔄 Offline Sync
│   ├── android/                         # 🤖 Android Config
│   │   ├── app/
│   │   │   ├── build.gradle            # 📦 Android Build
│   │   │   └── google-services.json    # 🔥 Firebase Android
│   │   └── gradle/                     # 🔧 Gradle Wrapper
│   ├── ios/                            # 🍎 iOS Config
│   │   └── Runner/
│   │       └── GoogleService-Info.plist # 🔥 Firebase iOS
│   ├── pubspec.yaml                    # 📦 Flutter Dependencies
│   └── integration_test/
│       └── app_test.dart               # 🧪 Integration Tests
│
├── 🔗 BACKEND API (Node.js)
│   └── backend/nodejs/
│       ├── server.js                   # 🚀 Express Server
│       ├── package.json                # 📦 Node Dependencies
│       ├── models/                     # 🗄️ Database Models
│       │   ├── index.js               # 📊 Sequelize Setup
│       │   ├── Part.js                # 🔧 Part Model
│       │   ├── Vendor.js              # 🏢 Vendor Model
│       │   └── Inspection.js          # ✅ Inspection Model
│       ├── routes/                     # 🛣️ API Endpoints
│       │   ├── parts.js               # 🔧 Parts CRUD
│       │   ├── vendors.js             # 🏢 Vendors CRUD
│       │   └── inspections.js         # ✅ Inspections CRUD
│       └── .env.example               # ⚙️ Environment Config
│
├── 🤖 ML SERVICE (Python)
│   └── ml/
│       ├── ml_api_simple.py           # 🚀 Flask ML API
│       ├── requirements.txt           # 📦 Python Dependencies
│       ├── anomaly_detection.py       # 🔍 Anomaly Detection
│       ├── predictive_maintenance.py  # 🔮 Predictive Models
│       ├── tensorflow_model.py        # 🧠 Deep Learning
│       ├── models/                    # 💾 Trained Models
│       │   ├── anomaly_detector.pkl   # 🔍 Anomaly Model
│       │   └── predictive_maintenance_model.pkl # 🔮 Prediction Model
│       └── data/                      # 📊 Training Data
│
├── ⛓️ BLOCKCHAIN SERVICE (Node.js)
│   └── blockchain/
│       ├── mock_blockchain_api.js     # 🚀 Blockchain API
│       ├── package.json               # 📦 Blockchain Dependencies
│       ├── hardhat.config.js          # ⚙️ Hardhat Config
│       ├── contracts/                 # 📜 Smart Contracts
│       │   └── PartTrace.sol          # ⛓️ Part Traceability
│       ├── scripts/                   # 🔧 Deployment Scripts
│       │   ├── deploy.js              # 🚀 Contract Deployment
│       │   └── interact.js            # 🤝 Contract Interaction
│       └── test/                      # 🧪 Contract Tests
│           └── PartTrace.test.js      # ✅ Smart Contract Tests
│
├── 🌐 ADMIN DASHBOARD (Flutter Web)
│   └── admin_dashboard/
│       ├── lib/
│       │   ├── main.dart              # 🚀 Web App Entry
│       │   ├── models/                # 📊 Data Models
│       │   │   ├── part.dart          # 🔧 Part Model
│       │   │   └── inspection.dart    # ✅ Inspection Model
│       │   ├── screens/               # 🖥️ Web Screens
│       │   │   ├── dashboard_screen.dart    # 📊 Main Dashboard
│       │   │   ├── inventory_screen.dart    # 📦 Inventory Management
│       │   │   └── inspections_screen.dart  # ✅ Inspections View
│       │   ├── services/              # 🔗 API Services
│       │   │   └── api_service.dart   # 🌐 HTTP Client
│       │   └── widgets/               # 🧩 Reusable Components
│       ├── web/
│       │   └── index.html             # 🌐 Web Entry Point
│       └── pubspec.yaml               # 📦 Web Dependencies
│
├── 🗄️ DATABASE SCHEMAS
│   └── database/
│       ├── postgresql_schema.sql      # 🐘 PostgreSQL Schema
│       ├── firebase_schema.json       # 🔥 Firebase Schema
│       ├── sequelize_models.js        # 📊 Sequelize Models
│       ├── django_models.py           # 🐍 Django Models
│       └── create_tables.sql          # 📋 Table Creation
│
├── 🔄 INTEGRATION SERVICES
│   └── integration/
│       ├── integration_manager.py     # 🔗 Integration Controller
│       ├── requirements.txt           # 📦 Integration Dependencies
│       └── scrapers/                  # 🕷️ Web Scrapers
│           ├── udm_scraper.py         # 🚂 UDM Portal Scraper
│           └── tms_scraper.py         # 🛤️ TMS Portal Scraper
│
├── 🧪 TESTING SUITE
│   └── testing/
│       ├── scripts/                   # 🔧 Test Scripts
│       │   ├── package.json           # 📦 Test Dependencies
│       │   ├── seed_database.js       # 🌱 Database Seeding
│       │   ├── seed_database.sql      # 📊 Sample Data
│       │   └── test_api_endpoints.js  # 🧪 API Testing
│       ├── integration/               # 🔗 Integration Tests
│       │   └── end_to_end_test.js     # 🎯 E2E Testing
│       └── data/                      # 📊 Test Data
│
├── 🚀 DEPLOYMENT
│   └── deployment/
│       ├── docker/                    # 🐳 Docker Setup
│       │   ├── docker-compose.yml     # 🐳 Multi-container Setup
│       │   ├── Dockerfile.backend     # 🔗 Backend Container
│       │   ├── Dockerfile.flutter     # 📱 Flutter Container
│       │   └── nginx.conf             # 🌐 Web Server Config
│       ├── ci/                        # 🔄 CI/CD Pipeline
│       │   └── github-actions.yml     # 🤖 GitHub Actions
│       └── scripts/                   # 🔧 Deployment Scripts
│           ├── deploy.sh              # 🚀 Production Deploy
│           └── build_flutter.sh       # 📱 Flutter Build
│
└── 📋 PROJECT MANAGEMENT
    ├── README.md                      # 📖 Main Documentation
    ├── README_QUICK_START.md          # ⚡ Quick Start Guide
    ├── SIMPLE_SETUP.md               # 🛠️ Simple Setup
    ├── demo_workflow.md               # 🎯 Demo Guide
    ├── pubspec.yaml                   # 📦 Main Flutter Config
    ├── .gitignore                     # 🚫 Git Ignore Rules
    ├── build_apk_only.bat            # 📱 APK Build Script
    ├── run_simple.bat                # 🚀 Simple Run Script
    └── PROJECT_FLOWCHART.md          # 📊 This Flowchart
```

## 🎯 Data Flow Architecture

```
📱 MOBILE APP
    ↓ QR Scan
🔍 QR SCANNER
    ↓ Part ID
🔗 BACKEND API
    ↓ Part Data Request
🤖 ML SERVICE ← → 🗄️ DATABASE
    ↓ Health Report
⛓️ BLOCKCHAIN
    ↓ Verification
📊 COMBINED RESPONSE
    ↓ Display
📱 PART DETAILS SCREEN
    ↓ Analytics
🌐 ADMIN DASHBOARD
```

## 🚀 Service Ports & Endpoints

```
📱 Flutter Mobile App    → Device/Emulator
🔗 Backend API          → http://localhost:3000
🤖 ML Service           → http://localhost:5000
⛓️ Blockchain API       → http://localhost:6000
🌐 Admin Dashboard      → http://localhost:8080
```

## 🎯 Key Integration Points

1. **📱 Mobile → 🔗 Backend**: REST API calls for part data
2. **🔗 Backend → 🤖 ML**: Health report generation
3. **🔗 Backend → ⛓️ Blockchain**: Part verification
4. **🌐 Admin → 🔗 Backend**: Management operations
5. **🔥 Firebase**: Authentication & offline sync
6. **📊 Database**: PostgreSQL for production data

## 🏗️ Build & Run Commands

```bash
# 📱 Mobile App
flutter build apk --release

# 🔗 Backend
cd backend/nodejs && npm start

# 🤖 ML Service  
cd ml && python ml_api_simple.py

# ⛓️ Blockchain
cd blockchain && node mock_blockchain_api.js

# 🌐 Admin Dashboard
cd admin_dashboard && flutter build web
```

**🎉 Complete Railway Parts Management System with QR scanning, AI predictions, blockchain verification, and admin dashboard!**