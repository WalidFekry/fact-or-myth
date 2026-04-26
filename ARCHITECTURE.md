# Architecture Documentation - حقيقة ولا خرافة؟

## 🏗️ Architecture Overview

This application follows Clean Architecture principles with MVVM pattern.

## 📐 Architecture Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Views + ViewModels + Widgets)     │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│         Domain Layer                │
│         (Models)                    │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│         Data Layer                  │
│  (Repositories + Services)          │
└─────────────────────────────────────┘
```

## 🎯 MVVM Pattern

### View
- UI components
- Observes ViewModel
- No business logic
- Displays data from ViewModel

### ViewModel
- Business logic
- State management
- Communicates with Repository
- Notifies View of changes

### Model
- Data structures
- No business logic
- Serialization/Deserialization

## 📁 Folder Structure Explained

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App-wide constants
│   │   └── app_constants.dart
│   ├── theme/              # Theme configuration
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── utils/              # Utility functions
│   │   └── date_utils.dart
│   └── di/                 # Dependency Injection
│       └── service_locator.dart
│
├── data/                    # Data layer
│   ├── models/             # Data models
│   │   ├── user_model.dart
│   │   ├── question_model.dart
│   │   ├── comment_model.dart
│   │   ├── leaderboard_model.dart
│   │   └── profile_model.dart
│   ├── services/           # External services
│   │   ├── api_service.dart
│   │   └── storage_service.dart
│   └── repositories/       # Data repositories
│       ├── auth_repository.dart
│       ├── question_repository.dart
│       ├── leaderboard_repository.dart
│       ├── comment_repository.dart
│       └── profile_repository.dart
│
├── viewmodels/             # ViewModels (Business Logic)
│   ├── theme_viewmodel.dart
│   ├── auth_viewmodel.dart
│   ├── daily_question_viewmodel.dart
│   ├── free_questions_viewmodel.dart
│   ├── leaderboard_viewmodel.dart
│   ├── comment_viewmodel.dart
│   └── profile_viewmodel.dart
│
├── views/                  # UI Screens
│   ├── onboarding/
│   │   └── splash_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── daily_question/
│   │   ├── daily_question_screen.dart
│   │   └── comments_screen.dart
│   ├── free_questions/
│   │   └── free_questions_screen.dart
│   ├── leaderboard/
│   │   └── leaderboard_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   └── auth/
│       └── register_screen.dart
│
├── widgets/                # Reusable widgets
│   ├── answer_button.dart
│   ├── avatar_selector.dart
│   ├── countdown_timer.dart
│   ├── error_widget.dart
│   ├── loading_widget.dart
│   └── leaderboard_item.dart
│
└── main.dart              # App entry point
```

## 🔄 Data Flow

### Example: Answering Daily Question

```
1. User taps answer button
   ↓
2. View calls ViewModel method
   ↓
3. ViewModel calls Repository
   ↓
4. Repository calls API Service
   ↓
5. API Service makes HTTP request
   ↓
6. Backend processes request
   ↓
7. Response flows back up
   ↓
8. ViewModel updates state
   ↓
9. View rebuilds with new data
```

## 🎨 State Management

### Provider Pattern

```dart
// 1. Create ViewModel
class MyViewModel extends ChangeNotifier {
  void updateData() {
    // Update state
    notifyListeners(); // Notify observers
  }
}

// 2. Provide ViewModel
ChangeNotifierProvider(
  create: (_) => MyViewModel(),
  child: MyScreen(),
)

// 3. Consume in View
Consumer<MyViewModel>(
  builder: (context, vm, _) {
    return Text(vm.data);
  },
)
```

## 🔌 Dependency Injection

### get_it Setup

```dart
// Register dependencies
final getIt = GetIt.instance;

// Services (Singleton)
getIt.registerLazySingleton<ApiService>(() => ApiService());

// Repositories (Singleton)
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepository(getIt<ApiService>()),
);

// ViewModels (Factory - new instance each time)
getIt.registerFactory<AuthViewModel>(
  () => AuthViewModel(getIt<AuthRepository>()),
);

// Usage
final authVM = getIt<AuthViewModel>();
```

## 🌐 API Integration

### API Service Layer

```dart
class ApiService {
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }
}
```

