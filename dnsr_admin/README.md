# 🚦 DNSR Admin Dashboard

The **DNSR Admin Dashboard** is a Flutter web application designed for administrators of the DNSR platform.  
It provides tools to manage incidents, user accounts, and application settings in real-time.

---

## 📌 Features

### 🔐 Authentication
- Secure login with email and password
- Admin role verification
- Profile management

### 📋 Incident Management
- **Dashboard View**: 
  - Real-time incident statistics
  - Recent incidents list with status filters
  - Date range filtering
  - Wilaya (province) filtering
  - Status-based filtering (Pending, In Progress, Processed)
- **Map View**: 
  - Interactive Google Maps integration
  - Custom markers with incident status colors
  - Incident clustering and details
  - Map settings customization (POI, Transit, Street View, etc.)
- **Incident Actions**:
  - View detailed incident information
  - Update incident status with comments
  - View status history timeline
  - Delete incidents with confirmation
  - View incident photos
  - Clickable username to navigate to user details

### 👥 User Management
- Search users by email or name
- View user profiles and registration details
- Paginated user list (10, 20, 50, 100 per page)
- User role display (Admin/Citizen)

### 📢 Broadcast Notifications
- Send proximity-based push notifications
- Test notification functionality
- Target users within specific radius of incidents

### ⚙️ Settings
- **Map Settings**:
  - Toggle POI display
  - Toggle transit display
  - Toggle street view control
  - Toggle map type control
  - Toggle fullscreen control
  - Set default map view (roadmap, satellite, hybrid, terrain)
- **Real-time Updates**: Manage incident subscription settings

### 🙍 Profile
- View admin profile information
- Display role and registration date

---

## 🛠️ Tech Stack
- **Flutter Web** (Dart 3.8.1, Flutter 3.32.7)
- **Supabase** (authentication, PostgreSQL database, real-time subscriptions, edge functions)
- **Firebase Cloud Messaging** (Push notifications)
- **Google Maps JavaScript API** (Interactive maps)
- **Provider** (State management)

---

## 📊 Database Schema

### Users Table (`utilisateurs`)
- `id` (UUID)
- `nom` (String)
- `prenom` (String)
- `email` (String)
- `role` (Enum: CITOYEN, ADMIN)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

