# 🚀 Railway Parts Management System - Quick Start Guide

## 📱 **What This System Does**

A complete **Railway Parts Inventory Management System** with:
- **QR Code Scanning** for parts tracking
- **Firebase Authentication** and offline sync
- **Real-time inventory management**
- **Predictive maintenance** with ML
- **Blockchain traceability**
- **Admin dashboard** for management

---

## 🏃♂️ **Build APK in 3 Steps**

### **Step 1: Install Flutter**
```bash
# Download Flutter SDK from: https://flutter.dev/docs/get-started/install
# Add Flutter to your PATH
# Install Android Studio from: https://developer.android.com/studio
```

### **Step 2: Verify Setup**
```bash
flutter doctor
# Should show ✓ for Flutter, Android toolchain, and Android Studio
```

### **Step 3: Build APK**
```bash
# Option A: Use the batch script (Windows)
double-click build_apk.bat

# Option B: Manual commands
cd "d:\Work\Github Repo\SIH"
flutter clean
flutter pub get
flutter build apk --release
```

**APK Location:** `build\app\outputs\flutter-apk\app-release.apk`

---

## 📋 **System Components Built**

### 🔥 **1. Flutter Mobile App**
- **Authentication**: Firebase login/register
- **QR Scanner**: Camera-based QR code scanning
- **Part Details**: Display part info, vendor, status
- **Offline Sync**: Works without internet
- **Analytics**: Usage statistics and performance

### 🖥️ **2. Admin Web Dashboard**
- **Inventory Management**: Add/edit/delete parts
- **Inspection Records**: Quality control tracking
- **Data Tables**: Search, filter, sort functionality
- **Real-time Updates**: Live data synchronization

### 🔗 **3. Backend API (Node.js)**
- **REST API**: Complete CRUD operations
- **PostgreSQL Database**: Scalable data storage
- **QR Code Mapping**: Link QR codes to parts
- **Vendor Management**: Supplier information

### 🤖 **4. ML & AI Features**
- **Predictive Maintenance**: Failure prediction
- **Anomaly Detection**: Unusual pattern detection
- **Performance Analytics**: Usage optimization

### ⛓️ **5. Blockchain Integration**
- **Smart Contract**: Immutable part history
- **Traceability**: Complete supply chain tracking
- **Ethereum Compatible**: Deploy on any EVM network

### 🔄 **6. Portal Integration**
- **UDM Scraper**: Indian Railways data sync
- **TMS Integration**: Track management data
- **Automated Sync**: Scheduled data updates

### 🧪 **7. Testing Suite**
- **Integration Tests**: End-to-end workflows
- **API Testing**: All endpoints validated
- **Database Seeding**: Sample data generation
- **Performance Testing**: Load and stress tests

### 🚀 **8. Production Deployment**
- **Docker Containers**: Scalable deployment
- **CI/CD Pipeline**: Automated builds
- **Multi-platform**: Android, iOS, Web
- **Monitoring**: Health checks and logging

---

## 📱 **App Features Demo**

### **Login Screen**
- Firebase authentication
- Email/password login
- User registration

### **Home Screen**
- Welcome message
- QR scan button
- Logout option

### **QR Scanner**
- Camera preview
- Real-time QR detection
- Flash toggle
- Scanning frame overlay

### **Part Details**
- Part name and number
- Vendor information
- Current status
- Analytics data
- Action buttons

---

## 🔧 **Technical Stack**

### **Frontend**
- **Flutter 3.16+** - Cross-platform mobile
- **Material Design** - UI components
- **Firebase SDK** - Authentication & sync

### **Backend**
- **Node.js + Express** - REST API server
- **PostgreSQL** - Primary database
- **Redis** - Caching layer

### **Mobile Features**
- **Camera API** - QR code scanning
- **Offline Storage** - Local data persistence
- **Push Notifications** - Real-time alerts

### **Security**
- **Firebase Auth** - Secure authentication
- **HTTPS/TLS** - Encrypted communication
- **Input Validation** - SQL injection prevention

---

## 🎯 **Use Cases**

### **For Railway Staff**
1. **Scan QR codes** on railway parts
2. **View part details** instantly
3. **Check maintenance history**
4. **Update part status**
5. **Generate reports**

### **For Managers**
1. **Monitor inventory** in real-time
2. **Track part usage** and performance
3. **Schedule maintenance** proactively
4. **Manage vendors** and suppliers
5. **Analyze trends** and patterns

### **For Inspectors**
1. **Record inspections** digitally
2. **Upload photos** and notes
3. **Generate QR codes** for new parts
4. **Track quality metrics**
5. **Create audit trails**

---

## 🚨 **Troubleshooting**

### **Build Issues**
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Check Flutter setup
flutter doctor

# Update Flutter
flutter upgrade
```

### **Android Issues**
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Update Android SDK
# Open Android Studio > SDK Manager > Update
```

### **Firebase Issues**
- Verify `google-services.json` is in `android/app/`
- Check Firebase project configuration
- Ensure package name matches: `com.sih.qrail`

---

## 📞 **Support**

### **Documentation**
- Flutter: https://flutter.dev/docs
- Firebase: https://firebase.google.com/docs
- Android: https://developer.android.com/docs

### **Common Commands**
```bash
# Run in debug mode
flutter run

# Build APK
flutter build apk --release

# Install on device
flutter install

# View logs
flutter logs
```

---

## 🎉 **Success!**

After building, you'll have:
- **APK file** ready for installation
- **Complete source code** for customization
- **Documentation** for maintenance
- **Testing suite** for validation
- **Deployment scripts** for production

**Install the APK on your Android device and start scanning QR codes!**