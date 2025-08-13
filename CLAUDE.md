# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based AI diary application that combines Supabase as the backend, Claude AI for diary enhancement, and RevenueCat for subscription management. Users write diary entries which are then beautifully rewritten by AI, creating an enhanced journaling experience.

## Key Development Commands

### Setup and Dependencies
```bash
# Install dependencies
flutter pub get

# Generate code (if needed for models/serialization)
flutter packages pub run build_runner build
```

### Development
```bash
# Run with environment variables
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key

# Run in debug mode
flutter run

# Run on specific device
flutter run -d chrome  # for web
flutter run -d ios     # for iOS simulator
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/diary_service_test.dart

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

### Building
```bash
# Build for Android (APK)
flutter build apk --release

# Build for Android (App Bundle)
flutter build appbundle --release

# Build for iOS
flutter build ios --release
flutter build ipa --release

# Build for web
flutter build web --release
```

## Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point, routing configuration
├── models/                   # Data models
│   └── diary_model.dart     # DiaryEntry model with JSON serialization
├── screens/                  # UI screens
│   ├── main_screen.dart     # Bottom navigation shell
│   ├── auth_screen.dart     # Authentication (login/signup)
│   ├── home_screen.dart     # Landing/welcome screen  
│   ├── diary_screen.dart    # Main diary writing interface
│   ├── profile_screen.dart  # User profile and settings
│   ├── subscription_screen.dart # RevenueCat subscription management
│   └── splash_screen.dart   # App loading screen
├── services/                # Business logic and external APIs
│   ├── auth_service.dart    # Supabase authentication
│   ├── diary_service.dart   # Diary CRUD operations
│   ├── localization_service.dart # i18n support
│   └── subscription_service.dart # RevenueCat integration
└── widgets/                 # Reusable UI components
    └── responsive_wrapper.dart # Responsive design wrapper
```

### State Management
- **Primary**: Provider pattern for state management
- **AuthService**: ChangeNotifier for authentication state
- **LocalizationService**: ChangeNotifier for language switching
- **GoRouter**: Handles navigation with authentication guards

### Authentication Flow
The app supports multiple authentication methods:
- **Guest Mode**: Local-only experience (no cloud sync)
- **Email/Password**: Traditional account creation
- **Google OAuth**: Via Supabase Auth
- **Apple Sign In**: iOS integration

Key considerations:
- Guest mode uses dummy user objects for compatibility
- Real authentication switches `_isGuestMode = false`
- AuthService extends ChangeNotifier for reactive UI updates

### Database Schema
Supabase PostgreSQL with Row Level Security (RLS):
```sql
diary_entries (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  date DATE NOT NULL,
  title TEXT NOT NULL,
  original_content TEXT NOT NULL,
  generated_content TEXT, -- AI-enhanced version
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(user_id, date) -- One diary per user per day
)
```

### AI Integration
- **Supabase Edge Function**: `generate-diary` function calls Claude API
- **Fallback**: Mock diary generation when Edge Function fails
- **API**: Uses Claude Sonnet 4 for diary enhancement
- **Privacy**: API keys stored only in Edge Functions, not client

### Subscription System
- **RevenueCat**: Handles cross-platform subscriptions
- **Products**: Monthly (₩4,500) and Yearly (₩39,000) tiers
- **Entitlement**: "premium" unlocks unlimited diary entries
- **Platform**: Supports both iOS App Store and Google Play billing

## Environment Configuration

### Required Environment Variables
```bash
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# RevenueCat (set in respective platform code)
REVENUECAT_API_KEY_ANDROID=your-android-key
REVENUECAT_API_KEY_IOS=your-ios-key
```

### Platform-Specific Setup
- **iOS**: Requires Apple Developer account, Sign in with Apple setup
- **Android**: Requires Google Play Console, OAuth client setup
- **Web**: Supabase OAuth redirect URLs must be configured

## Development Guidelines

### File Naming and Structure
- Screen files: `[name]_screen.dart`
- Service files: `[name]_service.dart` 
- Model files: `[name]_model.dart`
- Test files: `[name]_test.dart`

### Error Handling
- Services use try-catch with detailed logging
- UI shows user-friendly error messages
- Fallback mechanisms for offline/API failures

### Localization
- **Supported**: Korean (default), English
- **Implementation**: Custom LocalizationService with Provider
- **Strings**: Defined in service, not external files

### Testing Strategy
- Unit tests for services and models
- Widget tests for screens
- Integration tests for complete user flows
- Mocking with `mocktail` package

## Common Development Patterns

### Adding a New Screen
1. Create screen file in `lib/screens/`
2. Add route to `_router` in `main.dart`
3. Update navigation in `main_screen.dart` if needed
4. Add corresponding test file

### Adding a New Service
1. Create service file in `lib/services/`
2. Extend ChangeNotifier if state management needed
3. Add error handling and logging
4. Write unit tests
5. Update models if new data structures needed

### Database Changes
1. Update Supabase schema via SQL Editor
2. Modify `diary_model.dart` if schema changes
3. Update `diary_service.dart` CRUD operations
4. Run tests to ensure compatibility

### Subscription Changes
1. Update products in RevenueCat dashboard
2. Modify `subscription_service.dart`
3. Update UI in `subscription_screen.dart`
4. Test purchase flows on both platforms

## Known Issues and Considerations

- **Guest Mode**: Diary entries not synced to cloud
- **Edge Functions**: May fail, fallback to mock content exists
- **Authentication**: Supabase anonymous login requires proper configuration
- **iOS Build**: Requires proper signing certificates and provisioning profiles
- **Web Deployment**: Requires Supabase redirect URL configuration

## Troubleshooting

### Common Build Issues
- **Supabase Connection**: Check environment variables are set
- **iOS Signing**: Verify certificates in Xcode
- **Android Build**: Ensure proper Gradle configuration

### Runtime Issues
- **Authentication Failures**: Check Supabase project settings
- **Subscription Issues**: Verify RevenueCat configuration
- **AI Generation**: Check Edge Function logs in Supabase

This codebase follows Flutter best practices with clear separation of concerns between UI, business logic, and data layers. The architecture supports both offline functionality (guest mode) and cloud synchronization with robust error handling throughout.

## Claude Code Notification Setup

### Task Completion Notifications
After completing any significant task, always send notification using:
```bash
zsh -c "source ~/.zshrc && notify_done"
```

This sends alerts to both macOS notification center and iPhone via ntfy.

### Custom Notification Messages
For specific task completion messages:
```bash
zsh -c "source ~/.zshrc && notify_all 'Custom completion message'"
```

### Prerequisites
User must have notification functions set up in ~/.zshrc:
- `notify_done` - Simple completion alert
- `notify_all` - Custom message with dual platform support (macOS + iPhone)

Always use these commands after completing development tasks to keep user informed.