### Incidents Table (`incident`)
- `id` (UUID)
- `description` (String)
- `latitude` (Double)
- `longitude` (Double)
- `wilaya` (String) - Province/region
- `statut` (Enum: EN_ATTENTE, EN_COURS, TRAITE)
- `utilisateur_id` (UUID, Foreign Key)
- `incident_type_id` (UUID, Foreign Key)
- `vehicle_type_id` (UUID, Foreign Key)
- `category_id` (UUID, Foreign Key)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.32.7 or higher)
- [Dart SDK](https://dart.dev/get-dart) (3.8.1 or higher)
- Chrome browser (for web development)
- [Supabase CLI](https://supabase.com/docs/guides/cli) (optional, for edge functions)
- API keys for:
  - Firebase Cloud Messaging
  - Supabase
  - Google Maps JavaScript API

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Redvirex/DNSR-report.git
   cd "dnsr_admin"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API keys**
   
   Create/update `lib/config/app_config.dart`:
   ```dart
   class AppConfig {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
   }
   ```

4. **Configure Firebase**
   
   Update `lib/config/fcm_config.dart` with your Firebase configuration:
   ```dart
   class FCMConfig {
     static const String vapidKey = 'YOUR_FIREBASE_VAPID_KEY';
   }
   ```

5. **Run the app**
   ```bash
   flutter run -d chrome --no-web-resources-cdn
   ```

### Edge Functions Deployment

To deploy Supabase edge functions:

```bash
supabase functions deploy sendNotification
```

---

## 📝 Recent Updates (October 2025)

### Database Schema Changes
- ✅ Removed `numero_telephone` (phone number) field from users table
- ✅ Removed `status` field from users table  
- ✅ Removed `deactivated_at` field from users table

### New Features
- ✅ Added wilaya (province) filtering for incidents
- ✅ Added date range filtering for incidents
- ✅ Added delete incident functionality with confirmation
- ✅ Added clickable usernames to navigate to user profiles
- ✅ Implemented real-time incident updates with PostgreSQL subscriptions
- ✅ Added status history timeline for incidents
- ✅ Enhanced map customization settings

### Code Improvements
- ✅ Simplified user authentication (removed status checks)
- ✅ Cleaned up user search (removed phone number search)
- ✅ Updated all models and services to match new database schema
- ✅ Fixed setState() after dispose issues with mounted checks
- ✅ Improved error handling and logging

---

## 🏗️ Project Structure

```
lib/
├── config/
│   ├── app_config.dart          # Supabase & Google Maps config
│   ├── fcm_config.dart          # Firebase config
│   └── web_config.dart          # Web-specific config
├── models/
│   ├── incident.dart            # Incident data model
│   ├── user_profile.dart        # User profile model
│   └── status_history.dart      # Status change history model
├── pages/
│   ├── login_page.dart          # Authentication page
│   ├── dashboard_page.dart      # Main dashboard
│   ├── incidents_map_page.dart  # Map view
│   ├── users_page.dart          # User management
│   ├── settings_page.dart       # App settings
│   └── broadcast_notifications_page.dart  # Push notifications
├── providers/
│   ├── admin_auth_provider.dart # Authentication state
│   └── incident_provider.dart   # Incident data & filters
├── services/
│   ├── supabase_service.dart    # Database operations
│   ├── fcm_service.dart         # Push notifications
│   └── notification_service.dart # Local notifications
└── widgets/
    ├── dashboard_sidebar.dart   # Navigation sidebar
    ├── incident_card.dart       # Incident list item
    ├── status_filter_chip.dart  # Status filter UI
    ├── wilaya_filter_dropdown.dart  # Wilaya filter UI
    └── ...

supabase/
└── functions/
    └── sendNotification/        # Edge function for FCM
        └── index.ts

```

---

## 🔧 Configuration Files

### `pubspec.yaml`
Key dependencies:
- `supabase_flutter: ^2.9.2`
- `provider: ^6.1.2`
- `shared_preferences: ^2.3.3`
- `web: ^1.1.0`

### Firebase Configuration
The app uses Firebase Cloud Messaging for push notifications. Configuration is done in:
- `web/index.html` (Firebase SDK initialization)
- `lib/config/fcm_config.dart` (VAPID key)

### Supabase Configuration
Real-time subscriptions are configured for:
- Incident updates
- Status changes
- New incident notifications

---

## 🚦 Usage

### For Administrators

1. **Login**: Use your admin email and password
2. **Dashboard**: View incident statistics and recent reports
3. **Filters**: Apply status, wilaya, and date range filters
4. **Map View**: Switch to map mode to see incidents geographically
5. **Incident Actions**: 
   - Click on an incident to view details
   - Update status with comments
   - View status history
   - Delete if necessary
6. **User Management**: Search and view user profiles
7. **Notifications**: Send proximity-based alerts to users
8. **Settings**: Customize map display and real-time update preferences

---

## 🔒 Security

### Frontend Security Approach

**Important**: This is a frontend web application. All code and API keys compiled into JavaScript are effectively public. We follow security best practices:

✅ **What We Do:**
- Use **Supabase Anon Key** (designed to be public)
- Implement **Row-Level Security (RLS)** in Supabase database
- Restrict **Google Maps API key** to production domain
- Use **secure build scripts** to inject environment variables
- Apply **security headers** (X-Frame-Options, CSP, etc.)
- Enable **HTTPS only** in production
- **Admin role verification** on authentication
- **Audit logging** for sensitive operations

❌ **What to NEVER Do:**
- Never use Supabase Service Role Key in frontend
- Never commit `.env.production` to git
- Never expose Firebase Admin SDK keys
- Never bypass RLS policies

### Security Configuration

1. **Row-Level Security (RLS)**: Enabled on all Supabase tables
2. **API Key Restrictions**: Google Maps API restricted to production domain
3. **Environment Variables**: Managed via `.env.production` (not in git)
4. **Secure Build**: Use `./secure_build.sh` for production builds
5. **Edge Functions**: Sensitive operations run server-side

For detailed security guidelines, see [SECURITY.md](SECURITY.md).

---

## 📱 Deployment

### Web Deployment

```bash
flutter build web --release --no-web-resources-cdn
```

Deploy the `build/web` directory to your hosting service (Firebase Hosting, Netlify, Vercel, etc.)

### Firebase Hosting (Example)

```bash
firebase init hosting
firebase deploy --only hosting
```

---

## 🐛 Troubleshooting

### Common Issues

1. **Map not loading**: Verify Google Maps API key in `app_config.dart`
2. **Real-time updates not working**: Check Supabase connection and RLS policies
3. **Push notifications failing**: Verify FCM configuration and VAPID key
4. **Authentication errors**: Ensure user has ADMIN role in database

### Debug Mode

Enable debug logging in Flutter:
```bash
flutter run -d chrome --no-web-resources-cdn --verbose
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Authors

- **Redvirex** - [GitHub](https://github.com/Redvirex)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Firebase for push notification services
- Google Maps for mapping functionality
