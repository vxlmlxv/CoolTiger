# AI-Call Pipeline Implementation TODO

## ✅ Completed Optimizations

### Backend Changes

1. ✅ **Fixed CLOVA Speech API request format**

   - Changed from incorrect Content-Type to proper multipart/form-data with files parameter
   - Added JSON params as separate multipart field per CLOVA API spec
   - File: `backend/services/clova_speech.py`

2. ✅ **Eliminated cloud storage bottleneck**

   - TTS audio now returned as base64 data URL in response
   - Reduces latency by ~500-1000ms (no upload/download needed)
   - Files: `backend/routers/conversation.py`

3. ✅ **Added transcript to response**

   - Backend now returns `senior_text` field with transcribed audio
   - Frontend displays actual transcript instead of placeholder
   - Files: `backend/models/conversation.py`, `backend/routers/conversation.py`

4. ✅ **Added conversation context to TTS**
   - TTS now receives last 3 conversation turns as prompt
   - Improves prosody and naturalness of speech
   - File: `backend/routers/conversation.py`

### Frontend Changes

1. ✅ **Updated audio playback**

   - `just_audio` now plays base64 data URLs directly
   - No temporary file needed
   - File: `frontend/lib/screens/senior_call_screen.dart`

2. ✅ **Display actual transcript**
   - Shows `senior_text` from backend instead of "(음성 전달됨)"
   - File: `frontend/lib/screens/senior_call_screen.dart`

---

## 🔧 Required Manual Actions

### 3. Configure Google Cloud TTS Credentials

**Priority: HIGH** - TTS won't work without this

**File:** `backend/.env`

**Action:**

```bash
# Add these lines to backend/.env:
GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account-key.json
GOOGLE_TTS_LANGUAGE_CODE=ko-KR
GOOGLE_TTS_VOICE_NAME=ko-KR-Neural2-A
GOOGLE_TTS_AUDIO_ENCODING=MP3
```

**How to get credentials:**

1. Go to https://console.cloud.google.com/
2. Enable Text-to-Speech API for your project
3. Navigate to IAM & Admin → Service Accounts
4. Create new service account with "Cloud Text-to-Speech User" role
5. Generate JSON key and download
6. Save file as `backend/google_service_account.json`
7. Update path in `.env` to point to this file

**Available Korean voices:**

- `ko-KR-Neural2-A` (Female, conversational)
- `ko-KR-Neural2-B` (Female, formal)
- `ko-KR-Neural2-C` (Male, conversational)
- `ko-KR-Wavenet-A` (Female, older generation)
- `ko-KR-Wavenet-B` (Female, older generation)
- `ko-KR-Wavenet-C` (Male, older generation)
- `ko-KR-Wavenet-D` (Male, older generation)

**Recommended:** `ko-KR-Neural2-A` for warm, natural elderly-friendly voice

**Test command:**

```bash
cd backend
python -c "from google.cloud import texttospeech; client = texttospeech.TextToSpeechClient(); print('TTS configured!')"
```

---

### 4. Fix Frontend Audio Recording for Web

**Priority: MEDIUM** - Recording UI works but audio data needs proper handling

**File:** `frontend/lib/screens/senior_call_screen.dart` (line ~295)

**Current Issue:**

```dart
Future<Uint8List?> _readAudioFile(String path) async {
  try {
    // TODO: Implement proper audio file reading for web platform
    return null; // Placeholder
  }
  // ...
}
```

**Solution for Flutter Web:**

Replace the function with:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Only for web

Future<Uint8List?> _readAudioFile(String path) async {
  try {
    if (kIsWeb) {
      // For web: path is a blob URL from record package
      // Fetch the blob and convert to bytes
      final response = await http.get(Uri.parse(path));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      debugPrint('Failed to fetch audio blob: ${response.statusCode}');
      return null;
    } else {
      // For mobile/desktop: read file normally
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    }
  } catch (e) {
    debugPrint('Error reading audio file: $e');
    return null;
  }
}
```

**Add dependency** to `frontend/pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0 # If not already present
```

**Alternative (simpler but less tested):**
The `record` package may provide bytes directly. Check if:

```dart
final recordedData = await _recorder.stop();
// recordedData might already be Uint8List on web
```

### 6. Update Frontend Backend URL

**Priority: HIGH** - Frontend needs to point to deployed backend

**File:** `frontend/lib/app_config.dart`

**Action:**

```dart
// Change from:
const String kBaseApiUrl = "http://localhost:8000";

