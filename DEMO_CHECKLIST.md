# Railway Parts Demo Checklist

## Prerequisites

### System Requirements
- **Node.js** (v16 or higher) - `node --version`
- **Python** (v3.8 or higher) - `python --version` or `python3 --version`
- **Flutter** (v3.0 or higher) - `flutter --version`
- **PostgreSQL** (optional, will fallback to SQLite) - `psql --version`
- **Android SDK** (for APK building) - `flutter doctor`

### Installation Commands

#### Linux/Ubuntu
```bash
# Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Python
sudo apt-get install python3 python3-pip

# Flutter
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# PostgreSQL (optional)
sudo apt-get install postgresql postgresql-contrib
```

#### macOS
```bash
# Using Homebrew
brew install node python3 postgresql
brew install --cask flutter
```

#### Windows
```powershell
# Using Chocolatey
choco install nodejs python postgresql flutter
```

## Quick Start (Automated)

### Option 1: Run Demo Script
```bash
# Make script executable
chmod +x run_demo.sh

# Run complete demo setup
./run_demo.sh
```

This script will:
1. ✅ Check all dependencies
2. 🔧 Install Node.js and Python packages
3. 🗄️ Start database services
4. 🚀 Start all APIs (Backend, ML, Blockchain)
5. 🌱 Seed demo data (P-001 to P-020)
6. 🔲 Generate QR code images
7. 📱 Build APK with demo mode enabled
8. 🏥 Perform health checks

## Manual Setup (Step by Step)

### Step 1: Install Dependencies
```bash
# Backend dependencies
cd backend/nodejs
npm install
cd ../..

# Testing scripts dependencies
cd testing/scripts
npm install
cd ../..

# ML API dependencies
cd ml
pip install flask requests qrcode[pil]
cd ..
```

### Step 2: Start Services

#### Terminal 1: Backend API
```bash
cd backend/nodejs
node server.js
# Should show: Server running on port 3000
```

#### Terminal 2: ML API
```bash
cd ml
python3 ml_api_simple.py
# Should show: ML API running on http://localhost:5000
```

#### Terminal 3: Blockchain API
```bash
cd blockchain
node mock_blockchain_api.js
# Should show: Mock Blockchain API running on http://localhost:6000
```

### Step 3: Seed Database
```bash
cd testing/scripts
node seed_demo_data.js
# Should show: Demo data seeding completed successfully!
```

### Step 4: Generate QR Codes
```bash
cd tools
python3 gen_qr.py
# Should create sample_qr/P-001.png to P-020.png
```

### Step 5: Build Flutter APK
```bash
# Install Flutter dependencies
flutter pub get

# Build APK with demo mode
flutter build apk --release --dart-define=USE_DEV_AUTH=true
```

## Testing the Demo

### Health Checks
```bash
# Backend API
curl http://localhost:3000/api/health

# ML API
curl http://localhost:5000/health

# Blockchain API
curl http://localhost:6000/health

# Test part data
curl http://localhost:3000/api/parts/P-001
```

### Install APK on Device
```bash
# Connect Android device via USB
adb devices

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk
# OR if copied to root:
adb install railway_parts_demo.apk
```

### Demo Flow Testing

#### Method 1: QR Code Scanning
1. 📱 Open the Railway Parts app on device
2. 🔍 Tap "Scan QR Code" button
3. 🖥️ Open `sample_qr/P-001.png` on laptop screen
4. 📷 Point device camera at laptop screen to scan
5. ✅ Verify app shows part details, ML analysis, and blockchain verification

#### Method 2: Manual Entry
1. 📱 Open the Railway Parts app on device
2. 🔍 Tap "Scan QR Code" button
3. ⌨️ Tap keyboard icon for manual entry
4. 📝 Enter "P-001" and tap Submit
5. ✅ Verify same results as QR scanning

