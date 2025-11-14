# CoolTiger App Monorepo

Unified Flutter targets for the Senior mobile app, Guardian web dashboard, and Senior web showcase.

## Firebase Configuration

1. **Generate `firebase_options.dart`**

   - Install the FlutterFire CLI if needed: `dart pub global activate flutterfire_cli`.
   - From this directory run `flutterfire configure` and select the Firebase project plus the Android/iOS targets.
   - The command overwrites `lib/firebase_options.dart` with real values for mobile/macOS builds.

2. **Paste Guardian Web config**
   - In the Firebase Console add/register the Guardian web app.
   - Copy the config snippet (the `firebaseConfig` object) and replace every placeholder in `lib/bootstrap/firebase_bootstrap.dart` under `guardianWebOptions`
3. **Paste Senior Showcase Web config**
   - Register the Senior Showcase web app and copy its snippet.
   - Replace the placeholders within `seniorWebOptions` in the same file.

The entry points (`lib/main_senior.dart`, `lib/main_guardian.dart`, `lib/main_senior_web.dart`) automatically call `bootstrapFirebase(...)` so no additional work is required after the values are populated.

## Browser Showcase Notes

- The showcase flavor captures audio via the Web MediaRecorder APIs (through `flutter_webrtc`) and uploads it as `audio/webm`. Ensure the backend exposes the following CORS headers for `POST /api/v1/conversation` and `OPTIONS` preflight requests:
  - `Access-Control-Allow-Origin: https://<your-host>.web.app`
  - `Access-Control-Allow-Methods: GET,POST,OPTIONS`
  - `Access-Control-Allow-Headers: Content-Type, Authorization`
  - `Access-Control-Allow-Credentials: true`
- If your STT pipeline only accepts WAV/AAC, transcode `audio/webm` server-side or adjust the MediaRecorder mime type to a supported format.
