# HealthTrack360 - Comprehensive Health Tracking App

A modern Flutter mobile application designed to help users track and manage their health data with seamless cloud synchronization.

## 📱 App Description

HealthTrack360 is a comprehensive health tracking application built with Flutter that addresses critical health monitoring needs. The app provides users with tools to track nutrition, exercise, sleep patterns, and mood while offering motivational content and data analytics.

### 🎯 Problem Solved
- **Health Awareness**: Helps users become more conscious of their daily health habits
- **Data Tracking**: Provides comprehensive tracking of nutrition, exercise, sleep, and mood
- **Motivation**: Offers personalized motivational content based on user's emotional state
- **Analytics**: Visualizes health trends and patterns for better decision making
- **Cloud Sync**: Ensures data is safely backed up and accessible across devices

## 🚀 Features

### Core Features
- **User Authentication**: Secure login/signup with Firebase Auth
- **Nutrition Tracking**: Log food items with calorie estimation via API
- **Exercise Monitoring**: Track workouts, duration, and achievements
- **Sleep Tracking**: Monitor sleep hours and patterns
- **Mood Tracking**: Log emotional states with motivational content
- **Data Analytics**: Visualize health trends with charts
- **Cloud Synchronization**: Bidirectional sync with Firebase Firestore
- **Local Storage**: Offline data access with SQLite
- **Backup & Restore**: Complete data backup functionality

### Technical Features
- **Real-time Updates**: Instant UI updates with Provider state management
- **API Integration**: External APIs for nutrition data and motivational content
- **Form Validation**: Comprehensive input validation and error handling
- **Responsive Design**: Beautiful UI with gradients and modern design
- **Cross-platform**: Works on Android, iOS, Web, and Desktop

## 📊 Screenshots

The app includes 15+ well-developed screens:

1. **Splash/Login Screen** - Beautiful authentication interface
2. **Main Navigation** - Bottom navigation with health categories
3. **Dashboard** - Overview of health metrics
4. **Nutrition Screen** - Food logging with API integration
5. **Exercise Screen** - Workout tracking with achievements
6. **Sleep Screen** - Sleep pattern monitoring
7. **Mood Screen** - Emotional tracking with motivation
8. **Goals Screen** - Personal health goal setting
9. **Trends Screen** - Data visualization and analytics
10. **Settings Screen** - App configuration and sync options
11. **Profile Screen** - User profile management
12. **Sync Data Screen** - Cloud synchronization management
13. **About Screen** - App information and credits

## 🏗️ Architecture

### Folder Structure
```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user.dart
│   ├── nutrition.dart
│   ├── exercise.dart
│   ├── sleep.dart
│   └── mood.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── health_data_provider.dart
├── screens/                  # UI screens
│   ├── splash_login_screen.dart
│   ├── main_navigation_screen.dart
│   ├── nutrition_screen.dart
│   ├── exercise_screen.dart
│   ├── sleep_screen.dart
│   ├── mood_screen.dart
│   ├── settings_screen.dart
│   └── ... (15+ screens)
├── widgets/                  # Reusable components
│   ├── custom_text_field.dart
│   ├── health_card.dart
│   └── trend_chart.dart
├── settings/                 # Services and utilities
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── local_storage_service.dart
│   ├── nutrition_api_service.dart
│   └── motivation_api_service.dart
└── assets/                   # Static assets
    └── logo.png
```

### State Management
- **Provider Pattern**: Clean separation of business logic and UI
- **Real-time Updates**: Immediate UI updates when data changes
- **Persistence**: Local storage with SQLite and cloud sync with Firestore

### Data Flow
1. **User Input** → **Provider** → **Local Storage** → **Firebase**
2. **Firebase** → **Provider** → **UI Update**
3. **Offline Support**: Local SQLite database for offline access

## 🛠️ Technologies Used

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Provider**: State management
- **fl_chart**: Data visualization

### Backend & Storage
- **Firebase Auth**: User authentication
- **Firebase Firestore**: Cloud database
- **SQLite**: Local database
- **SharedPreferences**: Settings storage

### APIs & Services
- **Nutrition API**: Food calorie estimation
- **Exercise API**: Workout suggestions
- **Motivation API**: Emotional support content

## 📦 Installation

### Prerequisites
- Flutter SDK (>=2.17.0)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Setup Instructions
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
4. Run the app: `flutter run`

### Building APK
```bash
flutter build apk --release
```

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication and Firestore
3. Download configuration files
4. Update security rules for Firestore

### API Keys
- Nutrition API: Update keys in `lib/settings/nutrition_api_service.dart`
- Exercise API: Update keys in `lib/settings/exercise_api_service.dart`

## 📈 Widget Tree Diagrams

### Main Navigation Structure
```
MaterialApp
└── AuthWrapper
    ├── SplashLoginScreen (if not authenticated)
    └── MainNavigationScreen (if authenticated)
        ├── BottomNavigationBar
        └── IndexedStack
            ├── HomeScreen
            ├── NutritionScreen
            ├── ExerciseScreen
            ├── SleepScreen
            ├── MoodScreen
            └── SettingsScreen
```

### Screen Architecture
Each screen follows this pattern:
```
Scaffold
├── AppBar
├── Container (with gradient background)
│   └── SafeArea
│       └── ListView/Column
│           ├── Header Section
│           ├── Data Cards
│           ├── Action Buttons
│           └── Charts/Analytics
└── FloatingActionButton (where applicable)
```

## 🎓 Lessons Learned

### Technical Insights
1. **State Management**: Provider pattern provides excellent separation of concerns
2. **Data Persistence**: Hybrid approach (local + cloud) ensures reliability
3. **API Integration**: Fallback mechanisms are crucial for user experience
4. **UI/UX**: Gradient backgrounds and card-based layouts create modern feel
5. **Error Handling**: Comprehensive error handling improves app stability

### Development Challenges
1. **Firebase Permissions**: Proper Firestore security rules are essential
2. **Data Synchronization**: Bidirectional sync requires careful conflict resolution
3. **Offline Support**: Local storage ensures app functionality without internet
4. **API Reliability**: Fallback data prevents app crashes when APIs fail
5. **State Consistency**: Real-time UI updates require careful state management

### Best Practices Implemented
1. **Code Organization**: Clear folder structure and naming conventions
2. **Error Handling**: Try-catch blocks with user-friendly error messages
3. **Loading States**: Progress indicators for better user experience
4. **Form Validation**: Comprehensive input validation
5. **Documentation**: Detailed code comments and README

## 🚀 Future Enhancements

- **Push Notifications**: Reminders for health activities
- **Social Features**: Share achievements with friends
- **AI Integration**: Personalized health recommendations
- **Wearable Integration**: Connect with fitness trackers
- **Advanced Analytics**: Machine learning insights

## 📄 License

This project is developed for educational purposes as part of a Flutter mobile development course.

## 👨‍💻 Developer

Developed with ❤️ using Flutter and Firebase.

---

**HealthTrack360** - Your comprehensive health companion! 🏃‍♂️💪🥗😴
