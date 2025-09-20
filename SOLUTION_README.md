# QRail - Complete Railway Inspection System

## 🚀 Production-Ready Solution

This is a complete, production-quality Flutter + Firebase + Node.js application for railway parts inspection and management. The system provides role-based access control with distinct workflows for Vendors, Inspectors, and Users.

## ✨ Key Features Implemented

### 🏭 Vendor Side (Company Account)
- **Generate Part QR**: Complete form with part details, manufacturing date, warranty, inspection intervals
- **Manage Inventory**: Real-time inventory dashboard with filtering, search, and status management
- **Firebase Integration**: All data stored in Firestore with real-time sync
- **QR Code Generation**: Dynamic QR codes linked to Firestore part IDs

### 🔍 Inspector Side (Railway User Account)
- **QR Scanning**: Advanced camera scanner with overlay and processing indicators
- **Part Details**: Complete part information display with warranty status and inspection forms
- **Scan History**: Persistent scan history with inspection results and notes
- **Real-time Updates**: Live data sync across all devices

### 👤 User Side (Basic Access)
- **QR Scanning**: Basic QR scanning functionality
- **Part Information**: View part details and basic information

## 🛠 Technical Implementation

### Frontend (Flutter)
- **Material Design 3**: Modern, responsive UI with premium animations
- **Firebase Integration**: Real-time data sync with Firestore
- **Camera Integration**: Mobile scanner with permission handling
- **State Management**: Proper state management with StreamBuilder
- **Error Handling**: Comprehensive error handling and user feedback

### Backend (Node.js)
- **Express.js API**: RESTful API endpoints for all operations
- **Firebase Admin**: Server-side Firebase integration
- **Real-time Sync**: Socket.io for live updates
- **Data Validation**: Input validation and sanitization
- **Error Handling**: Proper error responses and logging

### Database (Firestore)
- **Parts Collection**: Complete part information with metadata
- **Scan History**: Inspector scan records with timestamps
- **Users Collection**: User management with role-based access
- **Real-time Listeners**: Live data updates across clients

## 📱 Demo Mode

The app includes a comprehensive demo mode that works without Firebase:
- **Offline Functionality**: Full app functionality without internet
- **Sample Data**: Pre-populated with realistic railway parts data
- **Demo Credentials**: Easy login with predefined roles

### Demo Login Credentials
- **Inspector**: `inspector@qrail.com` / `inspector123`
- **Vendor**: `vendor@qrail.com` / `vendor123`
- **User**: `user@qrail.com` / `user123`

## 🚀 Quick Start

### 1. Flutter App
```bash
cd SIH
flutter pub get
flutter run
```

### 2. Backend Server
```bash
cd backend/nodejs
npm install
npm start
```

### 3. Firebase Setup (Optional)
1. Create Firebase project
2. Enable Firestore, Authentication, Storage
3. Download service account key
4. Update `.env` file with credentials

## 📊 Features Breakdown

### ✅ Vendor Workflow
1. **Login** → Select Vendor role
2. **Generate QR** → Fill comprehensive part form
3. **Submit** → Data saved to Firestore, QR generated
4. **Manage Inventory** → View all parts, update status, filter/search
5. **Real-time Updates** → See changes instantly

### ✅ Inspector Workflow
1. **Login** → Select Inspector role
2. **Scan QR** → Camera scanner with advanced UI
3. **View Details** → Complete part information display
4. **Add Inspection** → Pass/Fail with remarks
5. **History** → View all previous scans with filters

### ✅ Data Flow
1. **Vendor creates part** → Stored in Firestore
2. **QR generated** → Contains Firestore document ID
3. **Inspector scans** → Fetches real-time data from Firestore
4. **Inspection recorded** → Saved to scan history collection
5. **Real-time sync** → All changes reflected immediately

## 🔧 Technical Architecture

### Frontend Structure
```
lib/
├── models/           # Data models (Part, ScanHistory, User)
├── services/         # Firebase & Demo services
├── screens/          # Feature screens (QR Generator, Scanner, etc.)
├── auth_screen.dart  # Authentication with role selection
├── home_screen.dart  # Role-based dashboard
└── main.dart         # App initialization
```

### Backend Structure
```
backend/nodejs/
├── routes/           # API endpoints
├── services/         # Business logic
├── middleware/       # Authentication & validation
└── server.js         # Express server setup
```

## 🎯 Production Quality Features

### Security
- **Input Validation**: All forms validated client and server-side
- **Error Handling**: Graceful error handling with user feedback
- **Authentication**: Role-based access control
- **Data Sanitization**: Prevent injection attacks

### Performance
- **Real-time Updates**: Efficient Firestore listeners
- **Caching**: Proper data caching strategies
- **Lazy Loading**: Efficient data loading patterns
- **Optimized Queries**: Indexed Firestore queries

### User Experience
- **Premium UI**: Material Design 3 with animations
- **Responsive Design**: Works on all screen sizes
- **Loading States**: Proper loading indicators
- **Error States**: Clear error messages and recovery options
- **Offline Support**: Demo mode for offline usage

### Scalability
- **Modular Architecture**: Clean separation of concerns
- **Firebase Backend**: Scalable cloud infrastructure
- **Real-time Sync**: Handles multiple concurrent users
- **API Design**: RESTful APIs for easy integration

## 🔄 Real-time Synchronization

The system ensures all data is synchronized in real-time:
- **Part Creation**: Instantly available for scanning
- **Inventory Updates**: Live status changes across all devices
- **Scan History**: Immediate updates to inspection records
- **Status Changes**: Real-time part status modifications

## 📈 Analytics & Reporting

Backend includes analytics endpoints for:
- **Total Parts**: Count by vendor/status
- **Scan Statistics**: Inspection rates and results
- **Performance Metrics**: Pass/fail rates
- **Historical Data**: Time-based analytics

## 🛡 Error Handling

Comprehensive error handling at all levels:
- **Network Errors**: Graceful fallback to demo mode
- **Validation Errors**: Clear user feedback
- **Permission Errors**: Proper permission requests
- **Data Errors**: Robust error recovery

## 🎨 UI/UX Highlights

- **Premium Design**: Modern gradients and animations
- **Role-based Colors**: Different color schemes per role
- **Intuitive Navigation**: Clear user flows
- **Responsive Layout**: Adapts to all screen sizes
- **Accessibility**: Proper contrast and touch targets

## 📝 Code Quality

- **Clean Architecture**: Separation of concerns
- **Type Safety**: Proper Dart typing
- **Documentation**: Comprehensive code comments
- **Error Handling**: Try-catch blocks everywhere
- **Validation**: Input validation at all levels

This solution provides a complete, production-ready railway inspection system with all requested features implemented and working seamlessly together.