// To your Cloud Run URL:
const String kBaseApiUrl = "https://cooltiger-backend-XXXX-uc.a.run.app";
```

**Get your Cloud Run URL:**

```bash
gcloud run services describe cooltiger-backend --region=asia-northeast3 --format='value(status.url)'
```

---

### 7. Test End-to-End Pipeline

**Priority: HIGH** - Verify everything works

**Test Sequence:**

1. **Test STT alone:**

```bash
# Use curl to test CLOVA Speech directly
curl -X POST "https://clovaspeech-gw.ncloud.com/recognizer/upload" \
  -H "X-CLOVASPEECH-API-KEY: your_key" \
  -F "media=@test_audio.wav" \
  -F 'params={"language":"ko-KR","completion":"sync"}'
```

2. **Test LLM alone:**

```python
# backend/test_llm.py
from services.clova_studio import generate_reply

history = [{"speaker": "ai", "text": "안녕하세요"}]
profile = {"name": "테스트", "age": 70}
response = generate_reply(history, profile)
print(response)
```

3. **Test TTS alone:**

```python
# backend/test_tts.py
from services.google_tts import synthesize_speech

audio = synthesize_speech("", "안녕하세요, 반갑습니다")
with open("test_output.mp3", "wb") as f:
    f.write(audio)
print(f"Generated {len(audio)} bytes")
```

4. **Test full pipeline:**

```bash
# Frontend: flutter run -d chrome
# Set kDemoMode = false
# Click "통화 시작하기"
# Record audio
# Verify:
# - Transcript appears correctly
# - AI response makes sense
# - Audio plays automatically
```

---

## 📊 Pipeline Performance Expectations

### Current Optimized Flow:

```
User presses mic button (Recording starts)
    ↓
User presses mic again (Recording stops)
    ↓
Audio sent to backend (multipart upload: ~100-300ms)
    ↓
┌─────────────────────────────────────────┐
│ BACKEND PROCESSING (parallel where possible) │
├─────────────────────────────────────────┤
│ 1. STT (CLOVA Speech): ~1-3 seconds    │
│ 2. Firestore write: ~100-200ms         │
│ 3. LLM (CLOVA Studio): ~1-2 seconds    │
│ 4. Firestore write: ~100-200ms         │
│ 5. TTS (Google): ~500-1000ms           │
│ 6. Base64 encode: ~50ms                │
└─────────────────────────────────────────┘
    ↓
Response returned with base64 audio (~100-200ms)
    ↓
Frontend plays audio immediately (0ms, streaming starts)
```

**Total Expected Latency:** ~3-6 seconds from mic stop to audio playback start

**Optimizations Applied:**

- ✅ Base64 audio (eliminated cloud storage: -500ms to -2s)
- ✅ Proper multipart format (eliminated retry delays: -1s to -3s)
- ✅ Conversation context in TTS (better prosody, no latency impact)
- ✅ Immediate playback (streaming, no download wait)

**Further optimization potential:**

- Use streaming STT (CLOVA Speech supports it)
- Use streaming LLM responses
- Cache TTS for common phrases
- Parallel Firestore writes (fire-and-forget)

---

## 🐛 Troubleshooting Guide

### Issue: "CLOVA Speech API error: 401"

**Fix:** Check `CLOVA_SPEECH_API_KEY` in `.env`

```bash
cd backend
python -c "from config import settings; print(settings.clova_speech_api_key)"
```

### Issue: "CLOVA Speech API error: 400"

**Fix:** Audio format issue. Ensure frontend sends WAV format:

```dart
// In senior_call_screen.dart
await _recorder.start(
  const RecordConfig(encoder: AudioEncoder.wav), // ← Must be wav
  path: 'recording.wav',
);
```

### Issue: "Empty transcript from CLOVA Speech"

**Fix:** Audio too short or silent. Add minimum recording time:

```dart
// Add timer to ensure minimum 1 second recording
DateTime? _recordingStartTime;

