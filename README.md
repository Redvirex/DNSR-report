# 🚦 DNSR Project

The **DNSR Project** is a system developed at **ESI (2025)** to manage and report traffic incidents in real-time.  
It consists of two Flutter mobile applications:  

- **DNSR Report App (User App)** → for citizens/users to report and view incidents  
- **DNSR Admin App (Admin App)** → for administrators to manage incidents, users, and system settings  

---

## 📌 Apps Overview

### 1. DNSR Report (User App)
Located in: `dnsr_user/`  
- Login with magic link (email-based)  
- Profile management with OTP phone verification  
- Report incidents with photo, description, and geolocation  
- View available route codes  
- Receive proximity notifications about incidents  

📖 Detailed README → [dnsr_user/README.md](dnsr_user/README.md)

---

### 2. DNSR Admin (Admin App)
Located in: `dnsr_admin/`  
- Secure authentication with email and password  
- Manage incidents (view, filter, inspect details with embedded map)  
- Manage user accounts (search, filter)  
- Configure app settings (maps, realtime updates)  
- View admin profile  
- Send push notifications to relevant users  

📖 Detailed README → [dnsr_admin/README.md](dnsr_admin/README.md)

---

## 🛠️ Tech Stack
- **Flutter** (Dart)  
- **Firebase / Supabase** (authentication, realtime database)  
- **Push Notifications** (Firebase Cloud Messaging)  
- **Maps Integration** (Google Maps API)  

---

## 🚀 Getting Started
Each app (`dnsr_user/` and `dnsr_admin/`) has its own `README.md` with setup instructions.  

General steps:  
1. Install [Flutter SDK](https://flutter.dev/docs/get-started/install)  
2. Navigate to the app folder:  
   ```bash
   cd dnsr_user    # or cd dnsr_admin
   flutter pub get
   flutter run
