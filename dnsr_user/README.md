# 🚦 DNSR Report App

The **DNSR Report App** is a Flutter-based mobile application designed for end-users of the DNSR platform.  
It enables users to authenticate, manage their profiles, and report traffic incidents with real-time updates.

---

## 📌 Features
- 🔐 **Authentication**: Login via email using a magic link  
- 🙍 **Profile Management**:  
  - Edit personal information (name, phone number)  
  - OTP-based phone number verification  
  - Account activation upon profile completion  
- 🗺️ **Incident Reporting**:  
  - Submit incident reports with description, photos, and geolocation  
  - Real-time confirmation when an incident is reported  
- 📍 **View Route Codes**: Fetch and display available route codes from the database  
- 🔔 **Notifications**: Receive proximity-based push notifications about incidents  

---

## 🛠️ Tech Stack
- **Flutter** (Dart)  
- **Supabase** (authentication, database, real-time updates)  
- **Push Notifications** (Firebase Cloud Messaging)  

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed  
- API keys for Firebase, Supabase, Twilio configured  

### Installation
1. Clone this repository:  
   ```bash
   git clone https://github.com/Redvirex/dnsr-report.git
   cd dnsr_user
