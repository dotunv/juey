# Juey - Flutter Migration Guide

## Project Overview
This document outlines the migration of the Juey from React Native/Expo to Flutter. The app is a task management solution with authentication, task CRUD operations, and voice input capabilities.

## Project Setup Guide

### Prerequisites
- Flutter SDK (3.10.0 or later)
- Android Studio / Xcode (for mobile development)
- VS Code (recommended) with Flutter/Dart plugins

### Getting Started
1. Install Flutter SDK
   ```bash
   # On Windows
   choco install flutter
   
   # On macOS
   brew install --cask flutter
   ```

2. Verify Installation
   ```bash
   flutter doctor
   ```

3. Create New Project
   ```bash
   flutter create --org com.juey --platforms android,ios,web juey_task_manager
   cd juey_task_manager
   ```

## Theming Guide

### Color Scheme
Edit `lib/app/theme/color_schemes.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Light Theme
  static const lightColorScheme = ColorScheme.light(
    primary: Color(0xFF6200EE),      // Primary brand color
    primaryContainer: Color(0xFFBB86FC),
    secondary: Color(0xFF03DAC6),    // Accent color
    secondaryContainer: Color(0xFF03DAC6).withOpacity(0.2),
    background: Color(0xFFFFFFFF),   // Background color
    surface: Color(0xFFFFFFFF),      // Surface/card color
    error: Color(0xFFB00020),        // Error color
    onPrimary: Color(0xFFFFFFFF),    // Text/icon color on primary
    onSecondary: Color(0xFF000000),  // Text/icon color on secondary
    onBackground: Color(0xFF000000), // Text color on background
    onSurface: Color(0xFF000000),    // Text color on surface
    onError: Color(0xFFFFFFFF),      // Text/icon color on error
    brightness: Brightness.light,
  );

  // Dark Theme
  static const darkColorScheme = ColorScheme.dark(
    primary: Color(0xFFBB86FC),
    primaryContainer: Color(0xFF3700B3),
    secondary: Color(0xFF03DAC6),
    secondaryContainer: Color(0xFF03DAC6).withOpacity(0.2),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    error: Color(0xFFCF6679),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFFFFFFFF),
    onSurface: Color(0xFFFFFFFF),
    onError: Color(0xFF000000),
    brightness: Brightness.dark,
  );
}
```

### Typography
Add to `lib/app/theme/text_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppTextTheme {
  static TextTheme get lightTextTheme {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    );
  }

  static TextTheme get darkTextTheme {
    return lightTextTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );
  }
}
```

### App Theme
Create `lib/app/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.lightColorScheme,
      textTheme: AppTextTheme.lightTextTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: AppColors.darkColorScheme,
      textTheme: AppTextTheme.darkTextTheme,
      // Override other theme properties for dark mode
    );
  }
}
```

## Project Structure
```
lib/
├── app/                    # App configuration and initialization
│   ├── app.dart           # Main app widget
│   ├── routes.dart        # Route configuration
│   └── theme/             # Theme definitions
│       ├── app_theme.dart
│       ├── color_schemes.dart
│       └── text_theme.dart
│
├── core/                  # Core functionality
│   ├── constants/         # App constants
│   ├── utils/             # Helper functions
│   └── services/          # External services
│
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── tasks/             # Task management
│   └── profile/           # User profile
│
└── shared/               # Shared components
    ├── widgets/          # Reusable widgets
    ├── models/           # Shared models
    └── services/         # Shared services
```

## Migration Tasks

### Phase 1: Project Setup & Configuration
- [x] Install Flutter SDK and set up development environment
- [x] Initialize new Flutter project with proper structure
- [x] Configure `pubspec.yaml` with required dependencies
- [x] Set up version control (Git)

### Phase 2: Core Infrastructure
- [x] Implement theme configuration (light/dark mode)
- [x] Set up routing and navigation
- [x] Configure state management (Riverpod)
- [ ] Implement dependency injection
- [ ] Set up internationalization (if needed)

### Phase 3: Authentication
- [ ] Implement Supabase authentication
- [ ] Create auth provider and state management
- [ ] Build sign-in/sign-up screens
- [ ] Implement session management
- [ ] Add password reset functionality

### Phase 4: Task Management
- [ ] Design task data models
- [ ] Implement task repository pattern
- [ ] Create task list screen
- [ ] Build add/edit task screen
- [ ] Implement task filtering and sorting

### Phase 5: Voice Integration
- [ ] Set up speech-to-text functionality
- [ ] Implement voice command system
- [ ] Create voice input UI components
- [ ] Add voice feedback

### Phase 6: Local Storage
- [ ] Implement SQLite database
- [ ] Set up offline-first architecture
- [ ] Implement data synchronization

### Phase 7: UI/UX
- [ ] Convert all screens from React Native to Flutter
- [ ] Implement responsive layouts
- [ ] Add animations and transitions
- [ ] Ensure accessibility compliance

### Phase 8: Testing
- [ ] Unit tests for business logic
- [ ] Widget tests for UI components
- [ ] Integration tests for critical flows
- [ ] Performance testing

### Phase 9: Deployment
- [ ] Configure app icons and splash screen
- [ ] Set up build variants
- [ ] Prepare for App Store and Google Play
- [ ] Implement CI/CD pipeline

## Technical Stack
- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Supabase
- **Local Database**: SQLite (sqflite)
- **Voice**: speech_to_text package
- **Theming**: Material 3 with custom themes

## Getting Started
1. Clone the repository
2. Install Flutter SDK (3.10 or later)
3. Run `flutter pub get` to install dependencies
4. Set up environment variables (see `.env.example`)
5. Run `flutter run` to start the development server

## Development Guidelines
- Follow Flutter best practices
- Write clean, maintainable code
- Document complex logic
- Write tests for new features
- Use meaningful commit messages
- Follow the existing project structure

## Dependencies
See `pubspec.yaml` for the complete list of dependencies.

## Support
For issues and feature requests, please use the issue tracker.

## License
[Your License Here]
