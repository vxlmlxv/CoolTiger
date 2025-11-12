### **[CONFIDENTIAL] AI System Instruction Document: Project CoolTiger**

### 1. Project Overview

**Project CoolTiger** is a proactive, AI-driven wellness companion designed for seniors, specifically targeting those at risk of mild cognitive impairment (MCI) and social isolation. The service's core function is to emulate a human check-in call ("안부전화"). It will proactively initiate conversations, provide personalized engagement using the senior's personal history, and conduct simple cognitive training. All interactions are analyzed asynchronously to provide data-driven peace of mind to the senior's designated guardians.

### 2. System Role & Mission

**Your Role:** You are the Lead AI System Architect. Your task is to generate the foundational code, architecture, and logic for this application based on the specified tech stack.

**Core Mission:**

1. **For Seniors (Users):** To act as a warm, reliable, and engaging companion ("CoolTiger"), reducing loneliness and providing daily cognitive stimulation.
2. **For Guardians (Customers):** To provide objective, data-driven "peace of mind" by transforming ambiguous "check-in calls" into actionable wellness reports.

### 3. High-Level System Architecture

This project is built on a **"One Codebase, Three Targets"** strategy using Flutter, all supported by a unified Firebase backend.

#### 3.1. The Three Application Targets

1. **`SeniorApp (Native Mobile)` (iOS/Android):** This is the core product for the senior. It _must_ be a native mobile app to handle critical features reliably:

   - **Proactive FCM Push Notifications** (the "check-in call").
   - **Reliable Microphone Access** (for the Walkie-Talkie).
   - **Background/Lock-screen interaction**.
   - **Initial Distribution:** Firebase App Distribution.
   - **Final Distribution:** Apple App Store & Google Play Store.

2. **`GuardianApp (Web)`:** This is the dashboard for the family/guardian.

   - **Why Web:** Zero-installation, accessible from any device (laptop, phone browser).
   - **Deployment:** Deployed via **Firebase App Hosting**.

3. **`SeniorApp - Showcase (Web)`:** A public-facing demo of the `SeniorApp`.

   - **Why Web:** Allows stakeholders, investors, and potential users to try the app's core conversation loop instantly in a browser without any installation.
   - **Limitations:** This version _cannot_ support the proactive push notification. It is for "in-app" experience showcase only.
   - **Deployment:** Deployed via **Firebase App Hosting**.

#### 3.2. Backend & Hosting Strategy

- **Backend (Service):** A **Python (FastAPI/Flask)** Web Server. This containerized application will expose all API endpoints (e.g., `/api/v1/conversation`).
- **BaaS (Database/Auth):** **Firebase** (Firestore, Firebase Authentication, FCM, Storage, Cloud Scheduler).
- **Hosting:** **Firebase App Hosting** will be the single deployment tool. It will build and host:
  1. The **Python Backend** (on Cloud Run).
  2. The **`GuardianApp (Web)`**.
  3. The **`SeniorApp - Showcase (Web)`**.
- **AI API Stack (Hybrid):**
  - **STT (Speech-to-Text):** **NCP Clova Speech** (Best-in-class Korean STT + free tier).
  - **LLM (Language Model):** **NCP HyperCLOVA X** (Best Korean context/personal history integration).
  - **TTS (Text-to-Speech):** **Google Cloud Text-to-Speech** (Generous "Always Free" tier).

### 4. Example Key Data Models (Firestore Collections)

JSON

```
/guardians/{guardianId}
  email: "david.son@example.com"
  name: "David (Son)"

/seniors/{seniorId}
  guardianId: "ref_to_guardianId"
  name: "Mary (Mother)"
  settings: {
    checkinTime: "10:00AM",
    proactiveCall: true
  }
  personalHistory: { ... } // Hometown, FavoriteSong, etc.

/conversation_logs/{logId}
  seniorId: "ref_to_seniorId"
  timestamp: "..."
  speaker: "user" | "ai"
  transcript: "The weather is lovely today."
  audioUrl: "gs://storage_bucket/user_speech_123.wav"

/analysis_reports/{reportId}
  seniorId: "ref_to_seniorId"
  date: "..."
  metrics: {
    sentiment: "positive",
    wordCount: 150,
    ttr: 0.65, // Type-Token Ratio
    speakingRate: 120 // Words per minute
  }
  summary: "AI summary of the call."
```

### 5. Core Feature Specifications (Instructions)

#### Feature 1: Proactive Check-in Call

- **Goal:** Initiate the conversation without senior intervention.
- **Note:** This feature is **exclusive to the `SeniorApp (Native Mobile)` build** due to its reliance on reliable FCM push notifications.
- **Instruction:**
  1. Use **Firebase Cloud Scheduler** to trigger an HTTP request to the Python backend endpoint: `POST /api/v1/trigger-checkin`.
  2. The backend endpoint queries Firestore for seniors scheduled at that time.
  3. It sends an **FCM Push Notification** (via Firebase Admin SDK) to the senior's device.
  4. The **native `SeniorApp`**, upon receiving the FCM, will open and auto-play the first AI greeting by calling the `/api/v1/conversation` endpoint.

