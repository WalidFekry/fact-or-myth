# Features Documentation - حقيقة ولا خرافة؟

Complete feature breakdown and implementation details.

## 🎯 Core Features

### 1. Daily Question (Challenge Mode)

#### Description
One question per day that users can answer only once. Answers contribute to the leaderboard.

#### User Flow
1. User opens app
2. Sees today's daily question
3. Selects answer (حقيقة or خرافة)
4. Sees result and explanation
5. Can view leaderboard or comments
6. Sees countdown to next question

#### Business Rules
- One answer per user per day
- Guest users can answer but not tracked
- Logged-in users' answers count toward leaderboard
- Cannot change answer once submitted
- New question available at midnight

#### Technical Implementation
```dart
// Check if already answered
if (userId && question.isDaily) {
  final answered = await checkIfAnswered(userId, questionId);
  if (answered) {
    return 'Already answered';
  }
}

// Submit answer
await submitAnswer(userId, questionId, answer);

// Update streak
if (lastAnswerDate == yesterday) {
  streak++;
} else {
  streak = 1;
}
```

---

### 2. Free Questions Mode

#### Description
Unlimited questions across multiple categories. Answers don't affect leaderboard.

#### Categories
- عشوائي (Random)
- صحة (Health)
- معلومات عامة (General Knowledge)
- نفسية (Psychology)
- دينية (Religious)

#### User Flow
1. User selects category
2. Gets random question from category
3. Answers question
4. Sees result and explanation
5. Clicks "سؤال جديد" for next question

#### Business Rules
- Unlimited questions
- No tracking for leaderboard
- Can answer same question multiple times
- No login required

#### Technical Implementation
```dart
// Get random question by category
if (category == 'عشوائي') {
  question = await getRandomQuestion();
} else {
  question = await getQuestionByCategory(category);
}
```

---

### 3. Guest Mode

#### Description
Users can use the app without registration with limited features.

#### Allowed Actions
- Answer daily question
- Answer free questions
- View explanations

#### Restricted Actions
- View leaderboard (requires login)
- Add comments (requires login)
- Track stats (requires login)
- View profile (requires login)

#### User Flow
1. User opens app
2. Can answer all questions
3. Tries to access leaderboard
4. Prompted to register
5. Can continue as guest or register

#### Technical Implementation
```dart
// Check login status
if (!authVM.isLoggedIn) {
  if (requiresLogin) {
    showLoginDialog();
    return;
  }
}
```

---

### 4. Soft Registration

#### Description
Simple registration requiring only name and avatar selection.

#### Required Information
- Name (text input)
- Avatar (emoji selection from predefined list)

#### User Flow
1. User clicks on leaderboard/comments
2. Prompted to register
3. Enters name
4. Selects avatar from grid
5. Clicks register
6. Immediately logged in

#### Business Rules
- No email required
- No password required
- No verification required
- Stats start from zero
- Previous guest answers not transferred

#### Technical Implementation
```dart
// Register user
final user = await authRepository.register(name, avatar);

// Save locally
await storageService.saveUser(user.id, user.name, user.avatar);

// Initialize streak
await initializeStreak(user.id);
```

---

### 5. Leaderboard

#### Description
Ranking of top 100 users based on daily question performance.

#### Display Rules
- Top 100 users shown
- Top 3 highlighted with medals (🥇🥈🥉)
- Current user shown even if outside top 100
- Sorted by percentage, then correct count

#### Eligibility
- Minimum 5 daily question answers
- Only daily questions count
- Free questions excluded

#### Metrics Shown
- Rank
- Name
- Avatar
- Correct answers
- Wrong answers
- Accuracy percentage

#### User Flow
1. User opens leaderboard
2. Sees top 100 users
3. Top 3 highlighted with special colors
4. Can see own rank at bottom (if outside top 100)
5. Pull to refresh

#### Technical Implementation
```sql
SELECT 
  user_id,
  correct_count,
  wrong_count,
  percentage
FROM (
  SELECT 
    u.id as user_id,
    SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) as correct_count,
    SUM(CASE WHEN a.is_correct = 0 THEN 1 ELSE 0 END) as wrong_count,
    ROUND((correct_count * 100.0) / COUNT(*), 2) as percentage
  FROM users u
  JOIN answers a ON u.id = a.user_id
  JOIN questions q ON a.question_id = q.id
  WHERE q.is_daily = 1
  GROUP BY u.id
  HAVING COUNT(*) >= 5
) rankings
ORDER BY percentage DESC, correct_count DESC
LIMIT 100
```

---

### 6. Comments System

#### Description
Users can comment on daily questions only.

#### Requirements
- Login required
- Daily questions only
- No comments on free questions

#### User Flow
1. User answers daily question
2. Clicks "التعليقات" button
3. Sees list of comments
4. Can add new comment
5. Comments show user name, avatar, and time

#### Business Rules
- Must be logged in
- Only on daily questions
- Comments are public
- No editing/deleting (keep it simple)
- Newest comments first

#### Technical Implementation
```dart
// Add comment
final comment = await commentRepository.addComment(
  userId: userId,
  questionId: questionId,
  comment: commentText,
);

// Load comments
final comments = await commentRepository.getComments(questionId);
```

---

### 7. Profile Screen

#### Description
User's personal profile showing stats, streak, and settings.

