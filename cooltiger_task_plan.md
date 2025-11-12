# CoolTiger Task Navigator

This guide converts the high-level CoolTiger brief into discrete execution steps. Each task lists **who** must do it (Human vs AI), the objective, and—when AI-owned—a ready-to-run prompt. Follow the steps sequentially to avoid missing dependencies.

---

## How to Use

- Complete every **Manual** task before triggering dependent AI work; most manual steps deal with accounts, secrets, or console-only actions.
- When handing work to an AI agent, copy the full **AI Prompt** block and insert any placeholder values (e.g., `<FIREBASE_PROJECT_ID>`).
- Mark tasks done as you proceed; several later prompts assume artifacts (folders, config files, service accounts) already exist.

---

## Phase 0 – Accounts & Secrets (Manual Only)

### Step 0.1 – Create the Firebase Project

- **Owner:** Manual
- **Objective:** Provision `cooltiger` Firebase project with all required services.
- **Actions:**
  1. Create a Firebase project (enable Google Analytics if desired) and note the `projectId`.
  2. Enable **Firestore**, **Firebase Authentication** (Email/Password + Phone), **Cloud Storage**, **Cloud Messaging**, **App Hosting**, and **Cloud Scheduler**.
  3. Link the project to the matching Google Cloud project so App Hosting can deploy Cloud Run backends.

### Step 0.2 – Register App Targets

- **Owner:** Manual
- **Objective:** Register every platform target so Flutter apps can initialize Firebase.
- **Actions:**
  1. Add **iOS** and **Android** apps for the native SeniorApp (`com.cooltiger.senior` suggested).
  2. Add two **Web** apps: `guardian.web` and `senior.web`.
  3. Download the `google-services.json`, `GoogleService-Info.plist`, and web config snippets; store them in a secure shared folder for later AI steps.

### Step 0.3 – Acquire External AI API Credentials

- **Owner:** Manual
- **Objective:** Secure API keys the backend will call.
- **Actions:**
  1. Sign up for **Naver Cloud Platform** and create credentials for **Clova Speech** (STT) and **HyperCLOVA X** (LLM). Record the `invoke_url`, `secret`, and any required domain IDs.
  2. In Google Cloud, enable **Text-to-Speech**, create a service account with `Text-to-Speech Admin`, and download its JSON key.
  3. Store all secrets in a password manager; note which environment variable each key should map to (e.g., `NCP_CLOVA_API_KEY`, `HYPERCLOVA_API_KEY`, `GOOGLE_TTS_SA_JSON`).

### Step 0.4 – Provision Firebase/Admin Credentials

- **Owner:** Manual
- **Objective:** Generate service accounts and secrets for backend + automation.
- **Actions:**
  1. Create a Firebase Admin service account with Firestore, Messaging, and Storage scopes; download `cooltiger-firebase-admin.json`.
  2. Create a Cloud Run (App Hosting) service account with `roles/run.invoker`, `roles/pubsub.publisher`, `roles/firebasedatabase.admin`.
  3. Upload secrets to **Firebase App Hosting > Environment Variables** (or Secret Manager) so backend deployments can pull them by name.

### Step 0.5 – Store Publishing & Tester Setup

- **Owner:** Manual
- **Objective:** Ensure distribution channels exist before builds start.
- **Actions:**
  1. Join the **Apple Developer Program** and **Google Play Console** (if not already).
  2. Create Firebase App Distribution tester groups (e.g., `internal`, `pilot_seniors`) using guardian/senior emails.
  3. Prepare required compliance docs (privacy policy, terms) for later store submissions.

### Step 0.6 – Seed Product Data

- **Owner:** Manual
- **Objective:** Prepare initial Firestore documents for development/testing.
- **Actions:**
  1. Draft at least one guardian + senior profile with realistic `personalHistory` data.
  2. Outline cognitive training modules (card match, recall quiz, etc.) so AI tasks can reflect actual content needs.

---

## Phase 1 – Multi-Target Flutter Foundation (AI)

### Step 1.1 – Scaffold the Flutter Workspace

- **Owner:** AI Agent
- **Objective:** Create a single Flutter project that supports iOS, Android, and two web entry points.
- **Inputs Needed:** Flutter 3.22+, `projectId`, app IDs from Step 0.2.
- **Deliverables:** `pubspec.yaml` with required packages, `lib/main_senior.dart`, `lib/main_guardian.dart`, `lib/main_senior_web.dart`, shared `lib/app.dart`.
- **AI Prompt:**

