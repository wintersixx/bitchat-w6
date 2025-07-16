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

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  No .env file found. Creating from template...${NC}"
    if [ -f ".env.template" ]; then
        cp .env.template .env
        echo -e "${RED}❌ Please edit .env with your Apple Developer Team ID and bundle prefix${NC}"
        echo -e "${YELLOW}   Then run ./generate.sh again${NC}"
        exit 1
    else
        echo -e "${RED}❌ No .env.template found. Please create .env manually${NC}"
        exit 1
    fi
fi

# Source environment variables
echo -e "${GREEN}📦 Loading environment variables...${NC}"
source .env

# Validate required variables
if [ -z "$BITCHAT_TEAM_ID" ] || [ "$BITCHAT_TEAM_ID" = "XXXXXXXXXX" ]; then
    echo -e "${RED}❌ BITCHAT_TEAM_ID not set in .env file${NC}"
    exit 1
fi

if [ -z "$BITCHAT_BUNDLE_PREFIX" ] || [ "$BITCHAT_BUNDLE_PREFIX" = "com.yourcompany.bitchat" ]; then
    echo -e "${RED}❌ BITCHAT_BUNDLE_PREFIX not set in .env file${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Using Team ID: $BITCHAT_TEAM_ID${NC}"
echo -e "${GREEN}✅ Using Bundle: $BITCHAT_BUNDLE_PREFIX${NC}"

# Replace placeholders in template and create project.yml
echo -e "${GREEN}🔄 Replacing placeholders...${NC}"
sed "s|__TEAM_ID__|$BITCHAT_TEAM_ID|g; s|__BUNDLE_PREFIX__|$BITCHAT_BUNDLE_PREFIX|g" project.yml.template > project.yml

# Generate Xcode project
echo -e "${GREEN}🏗️  Generating Xcode project...${NC}"
xcodegen generate

echo -e "${GREEN}🎉 Project generated successfully!${NC}"
echo -e "${YELLOW}💡 You can now open bitchat.xcodeproj${NC}" 