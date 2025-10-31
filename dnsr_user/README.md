# 🚦 DNSR Report App

The **DNSR Report App** is a Flutter-based mobile application designed for end-users of the DNSR platform.  
It enables citizens to authenticate, manage their profiles, and report traffic incidents in Algeria with automatic location detection.

---

## 📌 Features

### 🔐 Authentication
- Email-based login using magic links (passwordless)
- Google Sign-In integration
- Secure session management with Supabase Auth

### � Profile Management
- Edit personal information (first name, last name)
- View and update profile details
- Account deletion functionality
- No phone verification required - streamlined user experience

### 🗺️ Incident Reporting
- Submit detailed incident reports with:
  - Incident category and type selection
  - Vehicle type (when applicable)
  - Description and multiple photo uploads
  - **Automatic GPS location detection**
  - **Automatic Wilaya (province) detection** using reverse geocoding
- Real-time location tracking
- Mandatory wilaya validation with retry functionality
- Confirmation notifications upon successful submission

### 📍 Additional Features
- **Route Codes**: Download PDF of Algerian route codes
- **Push Notifications**: Receive updates about nearby incidents via Firebase Cloud Messaging
- **Multi-language Support**: Arabic and French localization
- **Offline-Ready**: Location services work without constant internet

---

## 🛠️ Tech Stack

- **Flutter SDK**: ^3.8.1 (Dart)
- **Supabase**: Backend-as-a-Service (auth, database, storage, real-time)
- **Firebase Cloud Messaging**: Push notifications
- **Geolocator**: GPS location services (^14.0.2)
- **Geocoding**: Reverse geocoding for wilaya detection (^3.0.0)
- **Image Picker**: Camera and gallery photo selection
- **Provider**: State management
- **Google Sign-In**: OAuth authentication
- **flutter_dotenv**: Environment variable management

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.8.1 or higher)
- Android SDK with API level 23+ (Android 6.0 or higher)
- Active internet connection for initial setup
- API keys configured:
  - Firebase project with FCM enabled
  - Supabase project with proper RLS policies
  - Google OAuth credentials (optional, for Google Sign-In)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Redvirex/DNSR-report.git
   cd dnsr_user
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**:
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_WEB_CLIENT_ID=your_google_client_id
   FIREBASE_API_KEY=your_firebase_api_key
   FIREBASE_APP_ID=your_firebase_app_id
   FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   FIREBASE_PROJECT_ID=your_project_id
   ```

4. **Set up Firebase**:
   - Add `google-services.json` to `android/app/`
   - Configure Firebase in the Firebase Console

5. **Run the app**:
   ```bash
   flutter run
   ```

6. **Build for production**:
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

---

## 📱 Key Features Explained

### Automatic Wilaya Detection

The app uses **reverse geocoding** to automatically detect the user's wilaya (province) when reporting incidents:

1. User clicks "Get Current Location"
2. App requests GPS coordinates (latitude/longitude)
3. Geocoding service converts coordinates to address information
4. Extracts the `administrativeArea` which contains the wilaya name
5. Validates that wilaya was successfully detected
6. If detection fails, prompts user to retry

**Supported Wilayas**: All 58 Algerian provinces (Adrar, Alger, Oran, Constantine, etc.)

### Profile Simplification

Recent updates have simplified the user experience:
- ✅ **No phone verification required** - users can report incidents immediately
- ✅ **No account activation restrictions** - all features accessible after signup
- ✅ **Streamlined profile** - only name and email required
- ✅ **Removed status checks** - no concept of active/inactive users

### Location Services

The app requires location permissions for:
- Accurate incident positioning
- Automatic wilaya detection
- Optional periodic location updates for logged-in users

**Android Permissions Required**:
- `ACCESS_FINE_LOCATION` - High accuracy GPS
- `ACCESS_COARSE_LOCATION` - Network-based location (Android 15+)

---

## 🗂️ Project Structure

```
lib/
├── config/
│   └── app_config.dart          # Environment configuration
├── controllers/
│   └── location_controller.dart  # Location state management
├── l10n/                         # Localization files (AR, FR)
├── models/
│   └── user_profile.dart         # User data model
├── pages/
│   ├── new_home_page.dart        # Main dashboard
│   ├── new_report_incident_page.dart  # Incident reporting
│   ├── new_edit_profile_page.dart     # Profile editing
│   └── new_profile_page.dart          # Profile view
├── providers/
│   └── auth_provider.dart        # Authentication state
├── services/
│   ├── supabase_service.dart     # Supabase API client
│   ├── location_service.dart     # GPS & geocoding
│   └── firebase_messaging_service.dart
├── widgets/
│   └── shared_bottom_nav_bar.dart
└── main.dart                     # App entry point
```

---

## 🔧 Configuration

### Supabase Database Schema

Required tables:
- `utilisateurs` - User profiles (id, email, nom, prenom, role)
- `incident` - Incident reports (with **wilaya** column)
- `incident_img` - Incident photos
- `incident_category` - Incident categories
- `type_incident` - Incident types
- `type_vehicule` - Vehicle types

**Important**: Make sure to add the `wilaya` column to the `incident` table:
```sql
ALTER TABLE incident ADD COLUMN wilaya TEXT;
```

### Environment Variables

All sensitive configuration is stored in `.env` (not committed to version control):
- Supabase credentials
- Firebase configuration
- Google OAuth client ID

**Note**: Add `.env` to `.gitignore` to prevent accidental commits.

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Check for code issues
flutter analyze
```

---

## 📦 Building

### Debug Build
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release Build
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### App Size
- Debug APK: ~55-60 MB
- Release APK: ~20-25 MB (optimized)

---

## 🐛 Troubleshooting

### Geocoding Not Working
If you see `MissingPluginException` for geocoding:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```
Then reinstall the app on your device.

### Location Permission Issues
- Ensure location services are enabled on the device
- Check that app has location permissions in device settings
- On Android 15+, both fine and coarse location permissions are required

### Build Errors
- Update Flutter: `flutter upgrade`
- Clear cache: `flutter clean`
- Verify all dependencies: `flutter pub get`

---

## 📄 License

This project is proprietary software developed for the DNSR platform.

---

## 👥 Contributors

- **RedVirex** - Main Developer

---

## 📞 Support

For issues or questions:
- Open an issue on [GitHub](https://github.com/Redvirex/DNSR-report/issues)
- Contact the development team

---

**Last Updated**: October 2025  
**Version**: 2.0.0+1  
**Flutter SDK**: ^3.8.1