```text
You are a senior Flutter architect. In an empty repo, initialize a Flutter project named `cooltiger_app` that targets iOS, Android, and Web.
Requirements:
1. Use sound null safety and add dependencies: firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging, http, freezed_annotation, json_annotation, flutter_riverpod (state), go_router (routing), just_audio (playback).
2. Create dedicated entry files:
   - lib/main_senior.dart (native mobile)
   - lib/main_guardian.dart (web dashboard)
   - lib/main_senior_web.dart (web showcase)
   Each should call a shared `CoolTigerApp` with a `TargetFlavor` enum to toggle UI layers.
3. Add platform folders with default bundle IDs matching placeholder IDs (`com.cooltiger.senior`, etc.).
Output all created files with concise explanations.
```

### Step 1.2 – Configure Firebase Initialization per Target

- **Owner:** AI Agent
- **Objective:** Ensure each entry point initializes Firebase with the correct options.
- **Deliverables:** `lib/bootstrap/firebase_bootstrap.dart`, generated `firebase_options.dart`, platform-specific config documentation.
- **AI Prompt:**

```text
You have the Flutter project from Step 1.1. Add Firebase initialization logic that:
1. Imports the FlutterFire-generated `firebase_options.dart` and exposes `Future<void> bootstrapFirebase(TargetFlavor flavor)`.
2. For mobile, loads native config files; for web, reads explicit options maps (`guardianWebOptions`, `seniorWebOptions`).
3. Initializes Firebase Messaging on mobile and requests notification permissions.
4. Guards initialization so each entry point simply awaits `bootstrapFirebase(flavor)` before running the app.
Document where to paste the config snippets from Firebase Console for both web targets.
```

### Step 1.3 – Define Core Models & Firestore Services

- **Owner:** AI Agent
- **Objective:** Mirror the provided data model (`guardians`, `seniors`, `conversation_logs`, `analysis_reports`) with immutable Dart models and service helpers.
- **Deliverables:** `lib/models/*.dart` (Freezed + JSON), `lib/services/firestore_service.dart` with CRUD helpers, error handling stubs.
- **AI Prompt:**

```text
Inside the Flutter repo, add Freezed models for Guardian, Senior, ConversationLog, AnalysisReport, and TrainingModuleResponse (for Feature 3).
Create a `FirestoreService` that exposes:
- Stream<List<ConversationLog>> conversationStream(String seniorId)
- Future<void> saveConversationLog(ConversationLog log)
- Future<List<AnalysisReport>> fetchReports(String guardianId)
Use converters so the data stays typed. Include TODO comments where role-based security rules will live.
```

### Step 1.4 – Shared UI + Routing Skeleton

- **Owner:** AI Agent
- **Objective:** Provide baseline navigation scaffolding for each flavor.
- **Deliverables:** `lib/router/app_router.dart`, placeholder screens (`SeniorHomeScreen`, `GuardianDashboardScreen`, `ShowcaseScreen`), responsive layout helpers.
- **AI Prompt:**

```text
Implement GoRouter-based navigation that:
1. Uses `TargetFlavor` to decide which initial route tree to expose.
2. Provides placeholders for:
   - SeniorHomeScreen (native mobile controls + microphone permission stub)
   - GuardianDashboardScreen (web-optimized layout with side nav)
   - ShowcaseScreen (simplified senior UI)
3. Includes a shared theme + typography suited for accessibility (large fonts, high contrast).
Return the updated files and explain how each flavor wires up.
```

---

## Phase 2 – Python Backend & APIs (AI)

### Step 2.1 – FastAPI Project Bootstrap

- **Owner:** AI Agent
- **Objective:** Create the Python backend structure deployable via Firebase App Hosting (Cloud Run).
- **Deliverables:** `/backend` folder with `main.py`, `routers`, `services`, `pyproject.toml`, Docker/App Hosting config (`firebase.json` will reference `main:app`).
- **AI Prompt:**

```text
Set up a FastAPI project under `backend/` with:
- Entry file `main.py` exposing `app`.
- Routers: `conversation.py`, `scheduler.py`, `analysis.py`, `health.py`.
- Services: `firestore_client.py`, `clova_speech.py`, `clova_studio.py`, `google_tts.py`, `fcm_client.py`.
- Dependency injection for Firestore (via google-cloud-firestore).
Include Pydantic schemas mirroring the Firestore models and ensure the Docker/App Hosting runtime is python311 with `uvicorn`.
```

### Step 2.2 – Conversation Pipeline Implementation

- **Owner:** AI Agent
- **Objective:** Implement the 8-step Walkie-Talkie pipeline inside `POST /api/v1/conversation`.
- **Deliverables:** Working endpoint handling audio upload, calling STT → LLM → TTS, persisting logs, returning either audio bytes or structured JSON.
- **AI Prompt:**