#### Method 3: Gallery Picker
1. 📱 Save `sample_qr/P-001.png` to device gallery
2. 🔍 Tap "Scan QR Code" button
3. 🖼️ Tap gallery icon and select saved QR image
4. ✅ Verify QR code is detected and processed

## Expected Results for P-001

### Part Information
- **Name**: Railway Part P-001
- **Part Number**: RP-2024-001
- **Category**: brake_system/electrical/track_system/signaling
- **Status**: active
- **Vendor**: One of the 5 seeded vendors
- **Warranty**: 12/24/36/48 months

### ML Health Analysis
- **Risk Score**: ~30% (deterministic based on part ID)
- **Anomaly**: false (for most parts)
- **Advice**: "No urgent action required" or similar
- **Source**: demo_fallback (unless trained model exists)

### Blockchain Verification
- **Verified**: true (for most parts except P-003)
- **Transaction**: 0xDEMO001 or similar
- **Block**: Random number 10000+
- **Timestamp**: Current timestamp

### Inspection History
- 1-3 inspection records per part
- Mix of passed/failed results
- Realistic inspection dates and scores

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Find process using port
lsof -i :3000
lsof -i :5000
lsof -i :6000

# Kill process
kill -9 <PID>
```

#### Database Connection Failed
```bash
# Start PostgreSQL
sudo systemctl start postgresql  # Linux
brew services start postgresql   # macOS

# Or use SQLite fallback (automatic)
```

#### Flutter Build Failed
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release --dart-define=USE_DEV_AUTH=true
```

#### QR Scanner Not Working
- Ensure camera permissions are granted
- Try manual entry as fallback
- Check device camera functionality
- Ensure good lighting for QR scanning

#### API Calls Failing
- Verify all services are running (health checks)
- Check Android emulator uses 10.0.2.2 instead of localhost
- Ensure CORS is properly configured
- Check network connectivity

### Logs and Debugging
```bash
# Check service logs
tail -f logs/run_demo.log

# Flutter logs
flutter logs

# Android device logs
adb logcat | grep flutter
```

## Demo Script Variations

### Development Mode
```bash
# Start services without building APK
./run_demo.sh --dev-only
```

### Production Mode
```bash
# Build with Firebase auth enabled
flutter build apk --release --dart-define=USE_DEV_AUTH=false
```

### Clean Restart
```bash
# Stop all services and clean
pkill -f "node server.js"
pkill -f "ml_api_simple.py"
pkill -f "mock_blockchain_api.js"
rm -rf logs/*.pid
```

## Success Criteria

✅ **All services start successfully**
- Backend API responds on port 3000
- ML API responds on port 5000  
- Blockchain API responds on port 6000

✅ **Database seeded with demo data**
- 20 parts (P-001 to P-020)
- 5 vendors
- Multiple inspection records

✅ **QR codes generated**
- 20 PNG files in sample_qr/
- Each contains corresponding part ID

✅ **APK builds successfully**
- No compilation errors
- Demo mode enabled
- File size reasonable (~50-100MB)

✅ **End-to-end flow works**
- App launches in demo mode
- QR scanning/manual entry works
- Part details display correctly
- ML analysis shows risk score
- Blockchain verification shows status
- All UI elements render properly

## Performance Benchmarks

- **App startup**: < 3 seconds
- **QR scan detection**: < 2 seconds
- **API response time**: < 1 second per endpoint
- **Full data load**: < 5 seconds total
- **APK size**: < 100MB

## Demo Presentation Tips

1. **Prepare backup methods**: Have manual entry ready if QR scanning fails
2. **Test beforehand**: Run through complete flow before demo
3. **Show logs**: Display service logs to prove real API calls
4. **Explain architecture**: Point out the 3 separate services working together
5. **Highlight features**: ML predictions, blockchain verification, offline capability
6. **Have fallbacks**: Screenshots ready if live demo fails

---

**📞 Support**: If issues persist, check logs in `logs/run_demo.log` and verify all prerequisites are installed correctly.