#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Error: No version supplied."
  exit 1
fi

echo "Updating version to $VERSION..."
# Update MARKETING_VERSION in project.pbxproj
# Using sed to replace the value. Assumes format: MARKETING_VERSION = 1.0;
sed -i '' "s/MARKETING_VERSION = .*;/MARKETING_VERSION = $VERSION;/g" floatpane.xcodeproj/project.pbxproj

echo "Building version $VERSION..."

# Clean build directory
rm -rf build
mkdir -p build

# Build for ARM64
echo "Building ARM64..."
xcodebuild -scheme floatpane -configuration Release -archivePath ./build/floatpane-arm64.xcarchive -arch arm64 archive -quiet CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
# Extract app
cp -r ./build/floatpane-arm64.xcarchive/Products/Applications/floatpane.app ./build/floatpane-arm64.app
# Create DMG
hdiutil create -volname "FloatPane $VERSION" -srcfolder ./build/floatpane-arm64.app -ov -format UDZO "floatpane-$VERSION-arm64.dmg"

# Build for x86_64
echo "Building x86_64..."
xcodebuild -scheme floatpane -configuration Release -archivePath ./build/floatpane-x64.xcarchive -arch x86_64 archive -quiet CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
# Extract app
cp -r ./build/floatpane-x64.xcarchive/Products/Applications/floatpane.app ./build/floatpane-x64.app
# Create DMG
hdiutil create -volname "FloatPane $VERSION" -srcfolder ./build/floatpane-x64.app -ov -format UDZO "floatpane-$VERSION-x64.dmg"

echo "Build complete."