```text
Inside backend/routers/conversation.py implement:
1. `POST /api/v1/conversation` accepting multipart audio + metadata (seniorId, guardianId).
2. Flow:
   a. Store raw audio in Cloud Storage.
   b. Call `clova_speech.transcribe(audio_uri)`; capture transcript + confidence.
   c. Call `clova_studio.generate_reply(transcript, personal_history, conversation_context)`.
   d. Decide whether to emit a training module (flag in LLM result). If training, pre-generate TTS audio and build the JSON payload shown in project.md.
   e. Call `google_tts.synthesize(reply_text)` for regular responses and stream audio bytes back.
3. Persist user/AI turns into `conversation_logs`.
Expose environment variable names for each external API key/secrets and fail gracefully when unset.
Return updated files plus unit-test-ready helpers.
```

_skipped_

### Step 2.3 – Proactive Check-in Trigger

- **Owner:** AI Agent
- **Objective:** Implement `POST /api/v1/trigger-checkin` so Cloud Scheduler can initiate FCM pushes.
- **Deliverables:** Endpoint + service that queries seniors due for check-in and sends FCM notifications with the opener payload.
- **AI Prompt:**

```text
Create `trigger-checkin` logic that:
1. Accepts optional override time (for manual testing) otherwise uses current UTC.
2. Queries Firestore `seniors` where `settings.proactiveCall == true` and `settings.checkinTime` within ±5 minutes.
3. Publishes an FCM message with data payload `{ "action": "start_conversation", "seniorId": ... }`.
4. Logs notification events to `system_logs` collection for observability.
Provide instructions for setting the Cloud Scheduler target URL and auth (OIDC) in the README.
```

### Step 2.4 – Asynchronous Analysis Endpoint

- **Owner:** AI Agent
- **Objective:** Implement `POST /api/v1/run-analysis` that computes sentiment, word count, type-token ratio, and speaking rate over new logs.
- **Deliverables:** Batch processing service writing to `/analysis_reports`.
- **AI Prompt:**

```text
Implement a background-safe analysis routine:
1. Query `conversation_logs` where `analysisStatus != "complete"`.
2. Group by `seniorId` and compute metrics (sentiment via TextBlob or AWS Comprehend equivalent stub, TTR, speaking rate based on timestamps).
3. Save aggregated metrics + summary text to `analysis_reports` with `analysisDate`.
4. Mark processed logs as complete.
Ensure the endpoint is idempotent and document how Cloud Scheduler should hit it (separate cron from trigger-checkin).
```

---

## Phase 3 – Frontend Feature Delivery (AI)

### Step 3.1 – SeniorApp (Native) Walkie-Talkie + FCM

- **Owner:** AI Agent
- **Objective:** Build the press-to-talk UI, audio capture pipeline, and FCM handling.
- **Deliverables:** Widgets/services under `lib/features/senior/`, background handlers for `firebase_messaging`, integration with conversation endpoint.
- **AI Prompt:**

```text
For the native SeniorApp flavor:
1. Implement a `PressToTalkController` that records AAC audio via `record` plugin, uploads to backend, and plays returned audio with `just_audio`.
2. Show large, high-contrast UI with accessibility labels and state transitions ("Press to Talk", "Thinking").
3. Handle FCM messages of type `start_conversation` to automatically invoke the greeting audio request.
4. Persist local copies of transcripts for offline viewing.
Return all new files and explain testing steps (unit + integration).
```

### Step 3.2 – SeniorApp Showcase (Web)

- **Owner:** AI Agent
- **Objective:** Port the conversation loop to Flutter Web (no push notifications).
- **Deliverables:** Web-friendly UI with microphone permissions + fallback messaging.
- **AI Prompt:**

```text
Using the same services, create a web-only implementation:
1. Replace press gestures with "Start Recording" / "Stop" buttons.
2. Use the `flutter_webrtc` or `mic_stream`-compatible package for browser audio capture, converting to a format the backend accepts.
3. Detect unsupported browsers and show guidance.
4. Reuse the cognitive training renderer so stakeholders see the full loop.
Document any backend CORS headers needed.
```

### Step 3.3 – GuardianApp Dashboard

- **Owner:** AI Agent
- **Objective:** Build responsive dashboards summarizing reports + live logs.
- **Deliverables:** `lib/features/guardian/` with widgets for analysis cards, timeline table, alert center.
- **AI Prompt:**

