# Railway Parts Admin Dashboard

## Overview
Flutter Web-based admin dashboard for managing railway parts inventory and inspections with real-time data integration.

## Features

### Inventory Management
- **Parts Listing**: DataTable with search and filtering
- **CRUD Operations**: Create, read, update, delete parts
- **Status Management**: Active, inactive, maintenance states
- **Stock Monitoring**: Quantity tracking and alerts

### Inspections Management
- **Inspection Records**: Comprehensive inspection data table
- **Result Tracking**: Pass/fail/pending status with scores
- **Summary Dashboard**: Statistics cards showing inspection metrics
- **Detailed Views**: Full inspection details with remarks

### API Integration
- **REST API**: HTTP client for backend communication
- **Error Handling**: Graceful fallback to mock data
- **Real-time Updates**: Automatic data refresh
- **Offline Support**: Mock data when API unavailable

## Architecture

### Models
- `Part`: Inventory item model with JSON serialization
- `Inspection`: Quality control record model

### Services
- `ApiService`: HTTP client for backend API communication
- Mock data fallback for development/demo

### Screens
- `DashboardScreen`: Main navigation with tabs
- `InventoryScreen`: Parts management interface
- `InspectionsScreen`: Inspections management interface

## Installation

```bash
# Install dependencies
flutter pub get

# Run in development
flutter run -d chrome

# Build for production
flutter build web
```

## API Endpoints

### Parts
- `GET /api/parts` - List all parts
- `POST /api/parts` - Create new part
- `PUT /api/parts/:id` - Update part
- `DELETE /api/parts/:id` - Delete part

### Inspections
- `GET /api/inspections` - List all inspections
- `POST /api/inspections` - Create new inspection

## Configuration

Update API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-api-server:3000/api';
```

## Features Detail

### Inventory Screen
- **Search**: Real-time search across part name, number, category
- **Filters**: Status-based filtering (active/inactive/maintenance)
- **Data Table**: Sortable columns with responsive design
- **Actions**: Edit and delete operations with confirmation
- **Status Chips**: Color-coded status indicators

### Inspections Screen
- **Summary Cards**: Total, passed, failed, pending counts
- **Search**: Search by part name, inspector, remarks
- **Result Filters**: Filter by inspection results
- **Detailed View**: Modal with complete inspection information
- **Date Formatting**: User-friendly date display

### Responsive Design
- **Web Optimized**: Designed for desktop/tablet use
- **DataTable2**: Enhanced data tables with fixed headers
- **Responsive Layout**: Adapts to different screen sizes
- **Material Design**: Consistent UI following Material guidelines

## Data Models

### Part Model
```dart
{
  "id": "string",
  "name": "string",
  "partNumber": "string",
  "category": "string",
  "quantity": "number",
  "price": "number",
  "status": "string",
  "location": "string",
  "vendorName": "string",
  "createdAt": "datetime"
}
```

### Inspection Model
```dart
{
  "id": "string",
  "partId": "string",
  "partName": "string",
  "inspectorName": "string",
  "inspectionDate": "datetime",
  "result": "string",
  "score": "number",
  "remarks": "string",
  "createdAt": "datetime"
}
```

## Development

### Project Structure
```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── part.dart         # Part model
│   └── inspection.dart   # Inspection model
├── services/             # API services
│   └── api_service.dart  # HTTP client
├── screens/              # UI screens
│   ├── dashboard_screen.dart
│   ├── inventory_screen.dart
│   └── inspections_screen.dart
└── widgets/              # Reusable widgets
```

### Dependencies
- `http`: REST API communication
- `data_table_2`: Enhanced data tables
- `flutter_riverpod`: State management (optional)

## Deployment

### Web Deployment
```bash
# Build for web
flutter build web --release

# Deploy to web server
cp -r build/web/* /var/www/html/
```

### Docker Deployment
```dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
EXPOSE 80
```

## Mock Data
When API is unavailable, the app uses realistic mock data:
- 3 sample parts with different categories
- 3 sample inspections with various results
- Proper data relationships and realistic values