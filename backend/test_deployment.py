import requests
import json
import os

# Your deployed URL
# BASE_URL = "https://cooltiger-backend-304653364245.asia-northeast3.run.app"
BASE_URL = "http://127.0.0.1:8000"

# Test Configuration
SENIOR_ID = "test_senior_001"
AUDIO_FILE_PATH = "test_input.m4a"  # Make sure this file exists locally!

def print_step(step_name):
    print(f"\n{'='*50}")
    print(f"Testing: {step_name}")
    print(f"{'='*50}")

def test_start_conversation():
    print_step("1. Start Conversation (/conversation/start)")
    
    url = f"{BASE_URL}/conversation/start"
    payload = {"senior_id": SENIOR_ID}
    
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status() # Raise error for 400/500 codes
        
        data = response.json()
        call_id = data.get("call_id")
        print(f"✅ Success! Status Code: {response.status_code}")
        print(f"📞 Call ID: {call_id}")
        print(f"🤖 AI Greeting: {data.get('ai_text')}")
        
        # Verify TTS was generated
        tts_url = data.get("tts_url", "")
        if tts_url.startswith("data:audio"):
            print("🔊 TTS Audio Data received (Base64)")
        else:
            print(f"⚠️ Warning: TTS URL looks empty or invalid: {tts_url[:20]}...")
            
        return call_id
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Server Error: {e.response.text}")
        return None

def test_reply_conversation(call_id):
    print_step("2. Send Audio Reply (/conversation/reply)")
    
    if not os.path.exists(AUDIO_FILE_PATH):
        print(f"❌ Error: Audio file '{AUDIO_FILE_PATH}' not found. Please create a dummy m4a file.")
        return False

    url = f"{BASE_URL}/conversation/reply"
    
    # Prepare multipart/form-data
    with open(AUDIO_FILE_PATH, 'rb') as f:
        files = {'audio': ('test_input.m4a', f, 'audio/m4a')}
        data = {
            'senior_id': SENIOR_ID,
            'call_id': call_id
        }
        
        try:
            response = requests.post(url, data=data, files=files)
            response.raise_for_status()
            
            result = response.json()
            print(f"✅ Success! Status Code: {response.status_code}")
            print(f"👤 Senior Said (STT): {result.get('senior_text')}")
            print(f"🤖 AI Replied: {result.get('ai_text')}")
            return True
            
        except requests.exceptions.RequestException as e:
            print(f"❌ Failed: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"Server Error: {e.response.text}")
            return False

def test_end_conversation(call_id):
    print_step("3. End Conversation (/conversation/end)")
    
    url = f"{BASE_URL}/conversation/end"
    payload = {
        "senior_id": SENIOR_ID,
        "call_id": call_id
    }
    
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        
        data = response.json()
        print(f"✅ Success! Status Code: {response.status_code}")
        print(f"📝 Summary: {data.get('summary')}")
        print(f"❤️ Mood: {data.get('mood')}")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Server Error: {e.response.text}")
        return False

if __name__ == "__main__":
    # Ensure we have a dummy audio file for testing
    if not os.path.exists(AUDIO_FILE_PATH):
        print("⚠️ Creating dummy audio file for testing...")
        with open(AUDIO_FILE_PATH, "wb") as f:
            f.write(b'\x00' * 1000) # 1kb of silence/junk just to test upload
            
    print(f"🚀 Testing Deployment: {BASE_URL}")
    
    # Run the pipeline
    call_id = test_start_conversation()
    
    if call_id:
        success = test_reply_conversation(call_id)
        if success:
            test_end_conversation(call_id)
    
    print("\n✅ Test Complete.")