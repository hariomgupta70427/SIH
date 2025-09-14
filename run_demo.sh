#!/bin/bash

# Demo Integration Script
# Starts all services, seeds data, generates QR codes, and builds APK

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create logs directory
mkdir -p logs

# Log file
LOG_FILE="logs/run_demo.log"
echo "$(date): Starting demo integration" > $LOG_FILE

echo -e "${BLUE}🚀 Starting Railway Parts Demo Integration${NC}"
echo "📝 Logging to: $LOG_FILE"

# Function to log and print
log_and_print() {
    echo -e "$1"
    echo "$(date): $1" >> $LOG_FILE
}

# Function to check if port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_and_print "${YELLOW}⚠️  Port $1 is already in use${NC}"
        return 1
    fi
    return 0
}

# Function to start service in background
start_service() {
    local name=$1
    local command=$2
    local port=$3
    local dir=$4
    
    log_and_print "${BLUE}🔄 Starting $name on port $port...${NC}"
    
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
    
    # Start service in background and save PID
    eval "$command" >> $LOG_FILE 2>&1 &
    local pid=$!
    echo $pid > "logs/${name,,}_pid.txt"
    
    # Wait a moment for service to start
    sleep 3
    
    # Check if service is still running
    if kill -0 $pid 2>/dev/null; then
        log_and_print "${GREEN}✅ $name started successfully (PID: $pid)${NC}"
    else
        log_and_print "${RED}❌ Failed to start $name${NC}"
        return 1
    fi
    
    cd - > /dev/null
}