#### Feature 2: The "Walkie-Talkie" Conversation Pipeline (CRITICAL)

- **Goal:** A simple "Press-to-Talk" interface for conversation.
- **Applicable to:** `SeniorApp (Native Mobile)` and `SeniorApp - Showcase (Web)`.
- **Instruction (The 8-Step Hybrid Pipeline):**
  1. **[Flutter App]** Senior presses [Tap to Talk] button. App records audio locally.
  2. **[Flutter App]** Senior taps the button again. UI shows "Thinking...".
  3. **[Flutter → Backend]** App sends the audio file via a `POST` request to **`POST /api/v1/conversation`**.
  4. **[Backend: Step A - STT]** Python server calls **NCP Clova Speech API**.
  5. **[Backend: Step B - LLM]** Python server calls **NCP HyperCLOVA X API** (with transcript, history, and `personalHistory` from Firestore).
  6. **[Backend: Step C - TTS]** Python server calls **Google Cloud Text-to-Speech API** (with LLM's text response).
  7. **[Backend → Flutter]** Google TTS returns audio. The Python server returns this audio file as the HTTP response.
  8. **[Flutter App]** The app receives the audio response and **auto-plays it**.

#### Feature 3: Integrated Cognitive Training

- **Goal:** Seamlessly blend conversation with simple, screen-based training.
- **Instruction:**

  1. The HyperCLOVA X LLM will decide when to initiate training.
  2. When it does, the **`/api/v1/conversation`** endpoint will return a structured **JSON object** instead of an audio file.
  3. _Example JSON:_

     JSON

     ```
     {
       "type": "training_module",
       "tts_audio_url": "...", // (Pre-generated by Google TTS)
       "tts_prompt": "Let's try a quick memory game!",
       "module_type": "card_match",
       "module_data": [ ... ]
     }
     ```

  4. The **Flutter app** (both Senior Native and Senior Web) must be built to parse this JSON, play the `tts_audio_url`, and render the visual game module.

#### Feature 4: Asynchronous "MVP" Phenotyping

- **Goal:** Analyze conversation data for the guardian's report without slowing down the conversation.
- **Instruction:**
  1. A **Cloud Scheduler** job will periodically call a backend endpoint: `POST /api/v1/run-analysis`.
  2. This endpoint will query `conversation_logs` that have not been analyzed.
  3. It will run **Python-based analysis** on the **transcripts** and **timestamps** (NOT acoustics) to generate metrics (TTR, sentiment, speaking rate).
  4. Results are saved to the **`/analysis_reports`** collection, which the `GuardianApp (Web)` will read and display.

### 6. Deployment & Build Strategy

This is the central plan for managing our three targets.

#### 6.1. Firebase App Hosting Configuration (`firebase.json`)

You must use both the `hosting` and `appHosting` keys. This file will orchestrate our entire web and backend deployment.

JSON

```
{

  "appHosting": {
    "backends": [
      {
        "id": "cooltiger-backend", // Your Python API
        "region": "us-central1",
        "entryPoint": "main:app", // Assumes a `main.py` with a FastAPI/Flask `app`
        "platform": "python311"
      }
    ],
    "rewrites": [
      {
        "source": "/api{,/**}", // ALL requests to /api...
        "backend": {
          "backendId": "cooltiger-backend" // ...are sent to your Python backend.
        }
      },
      {
        "source": "/guardian{,/**}", // Requests to /guardian...
        "web": {
          "entryPoint": "lib/main_guardian.dart" // ...build and serve the Guardian web app.
        }
      },
      {
        "source": "**", // All other requests...
        "web": {
          "entryPoint": "lib/main_senior_web.dart" // ...build and serve the Senior Showcase.
        }
      }
    ]
  }
}
```

#### 6.2. Flutter Build Targets & Distribution

**Web Apps (Guardian & Showcase):**

- **Build:** Handled **automatically** by Firebase App Hosting when you run `firebase deploy`.
- **Access:**
  - `your-project-id.web.app/` will serve the `SeniorApp - Showcase`.
  - `your-project-id.web.app/guardian` will serve the `GuardianApp`.

**Native App (Senior):**

- **Build:** Must be built **manually** from your command line, pointing to the correct entry point.
  - **Android:** `flutter build apk -t lib/main_senior.dart`
  - **iOS:** `flutter build ipa -t lib/main_senior.dart`
- **Testing Distribution:** Upload the resulting `.apk` or `.ipa` file to **Firebase App Distribution** to send to your testers.
- **Production Distribution:** Upload to the Google Play Store and Apple App Store.
