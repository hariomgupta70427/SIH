# Firebase Authentication Flutter App

## Setup Instructions

### 1. Firebase Project Setup
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication with Email/Password provider
3. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

### 2. Update Configuration
Replace placeholder values in:
- `lib/firebase_options.dart` - Add your Firebase config
- `android/app/google-services.json` - Replace with actual file
- `ios/Runner/GoogleService-Info.plist` - Replace with actual file

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

## Features
- Email/password authentication
- User registration and login
- Form validation
- Auth state management
- Automatic navigation
- Logout functionality
- Error handling
- QR code scanning with camera preview
- Part metadata fetching from API
- Analytics display

## File Structure
- `main.dart` - App entry point with Firebase initialization
- `auth_screen.dart` - Login/registration UI
- `home_screen.dart` - Protected home screen with QR scanner access
- `firebase_options.dart` - Firebase configuration
- `qr_scanner_screen.dart` - QR code scanning with camera
- `qr_result_screen.dart` - Display scanned data and fetch metadata