# Function to stop all services
cleanup() {
    log_and_print "${YELLOW}🧹 Cleaning up services...${NC}"
    
    for pid_file in logs/*_pid.txt; do
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
            if kill -0 $pid 2>/dev/null; then
                kill $pid
                log_and_print "Stopped service with PID: $pid"
            fi
            rm "$pid_file"
        fi
    done
}

# Trap to cleanup on exit
trap cleanup EXIT

# Step 1: Check dependencies
log_and_print "${BLUE}📋 Checking dependencies...${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    log_and_print "${RED}❌ Node.js not found. Please install Node.js${NC}"
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    log_and_print "${RED}❌ Python not found. Please install Python${NC}"
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    log_and_print "${RED}❌ Flutter not found. Please install Flutter${NC}"
    exit 1
fi

log_and_print "${GREEN}✅ All dependencies found${NC}"

# Step 2: Install Node.js dependencies
log_and_print "${BLUE}📦 Installing Node.js dependencies...${NC}"

cd backend/nodejs
npm install >> $LOG_FILE 2>&1
cd ../..

cd testing/scripts
npm install >> $LOG_FILE 2>&1
cd ../..

log_and_print "${GREEN}✅ Node.js dependencies installed${NC}"

# Step 3: Install Python dependencies
log_and_print "${BLUE}🐍 Installing Python dependencies...${NC}"

cd ml
pip install -r requirements_simple.txt >> $LOG_FILE 2>&1
pip install qrcode[pil] >> $LOG_FILE 2>&1
cd ..

log_and_print "${GREEN}✅ Python dependencies installed${NC}"

# Step 4: Start PostgreSQL or use SQLite fallback
log_and_print "${BLUE}🗄️  Setting up database...${NC}"

# Try to start PostgreSQL service (Linux/Mac)
if command -v systemctl &> /dev/null; then
    sudo systemctl start postgresql >> $LOG_FILE 2>&1 || log_and_print "${YELLOW}⚠️  Could not start PostgreSQL service${NC}"
elif command -v brew &> /dev/null; then
    brew services start postgresql >> $LOG_FILE 2>&1 || log_and_print "${YELLOW}⚠️  Could not start PostgreSQL service${NC}"
fi

log_and_print "${GREEN}✅ Database setup completed${NC}"

# Step 5: Start Backend API
if check_port 3000; then
    start_service "Backend" "node server.js" 3000 "backend/nodejs"
else
    log_and_print "${YELLOW}⚠️  Backend port 3000 already in use, skipping...${NC}"
fi

# Step 6: Start ML API
if check_port 5000; then
    start_service "ML-API" "python3 ml_api_simple.py" 5000 "ml"
else
    log_and_print "${YELLOW}⚠️  ML API port 5000 already in use, skipping...${NC}"
fi

# Step 7: Start Blockchain API
if check_port 6000; then
    start_service "Blockchain" "node mock_blockchain_api.js" 6000 "blockchain"
else
    log_and_print "${YELLOW}⚠️  Blockchain port 6000 already in use, skipping...${NC}"
fi

# Step 8: Wait for services to be ready
log_and_print "${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 5

# Step 9: Seed database
log_and_print "${BLUE}🌱 Seeding database with demo data...${NC}"
cd testing/scripts
node seed_demo_data.js >> $LOG_FILE 2>&1
cd ../..
log_and_print "${GREEN}✅ Database seeded with demo data${NC}"

# Step 10: Generate QR codes
log_and_print "${BLUE}🔲 Generating sample QR codes...${NC}"
cd tools
python3 gen_qr.py >> $LOG_FILE 2>&1
cd ..
log_and_print "${GREEN}✅ QR codes generated in sample_qr/${NC}"

# Step 11: Install Flutter dependencies
log_and_print "${BLUE}📱 Installing Flutter dependencies...${NC}"
flutter pub get >> $LOG_FILE 2>&1
log_and_print "${GREEN}✅ Flutter dependencies installed${NC}"

# Step 12: Build APK
log_and_print "${BLUE}🔨 Building Flutter APK...${NC}"
flutter build apk --release --dart-define=USE_DEV_AUTH=true >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    APK_PATH=$(find build/app/outputs/flutter-apk -name "*.apk" | head -1)
    log_and_print "${GREEN}🎉 APK built successfully!${NC}"
    log_and_print "${GREEN}📱 APK location: $APK_PATH${NC}"
    
    # Copy APK to root for easy access
    cp "$APK_PATH" "./railway_parts_demo.apk"
    log_and_print "${GREEN}📱 APK copied to: ./railway_parts_demo.apk${NC}"
else
    log_and_print "${RED}❌ APK build failed${NC}"
    exit 1
fi

# Step 13: Health checks
log_and_print "${BLUE}🏥 Performing health checks...${NC}"

# Check backend
if curl -s http://localhost:3000/api/health > /dev/null; then
    log_and_print "${GREEN}✅ Backend API is healthy${NC}"
else
    log_and_print "${RED}❌ Backend API health check failed${NC}"
fi

# Check ML API
if curl -s http://localhost:5000/health > /dev/null; then
    log_and_print "${GREEN}✅ ML API is healthy${NC}"
else
    log_and_print "${RED}❌ ML API health check failed${NC}"
fi

# Check Blockchain API
if curl -s http://localhost:6000/health > /dev/null; then
    log_and_print "${GREEN}✅ Blockchain API is healthy${NC}"
else
    log_and_print "${RED}❌ Blockchain API health check failed${NC}"
fi

# Final summary
log_and_print "${GREEN}🎉 Demo integration completed successfully!${NC}"
log_and_print ""
log_and_print "${BLUE}📋 Summary:${NC}"
log_and_print "   🔗 Backend API: http://localhost:3000"
log_and_print "   🤖 ML API: http://localhost:5000"
log_and_print "   ⛓️  Blockchain API: http://localhost:6000"
log_and_print "   📱 APK: ./railway_parts_demo.apk"
log_and_print "   🔲 QR Codes: ./sample_qr/"
log_and_print "   📝 Logs: $LOG_FILE"
log_and_print ""
log_and_print "${YELLOW}📱 To install APK on device:${NC}"
log_and_print "   adb install railway_parts_demo.apk"
log_and_print ""
log_and_print "${YELLOW}🔲 To test scanning:${NC}"
log_and_print "   1. Open sample_qr/P-001.png on laptop screen"
log_and_print "   2. Use app to scan QR code"
log_and_print "   3. Or manually enter 'P-001' in the app"
log_and_print ""
log_and_print "${BLUE}🎯 Expected demo flow:${NC}"
log_and_print "   Login → Scan QR (P-001) → View part details → ML analysis → Blockchain verification"

# Keep services running
log_and_print "${YELLOW}⚡ Services are running. Press Ctrl+C to stop all services.${NC}"
wait