```text
Create a Guardian dashboard that:
1. Shows the latest `analysis_reports` per senior with sentiment, word count, speaking rate, TTR.
2. Streams recent `conversation_logs` with filters (last 24h, 7d).
3. Highlights anomalies (e.g., sentiment negative for 3 calls) and recommends actions.
4. Includes authentication guard (Firebase Auth email/password) and a settings view for scheduling.
Ensure layout works down to 768px width.
```

### Step 3.4 – Cognitive Training Module Renderer

- **Owner:** AI Agent
- **Objective:** Support Feature 3 by rendering structured training modules returned by backend.
- **Deliverables:** Module registry, UI components, JSON parsing logic.
- **AI Prompt:**

```text
Implement a `TrainingModuleEngine` that:
1. Parses backend JSON with `type`, `tts_audio_url`, `module_type`, `module_data`.
2. Supports at least two module types: `card_match` and `memory_recall`.
3. Auto-plays the provided TTS audio while showing large, tappable UI elements.
4. Reports completion metrics back to Firestore (`training_results` collection).
5. Works across native and web flavors with responsive sizing.
```

---

## Phase 4 – Hosting, Automation, and Ops

### Step 4.1 – Firebase App Hosting Configuration (AI)

- **Owner:** AI Agent
- **Objective:** Author the `firebase.json` + `firebase.rc` files that wire web targets and backend per the spec.
- **Deliverables:** Config matching the sample in project.md plus README notes.
- **AI Prompt:**

```text
Create firebase.json that:
1. Defines `appHosting.backends[0]` for `cooltiger-backend` (python311, entry `backend/main.py` -> `app`).
2. Adds rewrites:
   - `/api{,/**}` -> backend
   - `/guardian{,/**}` -> web entry `lib/main_guardian.dart`
   - `**` -> web entry `lib/main_senior_web.dart`
3. Includes hosting cache headers suitable for SPA + API.
Also author `.firebaserc` with the `<FIREBASE_PROJECT_ID>` alias and document the `firebase deploy` command.
```

### Step 4.2 – CI/CD Pipeline (AI)

- **Owner:** AI Agent
- **Objective:** Provide automated testing + deployment workflow.
- **Deliverables:** `.github/workflows/deploy.yml` (or similar) running Flutter tests, backend tests, and `firebase deploy`.
- **AI Prompt:**

```text
Add a GitHub Actions workflow that:
1. Spins up Flutter stable, runs `flutter test` for shared code, and `flutter test --target=lib/main_guardian.dart` for web specifics.
2. Sets up Python 3.11, installs backend deps, and runs pytest.
3. Uses Firebase CLI (with token) to deploy backend + web on pushes to `main`.
Provide secrets instructions (`FIREBASE_TOKEN`, `GCLOUD_PROJECT`) in README updates.
```

### Step 4.3 – Connect Firebase Hosting (Manual)

- **Owner:** Manual
- **Objective:** Link local repo to Firebase Hosting & App Hosting deployments.
- **Actions:**
  1. Install Firebase CLI locally, run `firebase login`, then `firebase use <projectId>`.
  2. Run one manual `firebase deploy --only apphosting` to ensure permissions + secrets resolve.
  3. Verify Cloud Run service, Guardian web, and Showcase web all load via `https://<projectId>.web.app`.

### Step 4.4 – Cloud Scheduler Jobs (Manual)

- **Owner:** Manual
- **Objective:** Wire time-based triggers for proactive calls and analysis.
- **Actions:**
  1. Create Scheduler job `trigger-checkin` (Cron `0 * * * *` or as desired) pointing to `/api/v1/trigger-checkin`, using OIDC auth with the App Hosting service account.
  2. Create Scheduler job `run-analysis` (e.g., every 2 hours) pointing to `/api/v1/run-analysis`.
  3. Confirm logs in Cloud Logging show 2xx responses.

### Step 4.5 – Native Build & Distribution (Manual)

- **Owner:** Manual
- **Objective:** Produce and distribute native SeniorApp binaries.
- **Actions:**
  1. For Android: `flutter build apk -t lib/main_senior.dart --flavor prod` (once flavors exist), upload to Firebase App Distribution and Play Console.
  2. For iOS: `flutter build ipa -t lib/main_senior.dart`, upload via Transporter, and configure TestFlight.
  3. Maintain release notes and tester instructions in a shared doc.

---

## Appendix – Placeholder Mapping

- `<FIREBASE_PROJECT_ID>` → The project ID from Step 0.1.
- `<NCP_CLOVA_SECRET>` / `<HYPERCLOVA_API_KEY>` / `<GOOGLE_TTS_SA_JSON>` → Secrets created in Step 0.3.
- `<FCM_SERVER_KEY>` → From Firebase console, Cloud Messaging tab.

Update the prompts with actual values before execution to keep AI runs deterministic.
