# Changelog

All notable changes to the DNSR Admin Dashboard will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2025-10-31

### 🔥 Breaking Changes
- **Removed user phone number field** (`numero_telephone`) from database schema
- **Removed user status field** (`status`, `StatutUtilisateur` enum) from database schema
- **Removed deactivated_at timestamp** from database schema

### ✨ Added
- **Wilaya Filtering**: Added province/region filtering for incidents in dashboard and map views
  - New `WilayaFilterDropdown` widget
  - Dynamic population from distinct wilaya values in database
  - Filter persistence and clear functionality
- **Date Range Filtering**: Added date picker for filtering incidents by creation date
  - Calendar-based date selection
  - From/To date range support
  - Filter chips with clear buttons
- **Delete Incident**: Added ability to delete incidents with confirmation dialog
  - Confirmation prompt with incident details
  - Success/error notifications
  - Real-time list updates after deletion
- **Clickable Usernames**: Made usernames clickable to navigate to user profile page
  - Navigate from incident details to user management
  - Blue underlined link styling
  - Navigation callback pattern
- **Status History**: Enhanced status update tracking
  - Timeline view of all status changes
  - Commentaire display for each status change
  - Timestamp for each update
- **Real-time Updates**: Implemented PostgreSQL change subscriptions
  - Live incident updates without page refresh
  - Automatic marker updates on map
  - Optimistic UI updates

### 🔧 Changed
- **User Authentication**: Simplified authentication flow
  - Removed status verification (ACTIVE/DEACTIVATED check)
  - Now only verifies ADMIN role
  - Cleaner error messages
- **User Search**: Updated search functionality
  - Removed phone number search option
  - Search criteria limited to email and name
  - Removed complex Algerian phone format handling
- **User Profile Display**: Simplified user information
  - Removed phone number display
  - Removed status badges and colors
  - Cleaner profile cards
- **Edge Functions**: Updated Supabase edge function
  - Removed status validation in `sendNotification`
  - Simplified authentication checks

### 🐛 Fixed
- **setState() after dispose**: Added mounted checks before setState calls
  - Fixed crash when updating state after widget disposal
  - Added proper lifecycle management
  - Improved error handling in async operations
- **Null pointer errors**: Added null safety checks in filter chips
- **Map marker updates**: Fixed issue with markers not refreshing on filter changes
- **Real-time subscription cleanup**: Proper disposal of Supabase channels
- **Storage leak on incident deletion**: Now properly deletes associated images from storage bucket
  - Prevents storage bloat
  - Extracts file paths from URLs
  - Deletes files from Supabase storage
  - Cleans up incident_img records

### 🗑️ Removed
- `StatutUtilisateur` enum (ACTIVE, DEACTIVATED)
- `numeroTelephone` field from UserProfile model
- `status` field from UserProfile model
- Phone number search functionality
- Status-based user filtering
- Status color coding for user avatars
- `_buildStatusChip()` method in UsersPage
- `_getUserStatusColor()` method in UsersPage
- `_getStatusDisplayName()` method in UsersPage
- `_getStatusLabel()` method in ProfileDialog
- Account deactivation checks in authentication flow

### 📚 Documentation
- Updated README.md with comprehensive project documentation
- Added database schema documentation
- Added recent updates section
- Added project structure overview
- Added troubleshooting guide
- Updated .gitignore for better security
- Created CHANGELOG.md for version tracking

### 🔐 Security
- Enhanced .gitignore to protect sensitive configuration files
- Added app_config.dart and fcm_config.dart to gitignore
- Protected API keys and credentials

## [1.0.0] - 2025-10-XX

### Initial Release
- Admin authentication system
- Incident dashboard with statistics
- Google Maps integration
- User management
- Broadcast notifications
- Settings page
- Real-time updates
- Firebase Cloud Messaging integration

---

## Migration Guide (v1.0.0 → v2.0.0)

### Database Schema Changes

If migrating from v1.0.0, execute the following SQL to update your database:

```sql
-- Remove columns from utilisateurs table
ALTER TABLE utilisateurs 
DROP COLUMN IF EXISTS numero_telephone,
DROP COLUMN IF EXISTS status,
DROP COLUMN IF EXISTS deactivated_at;

-- Verify changes
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'utilisateurs';
```

### Code Migration

1. **Update Supabase Edge Functions**
   ```bash
   supabase functions deploy sendNotification
   ```

2. **Clear local cache** (if using SharedPreferences for user data)

3. **Test authentication flow** to ensure admin role verification works

4. **Verify real-time subscriptions** are working correctly

### Breaking Changes Impact

- **User Management**: Phone number search is no longer available
- **Authentication**: Status checks removed - all admin users can login
- **User Profiles**: Status field no longer displayed
- **API Responses**: UserProfile model no longer includes `numeroTelephone` or `status` fields

---

## Upgrade Instructions

### For Development

```bash
# Pull latest changes
git pull origin main

# Update dependencies
flutter pub get

# Run the app
flutter run -d chrome --no-web-resources-cdn
```

### For Production

```bash
# Build for web
flutter build web --release --no-web-resources-cdn

# Deploy edge functions
supabase functions deploy sendNotification

# Deploy web build to your hosting service
firebase deploy --only hosting
# or
# netlify deploy --prod
```

---

## Support

For issues, questions, or contributions, please visit:
- GitHub Issues: https://github.com/Redvirex/DNSR-report/issues
- GitHub Discussions: https://github.com/Redvirex/DNSR-report/discussions
