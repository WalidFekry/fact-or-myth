# Offline Mode Documentation - حقيقة ولا خرافة؟

## 📴 Overview

The Free Questions Mode works **FULLY OFFLINE** after the first sync, allowing users to practice anytime, anywhere without internet connection.

## 🎯 Features

### ✅ What Works Offline
- **Free Questions Mode** - Complete offline support
- Browse all categories
- Answer unlimited questions
- Get instant results
- See explanations
- No API calls required

### 🌐 What Requires Internet
- **Daily Question Mode** - Always requires internet
- **Leaderboard** - Always requires internet
- **Comments** - Always requires internet
- **Profile Sync** - Requires internet for updates
- **Registration** - Requires internet

## 🔄 How It Works

### First Launch Behavior

1. **User opens Free Questions Mode**
2. **App checks internet connection**
3. **If online:**
   - Fetches ALL free questions from backend
   - Stores them locally in Hive database
   - Shows success message
4. **If offline:**
   - Shows friendly error message
   - Prompts user to connect to internet

### After First Sync

- All Free Questions work WITHOUT internet
- Questions are cached locally
- Instant loading (no API calls)
- Smooth offline experience

## 🗄️ Local Storage

### Technology: Hive
- Fast NoSQL database
- Lightweight and efficient
- Perfect for mobile apps

### Cached Data
```dart
CachedQuestionModel {
  int id;
  String question;
  bool correctAnswer;
  String explanation;
  String category;
}
```

### Storage Location
- Android: `/data/data/com.yourapp/app_flutter/`
- iOS: `Library/Application Support/`

## 📡 Network Handling

### Offline Detection
```dart
// Check connectivity
final isOnline = await networkService.isConnected();

// Listen to connectivity changes
networkService.onConnectivityChanged.listen((isOnline) {
  // Handle connectivity changes
});
```

### User-Friendly Messages

**When Offline (Free Questions):**
```
🌐 وضع عدم الاتصال
الأسئلة محفوظة محلياً
```

**When Offline (Daily Question):**
```
لا يوجد اتصال بالإنترنت 🌐
السؤال اليومي يتطلب اتصال بالإنترنت
```

**When Offline (Leaderboard):**
```
لا يوجد اتصال بالإنترنت 🌐
الترتيب يتطلب اتصال بالإنترنت
```

## 🔁 Sync Strategy

### Automatic Sync
- First app launch
- When internet returns (optional)
- After 7 days (recommended refresh)

### Manual Sync
- User can tap sync button
- Refreshes all questions
- Shows sync progress

### Sync Process
```dart
1. Check internet connection
2. Fetch all free questions from API
3. Clear old cached data
4. Save new questions to Hive
5. Update last sync timestamp
6. Show success message
```

## 🎨 UI Indicators

### Online/Offline Badge
- 🟢 Green cloud icon = Online
- 🟠 Orange cloud icon = Offline

### Sync Button
- Visible when online
- Shows loading spinner during sync
- Disabled when offline

### Last Sync Time
```
آخر تحديث: منذ 5 دقائق
آخر تحديث: منذ 2 ساعة
آخر تحديث: منذ 3 أيام
```

## 📊 Offline Statistics

### Available Data
```dart
Map<String, int> stats = {
  'صحة': 15,
  'معلومات عامة': 20,
  'نفسية': 12,
  'دينية': 18,
};
```

### Total Questions
- Displayed in app
- Updated after each sync

## 🔧 Implementation Details

### Services

**NetworkService**
```dart
class NetworkService {
  Future<bool> isConnected();
  Stream<bool> onConnectivityChanged;
}
```

**OfflineStorageService**
```dart
class OfflineStorageService {
  Future<void> saveQuestions(List<CachedQuestionModel>);
  List<CachedQuestionModel> getAllQuestions();
  List<CachedQuestionModel> getQuestionsByCategory(String);
  CachedQuestionModel? getRandomQuestion(String);
  bool hasData();
  DateTime? getLastSyncTime();
  bool needsSync();
}
```

### Repository Methods

