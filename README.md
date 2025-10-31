# 🚦 DNSR Project

The **DNSR Project** (Direction Nationale de la Sécurité Routière) is a comprehensive traffic incident management system developed at **ESI (2025)** for Algeria.  
It enables real-time reporting and management of traffic incidents across Algerian provinces (wilayas).

The project consists of two Flutter applications:  
- **DNSR Report App** (Mobile) → for citizens to report traffic incidents  
- **DNSR Admin Dashboard** (Web) → for administrators to manage incidents and users  

---

## 📌 Apps Overview

### 1. 📱 DNSR Report App (User Mobile App)
**Location**: `dnsr_user/`  
**Version**: 2.0.0  
**Platform**: Android & iOS  

#### Key Features:
- 🔐 **Passwordless Authentication** via magic links and Google Sign-In
- 👤 **Profile Management** with account deletion capability
- 📍 **GPS-Based Incident Reporting**:
  - Automatic location and wilaya (province) detection using reverse geocoding
  - Multiple photo uploads from camera or gallery
  - Category and incident type selection
  - Vehicle type specification (when applicable)
- 📄 **Route Codes**: Download PDF of Algerian route codes
- 🔔 **Push Notifications**: Real-time alerts for nearby incidents
- 🌍 **Multi-language Support**: Arabic and French localization
- 📡 **Offline-Ready**: Location services work without constant internet

📖 **Detailed Documentation** → [dnsr_user/README.md](dnsr_user/README.md)

---

### 2. 💻 DNSR Admin Dashboard (Web App)
**Location**: `dnsr_admin/`  
**Version**: 1.0.0  
**Platform**: Web (Chrome, Firefox, Edge, Safari)  

#### Key Features:
- 🔐 **Secure Authentication** with email/password for admins
- 📊 **Dashboard Analytics**:
  - Real-time incident statistics
  - Date range and wilaya filtering
  - Status-based filtering (Pending, In Progress, Processed)
- 🗺️ **Interactive Map View**:
  - Google Maps integration with custom markers
  - Incident clustering and color-coded statuses
  - Configurable map settings (POI, Transit, Street View controls)
- 🛠️ **Incident Management**:
  - View detailed incident information with photos
  - Update incident status with comments
  - View status history timeline
  - Delete incidents with confirmation
  - Navigate to user details via clickable usernames
- 👥 **User Management**:
  - Search users by email or name
  - View user profiles and roles (Admin/Citizen)
  - Paginated user list (10-100 per page)
- 📢 **Broadcast Notifications**: Send proximity-based push notifications
- ⚙️ **Customizable Settings**: Configure map display and real-time updates

📖 **Detailed Documentation** → [dnsr_admin/README.md](dnsr_admin/README.md)

---

## 🛠️ Tech Stack

### Frontend
- **Flutter SDK**: 3.32.7
- **Dart**: 3.8.1
- **State Management**: Provider
- **UI Components**: Material Design 3

### Backend & Services
- **Supabase**: 
  - PostgreSQL database with Row Level Security (RLS)
  - Authentication and user management
  - Real-time subscriptions
  - Edge functions
  - File storage for incident photos
- **Firebase Cloud Messaging**: Push notifications
- **Google Maps API**: Interactive maps and reverse geocoding

### Key Dependencies
- **User App**: 
  - `supabase_flutter: ^2.3.4`
  - `geolocator: ^14.0.2`
  - `geocoding: ^3.0.0`
  - `image_picker` (camera/gallery)
  - `google_sign_in`
- **Admin App**: 
  - `supabase_flutter: ^2.9.1`
  - `google_maps_flutter_web: ^0.5.12`
  - `fl_chart: ^1.0.0` (analytics)
  - `http: ^1.5.0`

---

## 📊 Database Schema

### Main Tables
- **`utilisateurs`** (Users): User profiles with roles (CITOYEN, ADMIN)
- **`incident`**: Incident reports with status tracking
- **`incident_type`**: Types of incidents (e.g., accident, roadwork)
- **`vehicle_type`**: Vehicle classifications
- **`category`**: Incident categories
- **`status_history`**: Audit trail for incident status changes

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.8.1 or higher)
- For Android: Android SDK with API level 23+ (Android 6.0+)
- For iOS: Xcode 15.0+
- Active internet connection
- Firebase project with FCM enabled
- Supabase project configured
- Google Maps API key

### Quick Start

#### User App (Mobile)
```bash
cd dnsr_user
flutter pub get
flutter run
```

#### Admin Dashboard (Web)
```bash
cd dnsr_admin
flutter pub get
flutter run -d chrome  # or edge, firefox
```

### Environment Configuration
Both apps require `.env` files with the following keys:
- Supabase URL and Anon Key
- Firebase credentials (API key, App ID, Project ID, Messaging Sender ID)
- Google OAuth credentials (optional for User App)

See individual app README files for detailed setup instructions.

---

## 📁 Project Structure

```
DNSR-report/
├── README.md                    # This file
├── dnsr_user/                   # Mobile app for citizens
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/              # App configuration
│   │   ├── models/              # Data models
│   │   ├── pages/               # UI screens
│   │   ├── providers/           # State management
│   │   ├── services/            # API & business logic
│   │   └── widgets/             # Reusable components
│   ├── android/                 # Android platform code
│   ├── ios/                     # iOS platform code
│   └── pubspec.yaml
├── dnsr_admin/                  # Web dashboard for admins
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/
│   │   ├── models/
│   │   ├── pages/
│   │   ├── providers/
│   │   ├── services/
│   │   └── widgets/
│   ├── web/                     # Web platform code
│   ├── supabase/functions/      # Edge functions
│   └── pubspec.yaml
```

---

## 🔒 Security Features
- Row Level Security (RLS) policies in Supabase
- Role-based access control (RBAC)
- Secure authentication flows
- Environment variable management
- Input validation and sanitization

---

## 🌍 Localization
- **User App**: Arabic (ar) and French (fr)
- **Admin Dashboard**: French (default)

---

## 📄 License
This project is developed for educational purposes at ESI (École nationale Supérieure d'Informatique) in 2025.

---

## 👥 Contributing
This is an academic project. For contributions or issues, please contact the project maintainers.

---

## 📞 Support
For detailed setup instructions, troubleshooting, and feature documentation, refer to the individual README files:
- [User App Documentation](dnsr_user/README.md)
- [Admin Dashboard Documentation](dnsr_admin/README.md)
