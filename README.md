# حقيقة ولا خرافة؟ 🤔

A production-ready Arabic quiz mobile application built with Flutter and clean architecture.

## 📱 Features

### 1. Daily Question (Challenge Mode)
- One question per day
- Answer only once
- Countdown timer for next question
- Included in leaderboard

### 2. Free Questions Mode
- Unlimited questions
- Multiple categories
- Not included in leaderboard

### 3. Guest Mode
- No login required
- Answer all questions
- Cannot access leaderboard or comments

### 4. Soft Registration
- Only name and avatar required
- Triggered when accessing leaderboard/comments

### 5. Leaderboard
- Top 100 users
- Top 3 highlighted (🥇🥈🥉)
- Based on daily questions only
- Minimum 5 answers required

### 6. Comments
- Daily questions only
- Login required

### 7. Profile
- User stats
- Streak tracking
- Dark/Light mode toggle

## 🏗️ Architecture

- **Pattern**: MVVM (Model-View-ViewModel)
- **State Management**: Provider
- **Dependency Injection**: get_it
- **Clean Code**: Separation of concerns

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── di/
├── data/
│   ├── models/
│   ├── services/
│   └── repositories/
├── viewmodels/
├── views/
│   ├── onboarding/
│   ├── home/
│   ├── daily_question/
│   ├── free_questions/
│   ├── leaderboard/
│   ├── profile/
│   └── auth/
├── widgets/
└── main.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- PHP 7.4+
- MySQL 5.7+

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd haqeeqa_wala_khorafa
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Backend**
- Navigate to `backend/` directory
- Follow instructions in `backend/README.md`
- Update API URL in `lib/core/constants/app_constants.dart`

4. **Run the app**
```bash
flutter run
```

## 🎨 Theme

- Default: Dark Mode
- Supports Light Mode
- Centralized theme system
- RTL support

## 🔌 Backend

- **Language**: PHP
- **Database**: MySQL
- **API**: RESTful JSON API
- See `backend/README.md` for details

## 📦 Dependencies

```yaml
dependencies:
  provider: ^6.1.1
  get_it: ^7.6.4
  http: ^1.1.0
  shared_preferences: ^2.2.2
  intl: ^0.18.1
  flutter_svg: ^2.0.9
```

## 🎯 Key Features

- ✅ Clean Architecture
- ✅ MVVM Pattern
- ✅ Dependency Injection
- ✅ State Management (Provider)
- ✅ Dark/Light Theme
- ✅ RTL Support
- ✅ Guest Mode
- ✅ Soft Registration
- ✅ Leaderboard System
- ✅ Streak Tracking
- ✅ Comments System

## 📝 License

This project is private and proprietary.

## 👨‍💻 Author

Built with ❤️ for Arabic quiz enthusiasts
