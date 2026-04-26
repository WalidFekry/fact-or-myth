# Backend Setup - حقيقة ولا خرافة؟

## Requirements
- PHP 7.4+
- MySQL 5.7+
- Apache/Nginx

## Installation

### 1. Database Setup
```bash
mysql -u root -p < database.sql
```

### 2. Configuration
Edit `config.php` and update database credentials:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'quiz_app');
define('DB_USER', 'your_username');
define('DB_PASS', 'your_password');
```

### 3. Deploy Files
Upload all PHP files to your server's API directory.

### 4. Update Flutter App
In `lib/core/constants/app_constants.dart`, update:
```dart
static const String baseUrl = 'https://your-domain.com/api';
```

## API Endpoints

### POST /register
Register new user
```json
{
  "name": "أحمد",
  "avatar": "👨"
}
```

### GET /daily-question
Get today's daily question
```
?user_id=1 (optional)
```

### POST /submit-answer
Submit answer
```json
{
  "user_id": 1,
  "question_id": 1,
  "answer": true
}
```

### GET /free-question
Get random free question
```
?category=صحة
```

### GET /leaderboard
Get top 100 users

### GET /my-rank
Get user's rank
```
?user_id=1
```

### GET /comments
Get question comments
```
?question_id=1
```

### POST /add-comment
Add comment
```json
{
  "user_id": 1,
  "question_id": 1,
  "comment": "تعليق رائع"
}
```

### GET /profile
Get user profile
```
?user_id=1
```

### POST /update-profile
Update user profile
```json
{
  "user_id": 1,
  "name": "أحمد الجديد",
  "avatar": "👨‍💼"
}
```

## Adding Daily Questions

To add a new daily question, insert into database:
```sql
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date)
VALUES ('سؤال جديد؟', TRUE, 'التفسير هنا', 'صحة', TRUE, '2026-04-26');
```

## Notes
- Daily questions must have `is_daily = 1` and a specific `date`
- Free questions have `is_daily = 0` and `date = NULL`
- Leaderboard only counts daily question answers
- Minimum 5 answers required to appear on leaderboard
