#!/bin/bash

echo "🚀 Building Supermarket System for Android..."
echo ""

# Install dependencies
echo "📦 Installing Flutter packages..."
flutter pub get
flutter pub upgrade

# Build debug APK
echo ""
echo "🔨 Building Android APK (Debug)..."
flutter build apk --debug --verbose

# Check if build successful
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-debug.apk"
    echo "📏 APK size: $(du -h build/app/outputs/flutter-apk/app-debug.apk | cut -f1)"
else
    echo ""
    echo "❌ Build failed!"
    echo "🔍 Check the logs above for errors."
    exit 1
fi