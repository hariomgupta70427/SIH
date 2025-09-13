#!/bin/bash
# Flutter build script for multiple platforms

set -e

# Configuration
PROJECT_NAME="railway-parts-app"
BUILD_DIR="build"
RELEASE_DIR="release"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] $1${NC}"
}

# Clean previous builds
clean_builds() {
    log "Cleaning previous builds..."
    flutter clean
    flutter pub get
    rm -rf "$RELEASE_DIR"
    mkdir -p "$RELEASE_DIR"
}

# Build Android APK
build_android() {
    log "Building Android APK..."
    
    # Build release APK
    flutter build apk --release --split-per-abi
    
    # Copy APKs to release directory
    cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$RELEASE_DIR/${PROJECT_NAME}-arm64.apk"
    cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$RELEASE_DIR/${PROJECT_NAME}-arm32.apk"
    cp build/app/outputs/flutter-apk/app-x86_64-release.apk "$RELEASE_DIR/${PROJECT_NAME}-x64.apk"
    
    log "✓ Android APKs built successfully"
}

# Build Android App Bundle
build_android_bundle() {
    log "Building Android App Bundle..."
    
    flutter build appbundle --release
    cp build/app/outputs/bundle/release/app-release.aab "$RELEASE_DIR/${PROJECT_NAME}.aab"
    
    log "✓ Android App Bundle built successfully"
}

# Build iOS (requires macOS)
build_ios() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "Building iOS app..."
        
        flutter build ios --release --no-codesign
        
        # Create IPA (requires Xcode)
        if command -v xcodebuild &> /dev/null; then
            cd ios
            xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -archivePath "$PWD/../$RELEASE_DIR/${PROJECT_NAME}.xcarchive" archive
            xcodebuild -exportArchive -archivePath "$PWD/../$RELEASE_DIR/${PROJECT_NAME}.xcarchive" -exportPath "$PWD/../$RELEASE_DIR" -exportOptionsPlist ExportOptions.plist
            cd ..
        fi
        
        log "✓ iOS app built successfully"
    else
        warn "iOS build skipped (requires macOS)"
    fi
}

# Build Web
build_web() {
    log "Building Flutter Web..."
    
    flutter build web --release --web-renderer html
    
    # Create web archive
    cd build/web
    tar -czf "../../$RELEASE_DIR/${PROJECT_NAME}-web.tar.gz" .
    cd ../..
    
    log "✓ Web build completed successfully"
}

# Build Windows (requires Windows)
build_windows() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        log "Building Windows app..."
        
        flutter build windows --release
        
        # Create Windows archive
        cd build/windows/runner/Release
        zip -r "../../../../$RELEASE_DIR/${PROJECT_NAME}-windows.zip" .
        cd ../../../..
        
        log "✓ Windows build completed successfully"
    else
        warn "Windows build skipped (requires Windows)"
    fi
}

# Generate checksums
generate_checksums() {
    log "Generating checksums..."
    
    cd "$RELEASE_DIR"
    for file in *; do
        if [ -f "$file" ]; then
            sha256sum "$file" >> checksums.txt
        fi
    done
    cd ..
    
    log "✓ Checksums generated"
}

# Show build summary
show_summary() {
    log "Build Summary:"
    echo "─────────────────────────────────────"
    
    if [ -d "$RELEASE_DIR" ]; then
        ls -lh "$RELEASE_DIR"
        echo ""
        echo "Total size: $(du -sh "$RELEASE_DIR" | cut -f1)"
    fi
    
    echo "─────────────────────────────────────"
    log "All builds completed successfully!"
}

# Main build function
build_all() {
    log "Starting Flutter builds for $PROJECT_NAME..."
    
    clean_builds
    
    # Build for all platforms
    build_android
    build_android_bundle
    build_ios
    build_web
    build_windows
    
    generate_checksums
    show_summary
}

# Parse command line arguments
case "${1:-all}" in
    "android")
        clean_builds
        build_android
        ;;
    "bundle")
        clean_builds
        build_android_bundle
        ;;
    "ios")
        clean_builds
        build_ios
        ;;
    "web")
        clean_builds
        build_web
        ;;
    "windows")
        clean_builds
        build_windows
        ;;
    "all")
        build_all
        ;;
    "clean")
        clean_builds
        ;;
    *)
        echo "Usage: $0 [android|bundle|ios|web|windows|all|clean]"
        echo "  android  - Build Android APK"
        echo "  bundle   - Build Android App Bundle"
        echo "  ios      - Build iOS app (macOS only)"
        echo "  web      - Build Flutter Web"
        echo "  windows  - Build Windows app (Windows only)"
        echo "  all      - Build for all platforms (default)"
        echo "  clean    - Clean build artifacts"
        ;;
esac