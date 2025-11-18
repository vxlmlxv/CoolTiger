# 효심이 (Hyosimi) - Routing & Demo Mode Guide

## Overview

The Flutter Web app now has complete routing and a demo mode that allows testing without Firebase or backend setup.

## Quick Start

### Running in Demo Mode

1. **Set demo mode** in `lib/app_config.dart`:

   ```dart
   const bool kDemoMode = true;
   ```

2. **Run the app**:

   ```bash
   cd frontend
   flutter run -d chrome
   ```

3. **Test flows**:
   - Click "어르신으로 시작" to test senior UI
   - Click "보호자로 시작" to test guardian dashboard

### Running in Real Mode

1. **Disable demo mode** in `lib/app_config.dart`:

   ```dart
   const bool kDemoMode = false;
   ```

2. **Configure Firebase** (if not already done):

   - Ensure `lib/firebase_options.dart` is properly configured
   - Update Firebase project settings

3. **Update backend URL** in `lib/app_config.dart`:

   ```dart
   const String kBaseApiUrl = "https://your-cloud-run-url.run.app";
   ```

4. **Run**:
   ```bash
   flutter run -d chrome
   ```

## App Structure

### Configuration (`lib/app_config.dart`)

Global configuration file controlling:

- **`kDemoMode`**: Toggle between demo and real mode
- **`kBaseApiUrl`**: Backend API endpoint
- **`DemoUser`**: Sample user data for testing

### Routing (`lib/main.dart`)

Named routes:

- `/login` → LoginScreen
- `/signup` → SignupScreen
- `/role-router` → RoleRouter (determines senior/guardian path)
- `/senior-home` → SeniorHomeScreen
- `/guardian-home` → GuardianHomeScreen
- `/demo` → DemoLandingScreen (demo mode only)

Initial screen logic:

- **Demo mode**: Shows DemoLandingScreen
- **Real mode**: Checks Firebase auth state
  - Logged in → RoleRouter
  - Not logged in → LoginScreen

### Screens

#### DemoLandingScreen (`lib/screens/demo_landing_screen.dart`)

- Entry point for demo mode
- Role selection (senior/guardian)
- Info about demo mode features

#### LoginScreen (`lib/screens/login_screen.dart`)

- **Demo mode**:
  - Shows role selection dialog
  - No Firebase calls
  - Email hints: "senior" → senior role, "guardian" → guardian role
- **Real mode**:
  - Firebase authentication
  - Navigates to RoleRouter after login

#### SignupScreen (`lib/screens/signup_screen.dart`)

- **Demo mode**:
  - Simulates 1-second signup delay
  - Direct navigation to home screens
- **Real mode**:
  - Creates Firebase user
  - Writes user doc to Firestore
  - Creates senior profile if role is "senior"

#### RoleRouter (`lib/screens/role_router.dart`)

- **Demo mode**:
  - Reads `demoRole` from route arguments
  - Direct navigation to home screens
- **Real mode**:
  - Fetches user role from Firestore
  - Loading/error states
  - Logout option on error

#### SeniorHomeScreen (`lib/screens/senior_home_screen.dart`)

- Tabbed interface:
  1. 효심이 상담 (SeniorCallScreen)
  2. 인지능력 퀴즈 (SeniorQuizScreen)
  3. 운동 길잡이 (SeniorExerciseScreen)
- Quick-start button for calls
- Logout button with confirmation

#### SeniorCallScreen (`lib/screens/senior_call_screen.dart`)

- **Demo mode**:
  - Simulated conversation with predefined responses
  - Tests microphone permissions (recording works)
  - No backend API calls
  - Dummy TTS indicators
  - Sample conversation flow
- **Real mode**:
  - Full backend integration (POST /conversation/start, /reply, /end)
  - Audio recording and multipart upload
  - TTS playback from URLs
  - Conversation history

#### SeniorQuizScreen (`lib/screens/senior_quiz_screen.dart`)

- Uses local quiz data (4 sample questions)
- 2x2 answer grid with color feedback
- Hint system
- Exit and completion dialogs
- **TODO**: Integrate with GET /quiz/list API

#### SeniorExerciseScreen (`lib/screens/senior_exercise_screen.dart`)

- Video player with sample URL
- +/-10 second seek controls
- Play/pause button
- Exit and voice button placeholders
- **TODO**: Load exercise videos from backend

#### GuardianHomeScreen (`lib/screens/guardian_home_screen.dart`)

- **Demo mode**:
  - Shows 3 dummy senior reports
  - Activity summary cards
  - Mood tracking display
- **Real mode**:
  - **TODO**: Fetch real data from Firestore
  - **TODO**: Implement report details view
  - **TODO**: Alert notifications

## Demo Mode Behavior

### What Works in Demo Mode

✅ **Full UI Testing**

- All screens accessible
- Navigation flow complete
- All buttons and interactions work

✅ **Audio Recording**

