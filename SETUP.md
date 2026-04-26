# Setup Guide - حقيقة ولا خرافة؟

Complete step-by-step guide to set up and run the application.

## 📋 Prerequisites

### Flutter Development
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Backend Development
- PHP 7.4 or higher
- MySQL 5.7 or higher
- Apache/Nginx web server
- phpMyAdmin (optional, for database management)

## 🚀 Quick Start

### Step 1: Clone the Project
```bash
git clone <repository-url>
cd haqeeqa_wala_khorafa
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: Setup Backend

#### 3.1 Create Database
```bash
mysql -u root -p
```

Then run:
```sql
CREATE DATABASE quiz_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

#### 3.2 Import Database Schema
```bash
mysql -u root -p quiz_app < backend/database.sql
```

#### 3.3 Import Sample Data (Optional)
```bash
mysql -u root -p quiz_app < backend/sample-data.sql
```

#### 3.4 Configure Database Connection
Edit `backend/config.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'quiz_app');
define('DB_USER', 'your_username');
define('DB_PASS', 'your_password');
```

#### 3.5 Deploy Backend Files
- Copy all files from `backend/` to your web server
- Example: `/var/www/html/api/` or `C:\xampp\htdocs\api\`

#### 3.6 Test Backend
Visit: `http://localhost/api/leaderboard.php`

You should see JSON response.

### Step 4: Configure Flutter App

Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://localhost/api';
// or
static const String baseUrl = 'https://your-domain.com/api';
```

### Step 5: Run the App
```bash
flutter run
```

## 🔧 Development Setup

### Local Development (XAMPP/WAMP)

1. Install XAMPP/WAMP
2. Start Apache and MySQL
3. Place backend files in `htdocs/api/`
4. Access via `http://localhost/api/`

### Android Emulator Configuration

If using Android emulator with local server:
```dart
// Use 10.0.2.2 instead of localhost
static const String baseUrl = 'http://10.0.2.2/api';
```

### iOS Simulator Configuration

For iOS simulator with local server:
```dart
// Use your computer's IP address
static const String baseUrl = 'http://192.168.1.100/api';
```

## 🌐 Production Deployment

### Backend Deployment

1. **Upload Files**
   - Upload all PHP files to your hosting
   - Recommended path: `/public_html/api/`

2. **Create Database**
   - Use cPanel or phpMyAdmin
   - Import `database.sql`
   - Import `sample-data.sql` (optional)

3. **Configure**
   - Update `config.php` with production credentials
   - Ensure proper file permissions (644 for files, 755 for directories)

4. **Test**
   - Visit: `https://your-domain.com/api/leaderboard`
   - Should return JSON response

### Flutter App Deployment

1. **Update API URL**
```dart
static const String baseUrl = 'https://your-domain.com/api';
```

2. **Build Android APK**
```bash
flutter build apk --release
```

3. **Build iOS App**
```bash
flutter build ios --release
```

4. **Build App Bundle (for Play Store)**
```bash
flutter build appbundle --release
```

## 📱 Testing

### Test Guest Mode
1. Open app
2. Answer questions without login
3. Try to access leaderboard (should prompt for registration)

### Test Registration
1. Click on leaderboard
2. Enter name and select avatar
3. Complete registration

### Test Daily Question
1. Answer today's question
2. Try to answer again (should show already answered)
3. Check countdown timer

### Test Free Questions
1. Go to "أسئلة حرة" tab
2. Select different categories
3. Answer unlimited questions

### Test Leaderboard
1. Login
2. Go to leaderboard
3. Check top 3 highlighting
4. Check your rank

### Test Profile
1. Login
2. Go to profile
3. Check stats and streak
4. Edit profile
5. Toggle dark/light mode

## 🐛 Troubleshooting

### Backend Issues

**Problem**: Database connection failed
```
Solution: Check config.php credentials
```

**Problem**: CORS errors
```
Solution: Ensure .htaccess is uploaded and mod_headers is enabled
```

**Problem**: 404 errors on API calls
```
Solution: Check .htaccess rewrite rules and mod_rewrite is enabled
```

### Flutter Issues

**Problem**: API connection timeout
```
Solution: Check baseUrl in app_constants.dart
```

**Problem**: JSON parsing errors
```
Solution: Check API response format matches models
```

**Problem**: Theme not persisting
```
Solution: Check SharedPreferences permissions
```

## 📊 Adding Content

### Add Daily Question
```sql
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date)
VALUES (
    'سؤال جديد؟',
    TRUE,
    'التفسير هنا',
    'صحة',
    TRUE,
    '2026-04-26'
);
```

### Add Free Question
```sql
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date)
VALUES (
    'سؤال حر؟',
    FALSE,
    'التفسير هنا',
    'معلومات عامة',
    FALSE,
    NULL
);
```

## 🔐 Security Notes

1. **Production Config**
   - Never commit `config.php` with real credentials
   - Use environment variables for sensitive data

2. **Database**
   - Use strong passwords
   - Limit database user permissions
   - Regular backups

3. **API**
   - Consider adding rate limiting
   - Implement API authentication for admin endpoints
   - Use HTTPS in production

## 📞 Support

For issues or questions:
- Check documentation
- Review error logs
- Test API endpoints individually

## ✅ Checklist

Before going live:
- [ ] Database created and populated
- [ ] Backend deployed and tested
- [ ] API URL updated in Flutter app
- [ ] App tested on real devices
- [ ] HTTPS enabled
- [ ] Database backed up
- [ ] Error handling tested
- [ ] Guest mode working
- [ ] Registration working
- [ ] Leaderboard calculating correctly
- [ ] Comments system working
- [ ] Profile updates working
- [ ] Theme toggle working