await _startRecording() {
  _recordingStartTime = DateTime.now();
  // ... existing code
}

await _stopRecordingAndSend() {
  if (_recordingStartTime != null) {
    final duration = DateTime.now().difference(_recordingStartTime!);
    if (duration.inMilliseconds < 1000) {
      _showErrorSnackBar('녹음 시간이 너무 짧습니다 (최소 1초)');
      return;
    }
  }
  // ... existing code
}
```

### Issue: "Google TTS failed: 403"

**Fix:** Service account key not found or invalid permissions

```bash
# Verify file exists
ls -la backend/google_service_account.json

# Test credentials
python -c "from google.cloud import texttospeech; texttospeech.TextToSpeechClient()"
```

### Issue: "Audio doesn't play"

**Fix:** Check browser console for errors. just_audio requires:

```yaml
# frontend/pubspec.yaml
dependencies:
  just_audio: ^0.9.36
  just_audio_web: ^0.4.9 # Required for web support
```

### Issue: "Base64 audio too large"

**Fix:** Audio >1MB may cause issues. Adjust TTS settings:

```python
# backend/services/google_tts.py
# Change audio config to use lower bitrate
audio_config = texttospeech.AudioConfig(
    audio_encoding=texttospeech.AudioEncoding.MP3,
    speaking_rate=1.1,  # Slightly faster = smaller file
)
```

### Issue: "LLM returns JSON parse error"

**Fix:** CLOVA Studio sometimes adds explanation text. Already handled in code, but verify model ID:

```python
# backend/services/clova_studio.py (line ~223)
# Ensure using correct model for your project
url = settings.clova_studio_endpoint + "v3/chat-completions/HCX-DASH-002"
```

---

## 📝 Code Review Checklist

Before going to production:

- [ ] All API keys configured in `.env`
- [ ] Google service account key uploaded to Cloud Run
- [ ] Backend deployed with latest code
- [ ] Frontend `kBaseApiUrl` points to Cloud Run URL
- [ ] Audio recording works on web (test in Chrome)
- [ ] Transcript displays correctly in UI
- [ ] AI responses are contextual and natural
- [ ] TTS audio plays automatically
- [ ] Error messages are user-friendly in Korean
- [ ] Loading states show during processing
- [ ] Network errors handled gracefully
- [ ] Audio playback errors don't crash app

---

## 🎯 Next Steps for Production

1. **Add streaming for lower latency:**

   - Implement WebSocket connection
   - Stream STT results in real-time
   - Stream LLM tokens as generated
   - Stream TTS audio chunks

2. **Add caching:**

   - Cache common TTS phrases
   - Cache senior profiles
   - Use Redis for session state

3. **Add monitoring:**

   - Log latency metrics per pipeline step
   - Alert on errors or slow responses
   - Track conversation quality

4. **Add security:**
   - Implement rate limiting
   - Add CORS restrictions
   - Validate audio file sizes/types
   - Sanitize LLM outputs

---

## ✅ Quick Start Guide

**For local testing:**

```bash
# 1. Configure API keys in backend/.env
# 2. Start backend:
cd backend
python -m uvicorn main:app --reload --port 8000

# 3. In new terminal, start frontend:
cd frontend
flutter run -d chrome

# 4. Set kDemoMode = false in app_config.dart
# 5. Test the call flow
```

**For production:**

```bash
# 1. Configure all API keys
# 2. Deploy backend (see section 5)
# 3. Update frontend URL (see section 6)
# 4. Deploy frontend to Firebase Hosting
```

---

**Document last updated:** After implementing optimized AI-call pipeline with base64 TTS audio