- Microphone permission requests work
- Recording starts/stops (tests hardware)
- No actual audio processing

✅ **Simulated Data**

- Dummy conversations
- Sample quiz questions
- Placeholder guardian reports
- Sample video playback

✅ **No Network Required**

- No Firebase initialization
- No backend API calls
- Instant responses (simulated delays)

### What Doesn't Work in Demo Mode

❌ **Real Authentication**

- No actual user accounts
- No password validation

❌ **Data Persistence**

- Conversation history not saved
- Quiz results not stored
- No Firestore writes

❌ **External Services**

- No CLOVA Speech (STT)
- No CLOVA Studio (LLM)
- No Google TTS

## Development Workflow

### Testing UI Changes

1. Set `kDemoMode = true`
2. Make UI changes
3. Hot reload to see changes instantly
4. No backend/Firebase setup needed

### Testing Backend Integration

1. Set `kDemoMode = false`
2. Ensure backend is running locally or deployed
3. Update `kBaseApiUrl` to match backend
4. Test with real Firebase accounts

### Testing Specific Features

**Testing Senior Call Flow (Demo)**:

```dart
// In app_config.dart
const bool kDemoMode = true;

// Run app, select "어르신으로 시작"
// Click "효심이 상담 바로 시작하기"
// Click "통화 시작하기"
// Click mic button to record
// Observe dummy AI responses
```

**Testing Guardian Dashboard (Demo)**:

```dart
// In app_config.dart
const bool kDemoMode = true;

// Run app, select "보호자로 시작"
// View dummy reports
// Check summary cards
```

## Code Patterns

### Branching on Demo Mode

```dart
import '../app_config.dart';

Future<void> someApiCall() async {
  // DEMO MODE: Simulate behavior
  if (kDemoMode) {
    await Future.delayed(Duration(milliseconds: 500));
    // ... dummy data
    return;
  }

  // REAL MODE: Call actual backend
  final response = await dio.post('$kBaseApiUrl/endpoint');
  // ... process response
}
```

### Using Demo Users

```dart
import '../app_config.dart';

String getUserId() {
  if (kDemoMode) {
    return DemoUser.senior.uid; // or DemoUser.guardian.uid
  }
  return FirebaseAuth.instance.currentUser!.uid;
}
```

## Troubleshooting

### "Firebase not initialized" Error

**Solution**: Ensure `kDemoMode = true` in `app_config.dart` or properly configure Firebase.

### Routes Not Working

**Solution**: Check that all screen imports in `main.dart` are correct.

### Demo Mode Shows Real Login

**Solution**: Hot restart (not just hot reload) after changing `kDemoMode`.

### Compilation Errors

**Common issues**:

- Missing imports: Check all `import '../app_config.dart';` statements
- Undefined routes: Verify route names match in `main.dart` and `Navigator.pushNamed()` calls

## Next Steps

### Backend Integration TODOs

1. **SeniorCallScreen**:

   - [ ] Implement audio file reading for web platform
   - [ ] Handle TTS audio URLs from backend
   - [ ] Store conversation history in Firestore

2. **SeniorQuizScreen**:

   - [ ] Replace local quiz data with GET /quiz/list
   - [ ] Submit results to POST /quiz/submit
   - [ ] Load quiz history

3. **SeniorExerciseScreen**:

   - [ ] Fetch exercise video URLs from backend
   - [ ] Track exercise completion
   - [ ] Implement voice controls

4. **GuardianHomeScreen**:
   - [ ] Query Firestore for real senior reports
   - [ ] Implement report filtering/search
   - [ ] Add real-time updates
   - [ ] Notification system

### Production Deployment

1. Set `kDemoMode = false`
2. Update `kBaseApiUrl` to Cloud Run URL
3. Configure Firebase production project
4. Enable Firebase Auth methods
5. Set up Firestore security rules
6. Deploy frontend to Firebase Hosting or Cloud Run

## File Reference

```
frontend/
├── lib/
│   ├── main.dart                          # App entry, routing
│   ├── app_config.dart                    # Global config, demo mode
│   ├── firebase_options.dart              # Firebase config
│   └── screens/
│       ├── demo_landing_screen.dart       # Demo mode entry
│       ├── login_screen.dart              # Login with demo support
│       ├── signup_screen.dart             # Signup with demo support
│       ├── role_router.dart               # Role-based navigation
│       ├── senior_home_screen.dart        # Senior home with tabs
│       ├── senior_call_screen.dart        # AI call with demo mode
│       ├── senior_quiz_screen.dart        # Quiz with local data
│       ├── senior_exercise_screen.dart    # Exercise video player
│       └── guardian_home_screen.dart      # Guardian dashboard
```

## Support

For issues or questions:

1. Check this README
2. Review code comments (search for "DEMO MODE:" or "TODO:")
3. Verify `app_config.dart` settings
4. Check console for error messages