**QuestionRepository**
```dart
// Sync all free questions
Future<bool> syncFreeQuestions();

// Get offline question
CachedQuestionModel? getOfflineFreeQuestion(String category);

// Check offline data
bool hasOfflineData();
bool needsSync();
DateTime? getLastSyncTime();
```

### ViewModel

**FreeQuestionsViewModel**
```dart
bool isOnline;
bool isSyncing;
DateTime? lastSyncTime;

Future<void> syncQuestions();
Future<void> loadQuestion(); // Works offline
```

## 🚀 Usage Examples

### Check Offline Data
```dart
final hasData = questionRepository.hasOfflineData();
if (!hasData) {
  // Prompt user to sync
}
```

### Sync Questions
```dart
final success = await questionRepository.syncFreeQuestions();
if (success) {
  print('Sync successful!');
} else {
  print('Sync failed');
}
```

### Get Offline Question
```dart
final question = questionRepository.getOfflineFreeQuestion('صحة');
if (question != null) {
  // Display question
}
```

## 🐛 Error Handling

### No Internet on First Launch
```dart
if (!isOnline && !hasOfflineData()) {
  showError('لا يوجد اتصال بالإنترنت 🌐\nيرجى الاتصال بالإنترنت لتحميل الأسئلة');
}
```

### Sync Failed
```dart
try {
  await syncQuestions();
} catch (e) {
  showError('فشل تحميل الأسئلة. يرجى المحاولة لاحقاً');
}
```

### No Questions in Category
```dart
final question = getRandomQuestion(category);
if (question == null) {
  showError('لا توجد أسئلة في هذه الفئة');
}
```

## 📱 User Experience

### Seamless Offline Mode
1. User opens app
2. Sees offline indicator
3. Can still use Free Questions
4. No blocking errors
5. Smooth experience

### Clear Communication
- Always show connection status
- Explain why features are unavailable
- Provide actionable solutions
- Never block app completely

### Graceful Degradation
- Core features work offline
- Advanced features require internet
- Clear distinction between modes
- User always in control

## 🔐 Data Management

### Cache Size
- Typical: 100-200 questions
- Storage: ~50-100 KB
- Negligible impact on device

### Data Freshness
- Recommended: Sync every 7 days
- Optional: Auto-sync on app start
- Manual: User-triggered sync

### Clear Cache
```dart
await offlineStorage.clearAll();
```

## 🎯 Best Practices

### For Users
1. Sync when on WiFi
2. Check sync status regularly
3. Manual sync for latest questions
4. Offline mode for practice

### For Developers
1. Always check connectivity first
2. Provide clear error messages
3. Cache aggressively
4. Sync intelligently
5. Test offline scenarios

## 📈 Performance

### Benefits
- ⚡ Instant loading
- 📴 Works offline
- 💾 Minimal storage
- 🔋 Battery efficient
- 📶 No data usage (after sync)

### Metrics
- Load time: <100ms (offline)
- Storage: ~100KB
- Sync time: ~2-5 seconds
- Battery impact: Minimal

## 🔮 Future Enhancements

### Potential Features
1. **Smart Sync**
   - Only sync new/updated questions
   - Delta sync for efficiency

2. **Background Sync**
   - Auto-sync when WiFi available
   - Silent background updates

3. **Offline Analytics**
   - Track offline usage
   - Sync stats when online

4. **Partial Sync**
   - Sync specific categories
   - User-controlled sync

## ✅ Testing Checklist

- [ ] First launch with internet
- [ ] First launch without internet
- [ ] Sync with internet
- [ ] Use offline after sync
- [ ] Switch categories offline
- [ ] Answer questions offline
- [ ] Reconnect to internet
- [ ] Manual sync
- [ ] Offline indicators
- [ ] Error messages

## 📞 Troubleshooting

### Questions not loading offline
**Solution**: Check if initial sync completed

### Sync button not working
**Solution**: Check internet connection

### Old questions showing
**Solution**: Trigger manual sync

### Storage issues
**Solution**: Clear cache and re-sync

---

**Offline mode makes the app truly accessible anytime, anywhere! 🚀**
