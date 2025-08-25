#!/bin/bash

# DNSR Admin Deployment Script
# This script builds the Flutter web app and configures it for deployment

set -e

echo "🚀 DNSR Admin Deployment Script"
echo "=========================================="

# Check if environment variables are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "⚠️  Warning: SUPABASE_URL and SUPABASE_ANON_KEY environment variables not set"
    echo "Using default values from code. For production, set these variables:"
    echo "export SUPABASE_URL=your_supabase_url"
    echo "export SUPABASE_ANON_KEY=your_supabase_anon_key"
    echo "export GOOGLE_MAPS_API_KEY=your_maps_api_key"
fi

# Build the Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

# Update index.html with environment variables if they exist
if [ ! -z "$SUPABASE_URL" ] && [ ! -z "$SUPABASE_ANON_KEY" ]; then
    echo "🔧 Configuring production environment..."
    
    # Update meta tags in built index.html
    sed -i.bak "s|<meta name=\"supabase-url\" content=\"\">|<meta name=\"supabase-url\" content=\"$SUPABASE_URL\">|g" build/web/index.html
    sed -i.bak "s|<meta name=\"supabase-anon-key\" content=\"\">|<meta name=\"supabase-anon-key\" content=\"$SUPABASE_ANON_KEY\">|g" build/web/index.html
    
    if [ ! -z "$GOOGLE_MAPS_API_KEY" ]; then
        sed -i.bak "s|<meta name=\"google-maps-key\" content=\"\">|<meta name=\"google-maps-key\" content=\"$GOOGLE_MAPS_API_KEY\">|g" build/web/index.html
    fi
    
    # Remove backup file
    rm build/web/index.html.bak
    
    echo "✅ Production configuration applied"
else
    echo "⚠️  Using development configuration"
fi

echo "🎉 Build completed successfully!"
echo "📁 Output directory: build/web/"
echo ""
echo "🚀 Deployment options:"
echo "1. Upload build/web/ contents to your web server"
echo "2. Use Firebase Hosting: firebase deploy"
echo "3. Use Vercel: vercel deploy build/web"
echo "4. Use Netlify: drag build/web folder to Netlify deploy"
echo ""
echo "🔒 Security Notes:"
echo "- The Supabase anon key is safe to expose in frontend"
echo "- Real security comes from Row Level Security (RLS) in Supabase"
echo "- Admin authentication is handled server-side"
