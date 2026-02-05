#!/bin/bash
# setup.sh - Automated setup script for Xtra-Neo

set -e

echo "🚀 Xtra-Neo Setup Script"
echo "========================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Flutter installation
echo -e "${YELLOW}Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found!${NC}"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -n 1)
echo -e "${GREEN}✅ Found: $FLUTTER_VERSION${NC}"
echo ""

# Check Java installation
echo -e "${YELLOW}Checking Java installation...${NC}"
if ! command -v java &> /dev/null; then
    echo -e "${RED}❌ Java not found!${NC}"
    echo "Please install Java 17 or higher"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1)
echo -e "${GREEN}✅ Found: $JAVA_VERSION${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}Installing Flutter dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Run build_runner
echo -e "${YELLOW}Running build_runner...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✅ Code generation complete${NC}"
echo ""

# Check for Twitch API keys
echo -e "${YELLOW}Checking Twitch API configuration...${NC}"
if grep -q "YOUR_TWITCH_CLIENT_ID" lib/core/constants/api_constants.dart; then
    echo -e "${RED}⚠️  Warning: Twitch API keys not configured!${NC}"
    echo ""
    echo "To use Twitch features, you need to:"
    echo "1. Go to https://dev.twitch.tv/console/apps"
    echo "2. Create a new application"
    echo "3. Copy Client ID and Client Secret"
    echo "4. Edit lib/core/constants/api_constants.dart"
    echo ""
else
    echo -e "${GREEN}✅ Twitch API keys configured${NC}"
fi
echo ""

# Create directories
echo -e "${YELLOW}Creating required directories...${NC}"
mkdir -p assets/images
mkdir -p assets/emotes
echo -e "${GREEN}✅ Directories created${NC}"
echo ""

# Setup complete
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Configure Twitch API keys (if not done)"
echo "2. Connect a device or start emulator"
echo "3. Run: flutter run"
echo ""
echo "To build APK:"
echo "  flutter build apk --release --split-per-abi"
echo ""
echo "Happy coding! 🎮"
