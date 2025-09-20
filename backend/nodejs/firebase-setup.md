# Firebase Setup & Configuration

## ✅ Completed Configuration

### 1. Authentication
- **Firebase Admin SDK** configured with service account
- **ID token verification** middleware
- **Role-based access control** (inspector/user roles)
- **User profile management** with Firestore

### 2. Firestore Database
- **Security rules** implemented (`firestore.rules`)
- **TTL policies** for data cleanup (90 days)
- **Optimized queries** with proper indexing
- **Real-time listeners** for live updates

### 3. Cloud Storage
- **File upload** with multer integration
- **Storage rules** with 10MB file size limit
- **Automatic cleanup** of old files
- **Public URL generation** for images

### 4. Storage Optimization
- **Periodic cleanup service** (runs daily)
- **Expired data removal** (90+ days)
- **Orphaned file cleanup**
- **Storage usage tracking**

## 🔧 Deployment Steps

### 1. Deploy Security Rules
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project
firebase init

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

### 2. Set up Firestore Indexes
```bash
# Deploy indexes (if needed)
firebase deploy --only firestore:indexes
```

### 3. Environment Variables
All Firebase credentials are configured in `.env`:
- ✅ Project ID: `smartindiahackathon-a62a3`
- ✅ Service Account credentials
- ✅ Storage bucket configuration

## 📊 API Endpoints

### Authentication
- `POST /api/auth/profile` - Create/update user profile
- `GET /api/auth/profile` - Get user profile
- `POST /api/auth/verify` - Verify token

### Inspections (Protected)
- `GET /api/inspections` - Get all inspections
- `POST /api/inspections` - Create inspection with image upload
- `PATCH /api/inspections/:id` - Update status (inspector only)
- `DELETE /api/inspections/cleanup` - Manual cleanup (inspector only)

### Analytics (Inspector Only)
- `GET /api/analytics` - Get dashboard analytics with storage usage

## 🔒 Security Features
- **Token-based authentication** for all protected routes
- **Role-based authorization** for sensitive operations
- **File size limits** (10MB max)
- **Automatic data expiration** (90 days TTL)
- **Storage quota management**

## 🧹 Optimization Features
- **Daily cleanup service** removes expired data
- **Storage usage monitoring**
- **Batch operations** for efficient database writes
- **Proper indexing** for fast queries