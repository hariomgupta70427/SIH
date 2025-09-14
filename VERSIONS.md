# Version Compatibility Matrix

## System Requirements

### Runtime Versions
- **Node.js**: `>=20.0.0` (LTS)
- **NPM**: `>=10.0.0`
- **Python**: `>=3.9.0`
- **Flutter**: `>=3.22.0`
- **Dart**: `>=3.5.0`
- **Java**: `>=11` (for Android builds)
- **Android SDK**: API Level 24+ (Android 7.0+)
- **Gradle**: `8.11.1`

### Database
- **PostgreSQL**: `>=13.0` (optional, falls back to SQLite)
- **SQLite**: Built-in with Node.js

## Backend Dependencies (Node.js)

### Main Backend (`backend/nodejs/`)
```json
{
  "express": "^4.21.1",
  "sequelize": "^6.37.5", 
  "pg": "^8.13.1",
  "pg-hstore": "^2.3.4",
  "cors": "^2.8.5",
  "dotenv": "^16.4.7",
  "axios": "^1.7.9",
  "nodemon": "^3.1.9"
}
```

### Testing Scripts (`testing/scripts/`)
```json
{
  "pg": "^8.13.1",
  "uuid": "^11.0.3",
  "axios": "^1.7.9", 
  "dotenv": "^16.4.7",
  "jest": "^29.7.0"
}
```

### Blockchain (`blockchain/`)
```json
{
  "@nomicfoundation/hardhat-toolbox": "^5.0.0",
  "hardhat": "^2.22.18",
  "@openzeppelin/contracts": "^5.2.0",
  "express": "^4.21.1",
  "cors": "^2.8.5",
  "dotenv": "^16.4.7"
}
```

## Python Dependencies (ML Services)

### Full ML Stack (`ml/requirements.txt`)
```
pandas==2.2.3
numpy==1.26.4
scikit-learn==1.5.2
tensorflow==2.18.0
joblib==1.4.2
matplotlib==3.9.3
seaborn==0.13.2
flask==3.1.0
requests==2.32.3
```

### Simple ML API (`ml/requirements_simple.txt`)
```
flask==3.1.0
requests==2.32.3
qrcode[pil]==8.2
```

## Flutter Dependencies

### Main App (`pubspec.yaml`)
```yaml
environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  firebase_database: ^11.3.4
  connectivity_plus: ^6.1.0
  mobile_scanner: ^5.2.3
  http: ^1.2.2
  image_picker: ^1.1.2
  qr_code_scanner: ^1.0.1

dev_dependencies:
  flutter_lints: ^5.0.0
```

## Android Configuration

### Gradle Versions
- **Gradle Wrapper**: `7.6.4`
- **Android Gradle Plugin**: `7.4.2`
- **Kotlin**: `1.8.22`

### SDK Versions
- **Compile SDK**: `34`
- **Target SDK**: `34`
- **Min SDK**: `24` (Android 7.0+)
- **Java Version**: `1.8`

### Firebase
- **Firebase BOM**: `33.7.0`
- **Google Services**: `4.4.2`

## Version Upgrade Summary

### ✅ **Updated Components:**

#### Node.js Backend
- ✅ Express: `4.18.2` → `4.21.1`
- ✅ Sequelize: `6.35.2` → `6.37.5`
- ✅ PostgreSQL driver: `8.11.3` → `8.13.1`
- ✅ Axios: `1.6.2` → `1.7.9`
- ✅ UUID: `9.0.1` → `11.0.3`
- ✅ Nodemon: `3.0.2` → `3.1.9`
- ✅ Replaced node-fetch with axios for better compatibility

#### Python ML
- ✅ Pandas: `2.1.4` → `2.2.3`
- ✅ NumPy: `1.24.3` → `1.26.4`
- ✅ Scikit-learn: `1.3.2` → `1.5.2`
- ✅ TensorFlow: `2.15.0` → `2.18.0`
- ✅ Flask: `2.3.3` → `3.1.0`
- ✅ Matplotlib: `3.8.2` → `3.9.3`

#### Flutter
- ✅ SDK constraint: `>=3.0.0` → `>=3.5.0`
- ✅ Firebase Core: `2.24.2` → `3.8.0`
- ✅ Firebase Auth: `4.15.3` → `5.3.3`
- ✅ Cloud Firestore: `4.13.6` → `5.5.0`
- ✅ Mobile Scanner: `3.5.6` → `5.2.3`
- ✅ Connectivity Plus: `5.0.2` → `6.1.0`
- ✅ HTTP: `1.1.0` → `1.2.2`
- ✅ Flutter Lints: `3.0.0` → `5.0.0`

#### Android
- ✅ Gradle: `8.4` → `7.6.4` (stable compatibility)
- ✅ Android Gradle Plugin: `8.1.4` → `7.4.2` (stable compatibility)
- ✅ Kotlin: `1.9.10` → `1.8.22` (stable compatibility)
- ✅ Compile SDK: `34` (maintained for stability)
- ✅ Target SDK: `34` (maintained for stability)
- ✅ Java Version: `1.8` (maintained for Gradle compatibility)
- ✅ Firebase BOM: `32.7.0` → `33.7.0`

#### Blockchain
- ✅ Hardhat: `2.19.0` → `2.22.18`
- ✅ Hardhat Toolbox: `4.0.0` → `5.0.0`
- ✅ OpenZeppelin: `5.0.0` → `5.2.0`

## Compatibility Notes

### Breaking Changes Addressed
1. **Node-fetch v3**: Replaced with axios for CommonJS compatibility
2. **Java 11**: Updated from Java 8 for modern Android builds
3. **Firebase v3**: Updated imports and initialization patterns
4. **Mobile Scanner v5**: Updated API usage patterns
5. **Flask v3**: Updated import patterns and configuration

### Environment Setup
```bash
# Node.js (using nvm)
nvm install 20
nvm use 20

# Python (using pyenv)
pyenv install 3.11.0
pyenv local 3.11.0

# Flutter
flutter channel stable
flutter upgrade

# Java (for Android)
# Install OpenJDK 11 or higher
```

## Testing Commands

### Backend
```bash
cd backend/nodejs
npm install && npm test && npm start
```

### ML Service
```bash
cd ml
pip install -r requirements_simple.txt
python ml_api_simple.py
```

### Flutter
```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

### Blockchain
```bash
cd blockchain
npm install
npx hardhat compile
```

## Known Issues & Solutions

### Issue: Gradle Build Fails
**Solution**: 
- Ensure Java 8 or 11 is installed and JAVA_HOME is set correctly
- Use compatible Gradle/Android Gradle Plugin versions
- Clear Gradle cache: `gradlew clean` or delete `~/.gradle/caches`

### Issue: Firebase Auth Errors
**Solution**: Updated to Firebase v3 with proper initialization

### Issue: QR Scanner Crashes
**Solution**: Updated to mobile_scanner v5 with proper permissions

### Issue: Python Import Errors
**Solution**: Pinned exact versions in requirements.txt

---

**Last Updated**: December 2024  
**Tested On**: Windows 11, Node.js 22.11.0, Python 3.12.6, Flutter 3.35.3