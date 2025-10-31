#!/bin/bash

# DNSR Admin - Secure Production Build Script
# This script builds the app and injects environment variables at build time
# Usage: ./secure_build.sh

set -e  # Exit on error

echo "🔒 DNSR Admin - Secure Production Build"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo -e "${RED}Error: .env.production file not found${NC}"
    echo ""
    echo "Please create .env.production with your production API keys:"
    echo ""
    echo "SUPABASE_URL=your_production_supabase_url"
    echo "SUPABASE_ANON_KEY=your_production_anon_key"
    echo "GOOGLE_MAPS_API_KEY=your_production_google_maps_key"
    echo "FCM_VAPID_KEY=your_production_firebase_vapid_key"
    echo ""
    exit 1
fi

# Load environment variables from .env.production
echo "📝 Loading production environment variables..."
export $(cat .env.production | grep -v '^#' | xargs)

# Validate required variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ] || [ -z "$GOOGLE_MAPS_API_KEY" ]; then
    echo -e "${RED}Error: Missing required environment variables${NC}"
    echo "Please ensure .env.production contains:"
    echo "  - SUPABASE_URL"
    echo "  - SUPABASE_ANON_KEY"
    echo "  - GOOGLE_MAPS_API_KEY"
    exit 1
fi

echo -e "${GREEN}✓ Environment variables loaded${NC}"
echo ""

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Build for web
echo "🏗️  Building Flutter web app..."
flutter build web --release --no-web-resources-cdn --dart-define=SUPABASE_URL="$SUPABASE_URL" --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" --dart-define=GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY"
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# Inject environment variables into index.html using meta tags
echo "💉 Injecting environment variables into index.html..."
INDEX_FILE="build/web/index.html"

# Create backup
cp "$INDEX_FILE" "$INDEX_FILE.backup"

# Escape special characters in the values for sed
SUPABASE_URL_ESCAPED=$(echo "$SUPABASE_URL" | sed 's/[&/\]/\\&/g')
SUPABASE_ANON_KEY_ESCAPED=$(echo "$SUPABASE_ANON_KEY" | sed 's/[&/\]/\\&/g')
GOOGLE_MAPS_API_KEY_ESCAPED=$(echo "$GOOGLE_MAPS_API_KEY" | sed 's/[&/\]/\\&/g')

# Update existing meta tags with actual values
sed -i 's|<meta name="supabase-url" content="">|<meta name="supabase-url" content="'"$SUPABASE_URL_ESCAPED"'">|g' "$INDEX_FILE"
sed -i 's|<meta name="supabase-anon-key" content="">|<meta name="supabase-anon-key" content="'"$SUPABASE_ANON_KEY_ESCAPED"'">|g' "$INDEX_FILE"
sed -i 's|<meta name="google-maps-key" content="">|<meta name="google-maps-key" content="'"$GOOGLE_MAPS_API_KEY_ESCAPED"'">|g' "$INDEX_FILE"

echo -e "${GREEN}✓ Environment variables injected${NC}"
echo ""

# Create _redirects file for Netlify
echo "📄 Creating Netlify _redirects file..."
echo "/*    /index.html   200" > build/web/_redirects
echo -e "${GREEN}✓ _redirects file created${NC}"
echo ""

# Create _headers file for security
echo "🔒 Creating security headers..."
cat > build/web/_headers << 'EOF'
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: no-referrer
  Permissions-Policy: geolocation=(), microphone=(), camera=()

/assets/*
  Cache-Control: public, max-age=31536000, immutable

/*.js
  Cache-Control: public, max-age=31536000, immutable

/*.css
  Cache-Control: public, max-age=31536000, immutable

/index.html
  Cache-Control: no-cache, no-store, must-revalidate

/flutter_service_worker.js
  Cache-Control: no-cache, no-store, must-revalidate
EOF
echo -e "${GREEN}✓ Security headers created${NC}"
echo ""

# Show build info
echo "📊 Build Information:"
echo "===================="
echo "Output directory: build/web"
echo "Supabase URL: $SUPABASE_URL"
echo "Google Maps API Key: ${GOOGLE_MAPS_API_KEY:0:20}..."
echo ""

# Calculate build size
BUILD_SIZE=$(du -sh build/web | cut -f1)
echo "Build size: $BUILD_SIZE"
echo ""

echo -e "${GREEN}✅ Production build complete!${NC}"
echo ""
echo "📤 Next steps:"
echo "  1. Go to https://app.netlify.com/drop"
echo "  2. Drag and drop the 'build/web' folder"
echo "  3. Wait for deployment to complete"
echo ""
echo -e "${YELLOW}⚠️  Security Reminder:${NC}"
echo "  - The Supabase Anon Key is public by design"
echo "  - Ensure Row-Level Security (RLS) is enabled in Supabase"
echo "  - Restrict Google Maps API key to your domain"
echo "  - Never commit .env.production to git"
echo ""
