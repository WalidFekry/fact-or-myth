# Quick Start Guide - حقيقة ولا خرافة؟

Get up and running in 5 minutes!

## ⚡ Super Quick Setup

### 1. Install Dependencies (1 min)
```bash
flutter pub get
```

### 2. Setup Database (2 min)
```bash
# Create database
mysql -u root -p -e "CREATE DATABASE quiz_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Import schema
mysql -u root -p quiz_app < backend/database.sql

# Import sample data
mysql -u root -p quiz_app < backend/sample-data.sql
```

### 3. Configure Backend (1 min)
Edit `backend/config.php`:
```php
define('DB_USER', 'root');
define('DB_PASS', 'your_password');
```

### 4. Deploy Backend (30 sec)
```bash
# Copy to web server
cp -r backend/* /path/to/xampp/htdocs/api/
```

### 5. Configure App (30 sec)
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://localhost/api';
// For Android emulator: 'http://10.0.2.2/api'
```

### 6. Run! (30 sec)
```bash
flutter run
```

## 🎯 Test Checklist

- [ ] App opens successfully
- [ ] Daily question loads
- [ ] Can answer as guest
- [ ] Registration works
- [ ] Leaderboard shows data
- [ ] Profile displays stats
- [ ] Theme toggle works
- [ ] Free questions work
- [ ] Comments work

## 🐛 Quick Fixes

### Can't connect to API?
```dart
// Try this in app_constants.dart
static const String baseUrl = 'http://10.0.2.2/api'; // Android
static const String baseUrl = 'http://localhost/api'; // iOS
```

### Database connection failed?
```bash
# Check MySQL is running
mysql -u root -p -e "SHOW DATABASES;"
```

### CORS errors?
```bash
# Ensure .htaccess is in backend folder
# Check Apache mod_headers is enabled
```

## 📱 Quick Commands

```bash
# Run on specific device
flutter run -d <device_id>

# Build APK
flutter build apk --release

# Clean build
flutter clean && flutter pub get

# Check devices
flutter devices

# Run with hot reload
flutter run --hot
```

## 🎨 Quick Customization

### Change Primary Color
`lib/core/theme/app_colors.dart`:
```dart
static const Color primaryLight = Color(0xFF6C63FF); // Change this
```

### Add New Category
`lib/core/constants/app_constants.dart`:
```dart
static const List<String> categories = [
  'عشوائي',
  'صحة',
  'معلومات عامة',
  'نفسية',
  'دينية',
  'تاريخ', // Add new category
];
```

### Change App Name
`pubspec.yaml`:
```yaml
name: your_app_name
description: Your description
```

## 📊 Quick Database Queries

### Add Daily Question
```sql
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date)
VALUES ('سؤال جديد؟', TRUE, 'التفسير', 'صحة', TRUE, CURDATE());
```

### View Leaderboard
```sql
SELECT u.name, COUNT(*) as answers, 
       SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) as correct
FROM users u
JOIN answers a ON u.id = a.user_id
GROUP BY u.id
ORDER BY correct DESC;
```

### Reset User Data
```sql
DELETE FROM answers WHERE user_id = 1;
DELETE FROM comments WHERE user_id = 1;
UPDATE streaks SET current_streak = 0 WHERE user_id = 1;
```

## 🚀 Quick Deploy

### Deploy to Server
```bash
# 1. Build app
flutter build apk --release

# 2. Upload backend
scp -r backend/* user@server:/var/www/html/api/

# 3. Import database
mysql -h server -u user -p database < backend/database.sql

# 4. Update API URL in app
# Then rebuild
```

## 📞 Quick Help

### Common Issues

**Issue**: White screen on startup
**Fix**: Check API URL and backend is running

**Issue**: No questions showing
**Fix**: Import sample-data.sql

**Issue**: Can't register
**Fix**: Check database connection in backend

**Issue**: Theme not saving
**Fix**: Check app permissions for storage

## 🎓 Quick Learning

### Key Files to Understand
1. `lib/main.dart` - App entry point
2. `lib/core/di/service_locator.dart` - Dependency injection
3. `lib/viewmodels/` - Business logic
4. `lib/views/` - UI screens
5. `backend/config.php` - Backend config

### Key Concepts
- **MVVM**: View → ViewModel → Repository → API
- **Provider**: State management
- **get_it**: Dependency injection
- **Models**: Data structures
- **Repositories**: Data access layer

## 🎯 Next Steps

1. Read `ARCHITECTURE.md` for deep dive
2. Read `FEATURES.md` for feature details
3. Customize theme and colors
4. Add your own questions
5. Deploy to production

## 💡 Pro Tips

- Use `const` constructors for better performance
- Test on real devices, not just emulators
- Keep backend and app in sync
- Regular database backups
- Monitor API response times
- Use meaningful commit messages

## 🔗 Useful Links

- Flutter Docs: https://flutter.dev/docs
- Provider Docs: https://pub.dev/packages/provider
- get_it Docs: https://pub.dev/packages/get_it
- PHP MySQL: https://www.php.net/manual/en/book.mysqli.php

---

**Ready to build something amazing? Let's go! 🚀**