#### Sections

**User Info**
- Avatar (large display)
- Name
- Edit button

**Statistics**
- Total answers
- Correct answers
- Wrong answers
- Accuracy percentage

**Streak**
- Current streak (consecutive days)
- Fire emoji 🔥
- Days count

**Settings**
- Dark/Light mode toggle

#### User Flow
1. User opens profile
2. Sees avatar and name
3. Views stats
4. Checks streak
5. Can edit profile
6. Can toggle theme

#### Technical Implementation
```dart
// Calculate stats
final stats = await profileRepository.getProfile(userId);

// Stats include:
// - Total answers (all questions)
// - Correct/wrong counts
// - Accuracy = (correct / total) * 100
// - Current streak from streaks table
```

---

### 8. Streak System

#### Description
Tracks consecutive days of answering daily questions.

#### Rules
- Increments when user answers daily question
- Resets if user misses a day
- Only daily questions count
- Displayed in profile

#### Calculation Logic
```
Today's answer:
  if last_answer_date == yesterday:
    current_streak += 1
  else:
    current_streak = 1
  
  last_answer_date = today
```

#### User Flow
1. User answers daily question
2. Streak increments
3. User misses a day
4. Streak resets to 1 on next answer

#### Technical Implementation
```sql
-- Update streak
INSERT INTO streaks (user_id, current_streak, last_answer_date)
VALUES (?, 1, CURDATE())
ON DUPLICATE KEY UPDATE
  current_streak = CASE
    WHEN last_answer_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
    THEN current_streak + 1
    ELSE 1
  END,
  last_answer_date = CURDATE()
```

---

### 9. Theme System

#### Description
Dark and light mode support with persistence.

#### Features
- Default: Dark mode
- Toggle in profile
- Persists across sessions
- Smooth transition

#### Colors

**Light Mode**
- Primary: #6C63FF (Purple)
- Background: #F8F9FA (Light Gray)
- Surface: #FFFFFF (White)
- Text: #2D3436 (Dark Gray)

**Dark Mode**
- Primary: #8B83FF (Light Purple)
- Background: #1A1A2E (Dark Blue)
- Surface: #16213E (Navy)
- Text: #EEEEEE (Light Gray)

#### User Flow
1. User opens profile
2. Sees theme toggle
3. Switches theme
4. App immediately updates
5. Preference saved

#### Technical Implementation
```dart
// Toggle theme
Future<void> toggleTheme() async {
  _themeMode = _themeMode == ThemeMode.dark 
      ? ThemeMode.light 
      : ThemeMode.dark;
  
  await _storageService.saveThemeMode(_themeMode);
  notifyListeners();
}
```

---

## 🎨 UI/UX Features

### RTL Support
- Full right-to-left layout
- Arabic text alignment
- Proper icon positioning

### Animations
- Smooth page transitions
- Button press feedback
- Loading indicators
- Theme transitions

### Responsive Design
- Works on all screen sizes
- Adaptive layouts
- Proper spacing

### Accessibility
- Readable fonts
- Good contrast ratios
- Touch-friendly buttons
- Clear visual hierarchy

---

## 🔐 Security Features

### Data Protection
- No sensitive data stored
- Local storage for preferences only
- No password management

### API Security
- CORS enabled
- Input validation
- SQL injection prevention (prepared statements)
- XSS prevention

### Privacy
- Minimal data collection
- No email required
- No tracking
- No analytics

---

## 📊 Analytics & Insights

### User Metrics
- Total users
- Daily active users
- Answer accuracy
- Popular categories

### Question Metrics
- Most answered questions
- Hardest questions (lowest accuracy)
- Easiest questions (highest accuracy)
- Category popularity

### Engagement Metrics
- Average streak
- Daily question participation
- Free questions usage
- Comment activity

---

## 🚀 Future Enhancements

### Potential Features
1. **Achievements System**
   - Badges for milestones
   - Special avatars
   - Unlock rewards

2. **Social Features**
   - Share results
   - Challenge friends
   - Friend leaderboard

3. **Advanced Stats**
   - Category-wise accuracy
   - Progress charts
   - Historical data

4. **Notifications**
   - Daily question reminder
   - Streak reminder
   - Leaderboard updates

5. **Gamification**
   - Points system
   - Levels
   - Rewards

6. **Content Management**
   - Admin panel
   - Question submission
   - User reports

---

## 📱 Platform-Specific Features

### Android
- Material Design 3
- Adaptive icons
- Splash screen

### iOS
- Cupertino widgets (if needed)
- iOS-specific animations
- App Store compliance

---

## 🎯 Success Metrics

### User Engagement
- Daily active users > 60%
- Average session time > 5 minutes
- Return rate > 70%

### Content Quality
- Question accuracy rate 40-60% (balanced difficulty)
- User satisfaction with explanations
- Low report rate

### Technical Performance
- App load time < 2 seconds
- API response time < 500ms
- Crash-free rate > 99%

---

## 📝 Content Guidelines

### Question Quality
- Clear and unambiguous
- Culturally appropriate
- Factually accurate
- Engaging and interesting

### Explanation Quality
- Educational
- Concise
- Source-backed
- Easy to understand

### Category Balance
- Equal distribution
- Varied difficulty
- Fresh content regularly