### Repository Layer

```dart
class QuestionRepository {
  final ApiService _apiService;

  Future<QuestionModel> getDailyQuestion() async {
    final response = await _apiService.get('/daily-question');
    return QuestionModel.fromJson(response['data']);
  }
}
```

## 💾 Local Storage

### SharedPreferences Wrapper

```dart
class StorageService {
  final SharedPreferences _prefs;

  Future<void> saveUser(int userId, String name) async {
    await _prefs.setInt('user_id', userId);
    await _prefs.setString('user_name', name);
  }

  int? getUserId() => _prefs.getInt('user_id');
}
```

## 🎨 Theming

### Centralized Theme System

```dart
// Define colors
class AppColors {
  static const primaryLight = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF8B83FF);
}

// Create themes
class AppTheme {
  static ThemeData get lightTheme => ThemeData(...);
  static ThemeData get darkTheme => ThemeData(...);
}

// Apply theme
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeMode,
)
```

## 🔐 Authentication Flow

```
Guest User
    ↓
Opens App → Can answer questions
    ↓
Tries to access Leaderboard/Comments
    ↓
Prompted to Register
    ↓
Enters Name + Avatar
    ↓
Registered User → Full access
```

## 📊 Leaderboard Logic

### Calculation Rules
1. Only daily question answers count
2. Minimum 5 answers required
3. Sorted by percentage (descending)
4. If tied, sorted by correct count
5. Top 100 users shown

### SQL Query
```sql
SELECT 
  user_id,
  SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) as correct,
  COUNT(*) as total,
  (correct * 100.0 / total) as percentage
FROM answers
WHERE question_id IN (SELECT id FROM questions WHERE is_daily = 1)
GROUP BY user_id
HAVING total >= 5
ORDER BY percentage DESC, correct DESC
LIMIT 100
```

## 🔥 Streak System

### Logic
- Increments when user answers daily question
- Resets if user misses a day
- Stored in `streaks` table
- Updated on each daily answer

### Algorithm
```
if last_answer_date == yesterday:
  current_streak += 1
else:
  current_streak = 1

last_answer_date = today
```

## 🧪 Testing Strategy

### Unit Tests
- ViewModels
- Repositories
- Utilities

### Widget Tests
- Individual widgets
- Screen layouts

### Integration Tests
- Complete user flows
- API integration

## 🚀 Performance Optimization

### Best Practices
1. Use `const` constructors
2. Lazy load ViewModels
3. Cache API responses
4. Optimize images
5. Use ListView.builder for lists
6. Minimize rebuilds

### Example
```dart
// Good
const Text('Hello');

// Bad
Text('Hello');
```

## 📱 Navigation

### Simple Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => NewScreen()),
);
```

### With Result
```dart
final result = await Navigator.push(...);
if (result != null) {
  // Handle result
}
```

## 🔄 Error Handling

### Layered Approach
```dart
// Repository
try {
  return await _apiService.get('/endpoint');
} catch (e) {
  throw Exception('Error: $e');
}

// ViewModel
try {
  _data = await _repository.getData();
} catch (e) {
  _error = e.toString();
} finally {
  _isLoading = false;
  notifyListeners();
}

// View
if (vm.error != null) {
  return ErrorWidget(message: vm.error);
}
```

## 🌍 Localization

Currently Arabic-only, but structured for easy expansion:

```dart
// Future: Add localization
class AppStrings {
  static const correctAnswer = 'جاوبت صح!';
  static const wrongAnswer = 'مش لوحدك 😅';
}
```

## 📈 Scalability

### Easy to Add
- New question categories
- New screens
- New features
- Multiple languages

### Modular Design
- Each feature is independent
- Easy to test
- Easy to maintain
- Easy to extend

## 🎯 Design Principles

1. **Separation of Concerns**: Each layer has specific responsibility
2. **Dependency Inversion**: Depend on abstractions, not implementations
3. **Single Responsibility**: Each class has one job
4. **DRY**: Don't Repeat Yourself
5. **KISS**: Keep It Simple, Stupid

## 📚 Key Takeaways

- Clean Architecture for maintainability
- MVVM for clear separation
- Provider for state management
- get_it for dependency injection
- Modular and scalable design
- Easy to test and extend
