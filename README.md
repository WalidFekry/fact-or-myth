# 🧠 حقيقة ولا خرافة؟

<div align="center">

![App Logo](assets/icons/logo_512.png)

**Daily Interactive Quiz App - اختبر معلوماتك يوميًا**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

[Features](#-features) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack) • [Setup](#-setup) • [Architecture](#-architecture)

</div>

---

## 📱 About

**حقيقة ولا خرافة؟** (Fact or Myth?) is an engaging Arabic-first mobile quiz application that challenges users to distinguish between facts and myths through daily interactive questions.

### 🎯 Core Concept
- Daily question system with streak tracking
- Competitive leaderboard
- Free quiz categories
- Educational explanations
- Community engagement through comments

---

## ✨ Features

### 🎮 Core Features
- **📅 Daily Question System**
  - New question every day
  - Streak tracking (🔥 fire emoji)
  - Voting statistics
  - Detailed explanations

- **🎯 Free Questions**
  - Multiple categories (Health, General, Psychology, Religious, Technology)
  - Progress tracking per category
  - Offline caching support
  - Shuffle and reset options

- **🏆 Leaderboard**
  - Real-time ranking system
  - Top 50 users display
  - Podium for top 3
  - Personal rank tracking
  - Minimum 5 answers to qualify

- **👤 Profile Management**
  - User statistics (total, correct, wrong answers)
  - Accuracy percentage
  - Current streak display
  - Avatar customization
  - Profile editing

- **💬 Comments System**
  - Comment on daily questions
  - Quick reactions (❤️ 🔥 😂 🤔)
  - Anti-spam validation
  - Time-ago formatting

### 🎨 UX Features
- **🌙 Dark/Light Mode**
  - Premium dark theme (#121212)
  - Eye-friendly light theme
  - Persistent preference

- **🔊 Sound Effects**
  - Success/error feedback
  - Toggle in profile
  - Persistent setting

- **🔔 Push Notifications**
  - Daily question reminders
  - Motivational quotes
  - App updates
  - Topic-based subscriptions

- **📱 Modern UI/UX**
  - Clean, minimal design
  - Smooth animations
  - Skeleton loading
  - Micro-interactions
  - RTL support (Arabic-first)

### 🚀 Technical Features
- **💾 Offline Support**
  - Local caching for daily questions
  - Offline free questions
  - Progress persistence
  - Guest mode support

- **🔐 Authentication**
  - Simple registration (name + avatar)
  - Guest mode available
  - Session management
  - Account deletion

- **📊 Analytics & Monitoring**
  - Firebase Crashlytics (crash reporting)
  - Error tracking
  - Performance monitoring

- **🎯 Performance**
  - Lazy loading
  - Image optimization
  - Efficient state management
  - Smart caching (1-hour for daily questions)

---

## 📸 Screenshots

<div align="center">

| Home Screen | Daily Question | Leaderboard | Profile |
|------------|----------------|-------------|---------|
| ![Home](screenshots/home.png) | ![Question](screenshots/question.png) | ![Leaderboard](screenshots/leaderboard.png) | ![Profile](screenshots/profile.png) |

| Free Questions | Comments | Onboarding | Notifications |
|----------------|----------|------------|---------------|
| ![Free](screenshots/free.png) | ![Comments](screenshots/comments.png) | ![Onboarding](screenshots/onboarding.png) | ![Notifications](screenshots/notifications.png) |

</div>

> **Note:** Add actual screenshots to `screenshots/` directory

---

## 🛠 Tech Stack

### Frontend
- **Framework:** Flutter 3.0+
- **Language:** Dart
- **State Management:** Provider (MVVM pattern)
- **Dependency Injection:** GetIt
- **Local Storage:** SharedPreferences, Hive
- **Networking:** Dio + PrettyDioLogger

### Firebase Services
- **Firebase Core:** App initialization
- **Firebase Messaging:** Push notifications
- **Firebase Crashlytics:** Crash reporting & monitoring
- **Firebase Analytics:** User behavior tracking

### Key Packages
```yaml
dependencies:
  # State Management
  provider: ^6.1.1
  get_it: ^7.6.4
  
  # Networking
  dio: ^5.4.0
  connectivity_plus: ^5.0.2
  
  # Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  
  # Firebase
  firebase_core: ^4.7.0
  firebase_messaging: ^16.2.0
  firebase_crashlytics: ^5.2.0
  firebase_analytics: ^12.3.0
  
  # UI/UX
  shimmer: ^3.0.0
  audioplayers: ^5.2.1
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
```

---

## 🚀 Setup

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Firebase account (for services)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/haqeeqa-wala-khorafa.git
   cd haqeeqa-wala-khorafa
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
   
   b. Configure Firebase:
   ```bash
   flutterfire configure
   ```
   
   c. This will create `lib/firebase_options.dart` automatically

4. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

### Build APK

```bash
# Build release APK
flutter build apk --release

# Build app bundle (for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🏗 Architecture

### MVVM Pattern

```
lib/
├── core/
│   ├── constants/        # App constants
│   ├── di/              # Dependency injection
│   ├── network/         # API client & exceptions
│   ├── theme/           # App theme & colors
│   └── utils/           # Utility functions
├── data/
│   ├── models/          # Data models
│   ├── repositories/    # Data repositories
│   └── services/        # Services (API, Storage, etc.)
├── viewmodels/          # Business logic (ViewModels)
├── views/               # UI screens
│   ├── daily_question/
│   ├── free_questions/
│   ├── leaderboard/
│   ├── profile/
│   ├── onboarding/
│   └── notification_permission/
├── widgets/             # Reusable widgets
├── firebase_options.dart
└── main.dart
```

### Key Design Patterns
- **MVVM:** Separation of UI and business logic
- **Repository Pattern:** Data abstraction layer
- **Dependency Injection:** GetIt for service location
- **Provider:** State management
- **Singleton Services:** API, Storage, Notifications

---

## 🔥 Firebase Integration

### Crashlytics
- **Automatic crash reporting** in release mode
- **Stack traces** for debugging
- **Fatal error tracking** for Flutter and async errors
- **Debug mode:** Errors printed to console only

### Cloud Messaging
- **Push notifications** for daily questions
- **Topic subscriptions:** daily_questions, quotes, app_updates
- **Background/foreground** message handling
- **User-controlled** notification preferences

### Analytics
- **User behavior tracking**
- **Screen view tracking**
- **Event logging**
- **Conversion tracking**

---

## 📦 Project Structure

### Core Components

#### Services
- **ApiService:** HTTP requests with Dio
- **StorageService:** Local data persistence
- **NotificationService:** FCM integration
- **SoundService:** Audio feedback
- **NetworkService:** Connectivity checking
- **OfflineStorageService:** Hive-based caching

#### Repositories
- **AuthRepository:** User authentication
- **QuestionRepository:** Question data management
- **LeaderboardRepository:** Ranking data
- **CommentRepository:** Comments management
- **ProfileRepository:** User profile data

#### ViewModels
- **AuthViewModel:** Authentication state
- **DailyQuestionViewModel:** Daily question logic
- **FreeQuestionsViewModel:** Free quiz logic
- **LeaderboardViewModel:** Ranking logic
- **ProfileViewModel:** Profile management
- **CommentViewModel:** Comments logic
- **ThemeViewModel:** Theme management

---

## 🎨 Design System

### Colors
```dart
Primary: #5B7FFF
Success: #4CAF50
Error: #F44336
Warning: #FF9800
Dark Background: #121212
Surface: #1E1E1E
```

### Typography
- **Font Family:** Somar (Arabic-optimized)
- **Weights:** Regular (400), Medium (500), Bold (700)
- **Sizes:** 12px - 24px (max)

### Spacing
- **Grid System:** 8dp base unit
- **Padding:** 4, 8, 12, 16, 20, 24, 32, 48
- **Border Radius:** 8, 12, 16, 24

---

## 🔧 Configuration

### Environment Variables
Create `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String apiBaseUrl = 'YOUR_API_URL';
  static const String appName = 'حقيقة ولا خرافة؟';
  static const String appVersion = '1.0.0';
}
```

### Firebase Configuration
- Automatic via `flutterfire configure`
- Creates `lib/firebase_options.dart`
- Platform-specific config files:
  - Android: `android/app/google-services.json`
  - iOS: `ios/Runner/GoogleService-Info.plist`

---

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📊 Performance

### Optimization Techniques
- **Lazy loading** for images and data
- **Pagination** for leaderboard (50 users)
- **Caching** for daily questions (1 hour)
- **Offline support** for free questions
- **Efficient state management** with Provider
- **Image optimization** (compressed assets)
- **Code splitting** with lazy imports

### Metrics
- **App Size:** ~50 MB (release APK)
- **Cold Start:** < 2 seconds
- **Hot Reload:** < 1 second
- **Memory Usage:** < 150 MB average

---

## 🔐 Security

### Best Practices
- ✅ No hardcoded API keys
- ✅ Secure storage for tokens
- ✅ Input validation
- ✅ SQL injection prevention (backend)
- ✅ XSS protection
- ✅ HTTPS only
- ✅ Session management
- ✅ Rate limiting (backend)

---

## 🚀 Production Checklist

Before releasing to production:

- [ ] Update version in `pubspec.yaml`
- [ ] Update app name and package name
- [ ] Configure Firebase for production
- [ ] Enable Crashlytics
- [ ] Test on multiple devices
- [ ] Test offline functionality
- [ ] Test push notifications
- [ ] Optimize images
- [ ] Remove debug code
- [ ] Update privacy policy
- [ ] Test payment flows (if any)
- [ ] Generate signed APK/AAB
- [ ] Test release build
- [ ] Prepare store listing

---

## 📝 Release Notes

### Version 1.0.0 (Current)
- ✨ Initial release
- 🎯 Daily question system
- 🏆 Leaderboard with ranking
- 🔥 Streak tracking
- 💬 Comments system
- 🔔 Push notifications
- 🌙 Dark/Light mode
- 📱 Offline support
- 🎨 Modern UI/UX

---

## 🤝 Contributing

This is a proprietary project. For contributions or suggestions, please contact the development team.

---

## 📄 License

Copyright © 2024 حقيقة ولا خرافة؟. All rights reserved.

This is proprietary software. Unauthorized copying, distribution, or modification is prohibited.

---

## 👨‍💻 Development Team

- **Lead Developer:** [Your Name]
- **UI/UX Designer:** [Designer Name]
- **Backend Developer:** [Backend Dev Name]

---

## 📞 Support

For issues, questions, or feedback:
- **Email:** support@factormyth.com
- **Website:** [Your Website]
- **GitHub Issues:** [Issues Page]

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Community contributors
- Beta testers

---

<div align="center">

**Made with ❤️ in Egypt**

[Download on Google Play](#) • [Download on App Store](#)

</div>
