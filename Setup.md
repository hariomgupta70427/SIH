# QRail - Railway Inspection System

## Prerequisites
- **Node.js**: >= 20.0.0 (required for Firebase Admin SDK)
- **npm**: >= 10.0.0
- **Flutter**: >= 3.35.0
- **Docker**: Latest version (optional)

## Quick Start

### Option 1: Automated Setup (Windows)
```bash
# Verify system requirements
verify_setup.bat

# Start entire system
start_system.bat
```

### Option 2: Manual Setup

#### 1. Environment Setup
```bash
# Check versions
node --version  # Should be >= 20.0.0
flutter --version  # Should be >= 3.35.0

# Clone repository
git clone <repository-url>
cd SIH
```

#### 2. Backend Setup
```bash
cd backend/nodejs

# Install dependencies
npm ci

# Copy environment template
cp .env.example .env
# Edit .env with your Firebase credentials

# Start server
npm start
```

#### 3. Flutter Setup
```bash
# From project root
flutter pub get
flutter run -d chrome
```

### 4. Firebase Configuration
1. Create Firebase project at https://console.firebase.google.com
2. Enable Authentication, Firestore, Storage
3. Download service account key to `backend/nodejs/.env`
4. Download `google-services.json` to `android/app/`
5. Download `GoogleService-Info.plist` to `ios/Runner/`

## Development with Emulators
```bash
# Start Firebase emulators
npm run emulator

# Or with Docker
docker-compose --profile dev up
```

## Production Deployment
```bash
# Build and deploy with Docker
docker-compose up -d

# Or deploy to Firebase
firebase deploy
```

## Features
- **Real-time Analytics**: Live dashboard with Chart.js
- **ML Predictions**: TensorFlow.js failure prediction
- **Data Entry**: Comprehensive inspection forms
- **Status Management**: Real-time status updates
- **Role-based Access**: Inspector/user permissions
- **Mobile & Web**: Flutter app + web dashboard
- **QR Scanning**: Camera-based part identification

## Architecture
```
├── backend/nodejs/          # Node.js API server
│   ├── routes/             # API endpoints
│   ├── services/           # Business logic
│   ├── middleware/         # Auth & validation
│   └── public/             # Web dashboard
├── lib/                    # Flutter mobile app
├── docker-compose.yml      # Container orchestration
└── firebase.json          # Firebase configuration
```

## Version Management
- **Lockfiles**: Use `npm ci` for reproducible builds
- **Node Version**: Enforced via package.json engines
- **Docker**: Pinned base images for consistency
- **CI/CD**: Automated testing and deployment