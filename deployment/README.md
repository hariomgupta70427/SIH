# Deployment Guide

## Overview
Complete deployment solution for Railway Parts Management System with Docker containerization, CI/CD pipelines, and offline sync capabilities.

## Components

### 1. Docker Deployment
- **Backend**: Node.js API with PostgreSQL
- **Frontend**: Flutter Web with nginx
- **Admin Dashboard**: Flutter Web admin interface
- **Database**: PostgreSQL with persistent storage
- **Cache**: Redis for performance optimization

### 2. CI/CD Pipeline
- **GitHub Actions**: Automated testing and deployment
- **Multi-stage builds**: Optimized Docker images
- **Platform builds**: Android APK, iOS, Web, Windows
- **Automated testing**: Integration and unit tests

### 3. Offline Sync
- **Firebase Integration**: Firestore and Realtime Database
- **Automatic Sync**: Queue operations when offline
- **Connectivity Monitoring**: Real-time network status
- **Data Persistence**: Local caching with sync status

## Quick Start

### Docker Deployment
```bash
# Clone repository
git clone <repository-url>
cd railway-parts-management

# Copy environment file
cp .env.example .env
# Edit .env with your configuration

# Deploy with Docker Compose
cd deployment/docker
docker-compose up -d

# Check service status
docker-compose ps
```

### Manual Deployment
```bash
# Run deployment script
chmod +x deployment/scripts/deploy.sh
./deployment/scripts/deploy.sh

# Available commands:
./deployment/scripts/deploy.sh build    # Build images
./deployment/scripts/deploy.sh start    # Start services
./deployment/scripts/deploy.sh status   # Check status
./deployment/scripts/deploy.sh logs     # View logs
```

## Docker Configuration

### Services
- **database**: PostgreSQL 15 with persistent storage
- **backend**: Node.js API server (port 3000)
- **frontend**: Flutter Web app (port 80)
- **admin**: Admin dashboard (port 8080)
- **redis**: Cache server (port 6379)

### Environment Variables
```bash
# Database
DB_NAME=inventory_db
DB_USER=postgres
DB_PASSWORD=your_secure_password
DB_HOST=database

# API
NODE_ENV=production
PORT=3000

# Firebase (for offline sync)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key
```

### Health Checks
All services include health checks:
- **Database**: `pg_isready`
- **Backend**: `curl /health`
- **Frontend**: `curl /`
- **Redis**: Built-in health check

## CI/CD Pipeline

### GitHub Actions Workflow
```yaml
# Triggers
- Push to main/develop branches
- Pull requests to main

# Jobs
1. Test: Run unit and integration tests
2. Build: Create Docker images and Flutter builds
3. Deploy: Deploy to staging and production
```

### Build Artifacts
- **Android**: APK files for different architectures
- **iOS**: IPA file (requires macOS runner)
- **Web**: Optimized web build
- **Windows**: Executable package
- **Docker**: Multi-platform container images

### Deployment Stages
1. **Staging**: Automatic deployment on main branch
2. **Production**: Manual approval required
3. **Rollback**: Previous version restoration

## Flutter Builds

### Build Script Usage
```bash
# Build for all platforms
./deployment/scripts/build_flutter.sh all

# Build specific platform
./deployment/scripts/build_flutter.sh android
./deployment/scripts/build_flutter.sh web
./deployment/scripts/build_flutter.sh ios
```

### Build Outputs
```
release/
├── railway-parts-app-arm64.apk     # Android ARM64
├── railway-parts-app-arm32.apk     # Android ARM32
├── railway-parts-app.aab           # Android App Bundle
├── railway-parts-app-web.tar.gz    # Web build
├── railway-parts-app-windows.zip   # Windows build
└── checksums.txt                   # SHA256 checksums
```

## Offline Sync Features

### Firebase Configuration
```dart
// Initialize offline sync
await OfflineSyncService().initialize();

// Firestore persistence (enabled by default on mobile)
await FirebaseFirestore.instance.enablePersistence();

// Realtime Database persistence
await FirebaseDatabase.instance.setPersistenceEnabled(true);
```

### Sync Capabilities
- **Automatic Queue**: Operations queued when offline
- **Connectivity Monitoring**: Real-time network status
- **Conflict Resolution**: Last-write-wins strategy
- **Status Tracking**: Sync status indicators in UI

### Usage Example
```dart
// Add data with offline support
await OfflineSyncService().addPart({
  'name': 'Brake Pad',
  'qrCode': 'QR001',
  'status': 'active'
});

// Monitor sync status
StreamBuilder<bool>(
  stream: OfflineSyncService().syncStatusStream,
  builder: (context, snapshot) {
    final isOnline = snapshot.data ?? true;
    return Icon(isOnline ? Icons.cloud_done : Icons.cloud_off);
  },
)
```

## Production Deployment

### Server Requirements
- **CPU**: 2+ cores
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 50GB+ SSD
- **Network**: Stable internet connection
- **OS**: Ubuntu 20.04+ or similar

### Security Considerations
- **HTTPS**: SSL/TLS certificates required
- **Firewall**: Restrict access to necessary ports
- **Database**: Secure credentials and network isolation
- **Backup**: Regular database backups
- **Monitoring**: Log aggregation and alerting

### Monitoring
```bash
# Service status
docker-compose ps

# Resource usage
docker stats

# Application logs
docker-compose logs -f backend

# Database status
docker-compose exec database pg_isready
```

### Backup Strategy
```bash
# Database backup
./deployment/scripts/deploy.sh backup

# Restore from backup
docker-compose exec database psql -U postgres -d inventory_db < backup.sql
```

## Troubleshooting

### Common Issues

**Service Won't Start:**
```bash
# Check logs
docker-compose logs service_name

# Restart service
docker-compose restart service_name
```

**Database Connection:**
```bash
# Check database status
docker-compose exec database pg_isready

# Connect to database
docker-compose exec database psql -U postgres -d inventory_db
```

**Build Failures:**
```bash
# Clean Flutter cache
flutter clean && flutter pub get

# Rebuild Docker images
docker-compose build --no-cache
```

**Offline Sync Issues:**
```bash
# Check Firebase configuration
# Verify network connectivity
# Clear app data and re-sync
```

### Performance Optimization
- **Database**: Add indexes for frequently queried fields
- **API**: Implement caching with Redis
- **Frontend**: Enable gzip compression
- **Images**: Optimize Docker image sizes

## File Structure
```
deployment/
├── docker/
│   ├── Dockerfile.backend         # Backend container
│   ├── Dockerfile.flutter         # Flutter web container
│   ├── docker-compose.yml         # Service orchestration
│   └── nginx.conf                 # Web server config
├── scripts/
│   ├── deploy.sh                  # Main deployment script
│   └── build_flutter.sh           # Flutter build script
├── ci/
│   └── github-actions.yml         # CI/CD pipeline
└── README.md                      # This file

lib/services/
└── offline_sync_service.dart      # Firebase offline sync
```