# Admin Dashboard - حقيقة ولا خرافة؟

## 🎯 Overview
Complete admin dashboard for managing the quiz app.

## 📦 Features

### 1. Dashboard Home
- Total users, questions, answers statistics
- Daily activity tracking
- Recent users list
- Recent activity feed

### 2. Questions Management
- Add new questions
- Edit existing questions
- Delete questions
- Search functionality
- Pagination
- Fields:
  - Question text
  - Correct answer (truth/myth)
  - Explanation
  - Category
  - Is daily question

### 3. Users Management
- View all users
- User statistics (total, correct, wrong answers)
- Accuracy percentage
- Current streak
- Delete users
- Search functionality

### 4. Comments Management
- View all comments
- Delete inappropriate comments
- See associated question and user
- Pagination

### 5. Leaderboard Preview
- Top 50 users
- Same logic as mobile app
- Minimum 5 answers required
- Sorted by correct answers and accuracy

## 🔐 Login Credentials

**Default credentials:**
- Username: `admin`
- Password: `admin123`

⚠️ **IMPORTANT:** Change these credentials in production!

Edit `includes/auth.php` to change:
```php
define('ADMIN_USERNAME', 'your_username');
define('ADMIN_PASSWORD', 'your_password');
```

## 🚀 Installation

1. Upload the `admin` folder to your backend directory
2. Ensure database connection is configured in `includes/db.php`
3. Access: `http://yourdomain.com/backend/admin/`
4. Login with default credentials

## 🛡️ Security

- Session-based authentication
- All pages protected (require login)
- SQL injection prevention (prepared statements)
- Input sanitization
- CSRF protection recommended for production

## 📱 Tech Stack

- PHP 7.4+
- MySQL
- Bootstrap 5 RTL
- Bootstrap Icons
- Responsive design

## 🎨 UI Features

- Clean, modern interface
- RTL support (Arabic)
- Responsive design
- Sidebar navigation
- Statistics cards
- Data tables with pagination
- Search functionality
- Modal forms
- Alert notifications

## 📂 File Structure

```
admin/
├── includes/
│   ├── db.php          # Database connection
│   ├── auth.php        # Authentication logic
│   ├── header.php      # Page header & sidebar
│   └── footer.php      # Page footer & scripts
├── login.php           # Login page
├── dashboard.php       # Dashboard home
├── questions.php       # Questions management
├── users.php           # Users management
├── comments.php        # Comments management
├── leaderboard.php     # Leaderboard preview
├── index.php           # Redirect to dashboard
├── .htaccess           # Security settings
└── README.md           # This file
```

## 🔧 Configuration

### Database Connection
Edit `includes/db.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'quiz_app');
define('DB_USER', 'root');
define('DB_PASS', '');
```

### Admin Credentials
Edit `includes/auth.php`:
```php
define('ADMIN_USERNAME', 'admin');
define('ADMIN_PASSWORD', 'admin123');
```

## 📝 Notes

- All pages require authentication
- Logout: Click "تسجيل الخروج" in sidebar
- Auto-hide alerts after 3 seconds
- Confirm dialogs for delete actions
- Pagination: 15-20 items per page

## 🚀 Production Checklist

- [ ] Change admin credentials
- [ ] Update database credentials
- [ ] Enable HTTPS redirect in .htaccess
- [ ] Disable error display
- [ ] Add CSRF protection
- [ ] Implement password hashing
- [ ] Add activity logging
- [ ] Set up backups

## 📞 Support

For issues or questions, contact the development team.

---

Made with ❤️ for حقيقة ولا خرافة؟
