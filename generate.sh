#!/bin/bash

# Build script for bitchat - replaces credentials and generates project
# Usage: ./generate.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 Generating bitchat project...${NC}"

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "Please copy .env.template to .env and set your values"
    exit 1
fi

source .env

# Validate required variables
if [ -z "$BITCHAT_TEAM_ID" ] || [ -z "$BITCHAT_BUNDLE_PREFIX" ] || [ -z "$BITCHAT_GROUP_IDENTIFIER" ] || [ -z "$BITCHAT_SERVICE_NAME" ]; then
    echo "❌ Error: Missing required environment variables"
    echo "Please check your .env file has all required values"
    exit 1
fi

echo "🔄 Generating project files..."

# Create project.yml from template
sed -e "s/__TEAM_ID__/$BITCHAT_TEAM_ID/g" \
    -e "s/__BUNDLE_PREFIX__/$BITCHAT_BUNDLE_PREFIX/g" \
    -e "s/__GROUP_IDENTIFIER__/$BITCHAT_GROUP_IDENTIFIER/g" \
    -e "s/__SERVICE_NAME__/$BITCHAT_SERVICE_NAME/g" \
    project.yml.template > project.yml

# Temporarily substitute placeholders in source files for building
find . -name "*.swift" -not -path "./bitchatTests/*" -exec sed -i '' \
    -e "s/__TEAM_ID__/$BITCHAT_TEAM_ID/g" \
    -e "s/__BUNDLE_PREFIX__/$BITCHAT_BUNDLE_PREFIX/g" \
    -e "s/__GROUP_IDENTIFIER__/$BITCHAT_GROUP_IDENTIFIER/g" \
    -e "s/__SERVICE_NAME__/$BITCHAT_SERVICE_NAME/g" \
    {} \;

# Also handle entitlements files
find . -name "*.entitlements" -exec sed -i '' \
    -e "s/__TEAM_ID__/$BITCHAT_TEAM_ID/g" \
    -e "s/__BUNDLE_PREFIX__/$BITCHAT_BUNDLE_PREFIX/g" \
    -e "s/__GROUP_IDENTIFIER__/$BITCHAT_GROUP_IDENTIFIER/g" \
    -e "s/__SERVICE_NAME__/$BITCHAT_SERVICE_NAME/g" \
    {} \;

# Generate Xcode project
echo -e "${GREEN}🏗️  Generating Xcode project...${NC}"
xcodegen generate

# Restore placeholder values in source files to keep git clean
echo "🧹 Restoring placeholders in source files..."
find . -name "*.swift" -not -path "./bitchatTests/*" -exec sed -i '' \
    -e "s/$BITCHAT_TEAM_ID/__TEAM_ID__/g" \
    -e "s/$BITCHAT_BUNDLE_PREFIX/__BUNDLE_PREFIX__/g" \
    -e "s/$BITCHAT_GROUP_IDENTIFIER/__GROUP_IDENTIFIER__/g" \
    -e "s/$BITCHAT_SERVICE_NAME/__SERVICE_NAME__/g" \
    {} \;

find . -name "*.entitlements" -exec sed -i '' \
    -e "s/$BITCHAT_TEAM_ID/__TEAM_ID__/g" \
    -e "s/$BITCHAT_BUNDLE_PREFIX/__BUNDLE_PREFIX__/g" \
    -e "s/$BITCHAT_GROUP_IDENTIFIER/__GROUP_IDENTIFIER__/g" \
    -e "s/$BITCHAT_SERVICE_NAME/__SERVICE_NAME__/g" \
    {} \;

echo -e "${GREEN}🎉 Project generated successfully!${NC}"
echo -e "${YELLOW}💡 You can now open bitchat.xcodeproj${NC}"
echo -e "${YELLOW}📝 Source files restored to placeholder values for git${NC}" 