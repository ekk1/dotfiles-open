"""quick talk"""
import string
import sys
import os
import json
import requests

# OPENAI_API_ENDPOINT="https://api.chatanywhere.cn"
# OPENAI_API_ENDPOINT="https://api.chatanywhere.com.cn"
OPENAI_API_ENDPOINT="https://api.openai.com"

print("Using: ", OPENAI_API_ENDPOINT)

def load_keys():
    with open("key.txt", 'r', encoding='utf8') as f:
        data = f.read()
    return data.strip()

def list_models(k):
    """list all models"""
    header = {"Authorization": f"Bearer {k}"}
    r = requests.get(f"{OPENAI_API_ENDPOINT}/v1/models", headers=header, timeout=10)
    try:
        aa = json.loads(r.text)
        for model in aa['data']:
            print(model['id'])
    except:
        print(r.text)

def make_gpt_talk(k, msg, voice, model):
    header = {"Authorization": f"Bearer {k}"}
    req_body = {
        "model": model,
        "input": msg,
        "voice": voice,
    }
    r = requests.post(
        f"{OPENAI_API_ENDPOINT}/v1/audio/speech",
        headers=header, json=req_body, timeout=600,
    )
    with open(voice + "-test.mp3", 'wb') as f:
        f.write(r.content)

if not os.path.exists("key.txt"):
    with open("key.txt", 'w', encoding="utf8") as f:
        f.truncate()
    print("Please put the key in key.txt")
    sys.exit(2)

models = [
    "tts-1-hd",
]
use_model = models[0]

print("Choose model, default [0]:")
for ii in range(0, len(models)):
    print(f"[{ii}]: {models[ii]}")

while True:
    a = input("Select: ")
    if a == "ll":
        list_models(load_keys())
        continue
    if a not in string.digits:
        print("No such model")
        continue
    if len(a) == 0:
        break
    if int(a) < len(models):
        use_model = models[int(a)]
        break
    print("No such model")

print("Using model: ", use_model)

msg = input("Enter message")
make_gpt_talk(load_keys(), msg, "alloy", use_model)
