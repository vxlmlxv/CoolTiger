# 효심이 Demo Mode - Quick Test Guide

## 🚀 Quick Start (5 Minutes)

### Step 1: Enable Demo Mode

```bash
cd /Users/vxlmlxv/github/CoolTiger/frontend
```

Open `lib/app_config.dart` and verify:

```dart
const bool kDemoMode = true;  // ← Should be true for demo
```

### Step 2: Run the App

```bash
flutter run -d chrome
```

Wait for the app to launch in your browser.

### Step 3: Test Senior Flow

1. **Landing Page**: You should see "효심이 - Demo Mode" with a yellow banner
2. **Click**: "어르신으로 시작" (blue button)
3. **Home Screen**: You'll see tabs: 효심이 상담 | 인지능력 퀴즈 | 운동 길잡이

#### Test AI Call

4. **Click**: Big orange button "효심이 상담 바로 시작하기"
5. **Click**: "통화 시작하기" button
6. **Observe**: AI greeting appears in chat
7. **Click**: Microphone button (🎤) - browser may ask for mic permission
8. **Wait**: 2-3 seconds (simulates recording)
9. **Click**: Mic button again to stop
10. **Observe**: Dummy user message + AI response appear
11. **Click**: "통화 종료" to end call

#### Test Quiz

12. **Click**: "인지능력 퀴즈" tab
13. **Click**: Any answer in the 2x2 grid
14. **Observe**:
    - Correct answer → green
    - Wrong answer → red
15. **Click**: "힌트 보기" for help
16. **Click**: "다음 문제" to continue
17. **Complete**: All 4 questions

#### Test Exercise

18. **Click**: "운동 길잡이" tab
19. **Wait**: Video loads (sample bee video)
20. **Click**: Large pink play/pause button
21. **Click**: "10초 전" / "10초 후" buttons
22. **Observe**: Video seeks backward/forward

### Step 4: Test Guardian Flow

1. **Logout**: Click logout icon (top right)
2. **Return**: You're back at demo landing page
3. **Click**: "보호자로 시작" (green button)
4. **Observe**: Dashboard with:
   - 4 summary cards (today's calls, weekly quiz, exercise, mood)
   - 3 dummy activity reports with mood chips
5. **Pull Down**: Refresh gesture works
6. **Logout**: Test logout flow

## ✅ Expected Behaviors

### Demo Mode Features

- ✅ No Firebase errors
- ✅ No backend API calls
- ✅ Instant responses (simulated delays)
- ✅ All navigation works
- ✅ Audio recording permission requests (but no real processing)
- ✅ Video playback works (sample video)
- ✅ No data persistence (refresh = reset)

### What You Should See

- Yellow "DEMO MODE" banner on landing page
- SnackBar messages: "(Demo) TTS would play here"
- Dummy data in conversations and reports
- Korean text throughout UI
- Large, senior-friendly buttons and fonts

## 🐛 Common Issues

### Issue: Black screen / white screen

**Fix**: Hard refresh browser (Cmd+Shift+R on Mac, Ctrl+Shift+R on Windows)

### Issue: "Firebase not initialized" error

**Fix**: Verify `kDemoMode = true` in `app_config.dart`, then run `flutter run -d chrome` again (not hot reload)

### Issue: Video doesn't load

**Fix**: Normal - the sample video URL may be slow. Wait 5-10 seconds.

### Issue: Microphone button does nothing

**Fix**:

1. Check browser console for errors
2. Grant microphone permission when prompted
3. This is expected in demo mode - it just tests the UI

### Issue: Routes don't work after hot reload

**Fix**: Do a hot restart (Shift+R in terminal) instead of hot reload

## 🔄 Switch to Real Mode

When ready to test with actual Firebase/backend:

1. **Update config**:

```dart
// lib/app_config.dart
const bool kDemoMode = false;
const String kBaseApiUrl = "http://localhost:8000"; // or your Cloud Run URL
```

2. **Restart app** (full restart, not hot reload):

```bash
flutter run -d chrome
```

3. **Login**: Use real Firebase credentials
4. **Test**: All features now hit actual backend

## 📋 Test Checklist

Copy this to track your testing:

```
Demo Mode Tests:
□ App launches without Firebase errors
□ Demo landing page shows with yellow banner
□ "어르신으로 시작" navigates to senior home
□ Tabs switch between Call/Quiz/Exercise
□ Quick-start button switches to Call tab
□ Call: Start call shows AI greeting
□ Call: Mic button triggers recording UI
□ Call: Dummy responses appear after recording
□ Call: End call shows summary
□ Quiz: Answer selection shows color feedback
□ Quiz: Hint button shows dialog
□ Quiz: All 4 questions can be completed
□ Exercise: Video loads and plays
□ Exercise: Seek buttons work (+/-10s)
□ Exercise: Play/pause button toggles
□ Logout button shows confirmation dialog
□ "보호자로 시작" navigates to guardian home
□ Guardian: 4 summary cards display
□ Guardian: 3 dummy reports show with mood chips
□ Guardian: Pull-to-refresh works
□ Guardian: Logout returns to landing page

Real Mode Tests (after backend setup):
□ Login screen appears on launch
□ Signup creates Firebase user
□ Login authenticates successfully
□ RoleRouter fetches role from Firestore
□ Senior call hits backend API
□ Audio upload works (multipart)
□ TTS URL plays audio
□ Quiz loads from backend /quiz/list
□ Guardian dashboard loads real reports
```

## 📞 Navigation Flow Map

```
Demo Mode:
┌─────────────────────┐
│ DemoLandingScreen   │
│ (Role Selection)    │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
┌────▼────┐  ┌──▼──────┐
│ Senior  │  │Guardian │
│  Home   │  │  Home   │
└────┬────┘  └─────────┘
     │
  ┌──┴──┬──────┬────────┐
  │     │      │        │
┌─▼──┐┌─▼─┐┌──▼───┐┌───▼────┐
│Call││Quiz││Exercise││Logout │
└────┘└───┘└──────┘└────┬────┘
                         │
                    ┌────▼────┐
                    │Landing  │
                    │(restart)│
                    └─────────┘

Real Mode:
┌─────────────┐
│LoginScreen  │◄──────┐
└──────┬──────┘       │
       │              │
   ┌───▼───┐     ┌────┴────┐
   │Signup │     │ Logout  │
   └───┬───┘     └────▲────┘
       │              │
    ┌──▼──────────────┴──┐
    │   RoleRouter       │
    │(Firestore lookup)  │
    └──────┬─────────────┘
           │
     ┌─────┴─────┐
     │           │
┌────▼────┐  ┌──▼──────┐
│ Senior  │  │Guardian │
│  Home   │  │  Home   │
└─────────┘  └─────────┘
```

## 🎯 Success Criteria

You've successfully tested demo mode if:

1. ✅ No compile errors
2. ✅ No Firebase errors in console
3. ✅ All screens accessible
4. ✅ Senior call flow completes end-to-end
5. ✅ Quiz plays through all questions
6. ✅ Video player controls work
7. ✅ Guardian dashboard displays
8. ✅ Logout/navigation cycle works

## 🚦 Next Steps

After confirming demo mode works:

1. ✅ **Deploy backend** to Cloud Run
2. ✅ **Set up Firebase** production project
3. ✅ **Update** `app_config.dart` with real URLs
4. ✅ **Switch** `kDemoMode = false`
5. ✅ **Test** real mode end-to-end
6. ✅ **Deploy** frontend to Firebase Hosting

---

**Need help?** Check `ROUTING_DEMO_MODE.md` for detailed documentation.
