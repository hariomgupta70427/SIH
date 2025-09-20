# QRail Backend Setup Guide

## Prerequisites
- Node.js 20+ (LTS)
- Firebase project: `smartindiahackathon-a62a3`

## Quick Setup

### 1. Node Version Management
```bash
# Using nvm (recommended)
nvm use 20
# Or check current version
node --version  # Should be >= 20.0.0
```

### 2. Install Dependencies
```bash
# Use exact versions from lockfile
npm ci
```

### 3. Firebase Configuration
1. Go to Firebase Console → Project Settings → Service Accounts
2. Generate new private key
3. Copy `.env.example` to `.env`
4. Fill in the Firebase credentials:
   - `FIREBASE_PRIVATE_KEY_ID`
   - `FIREBASE_PRIVATE_KEY` (include quotes and newlines)
   - `FIREBASE_CLIENT_EMAIL`
   - `FIREBASE_CLIENT_ID`

### 4. Start Server
```bash
npm run dev  # Development with nodemon
npm start    # Production
```

### 5. Access Dashboard
- Dashboard: http://localhost:3000
- API: http://localhost:3000/api/*

## Docker Deployment
```bash
docker build -t qrail-backend .
docker run -p 3000:3000 --env-file .env qrail-backend
```

## API Endpoints
- `POST /api/inspections` - Add inspection
- `GET /api/analytics` - Get dashboard data
- `POST /api/ml/predict` - ML prediction