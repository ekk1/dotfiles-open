"""common functions"""
import os
import getpass
import json
import pprint
import requests

OPENAI_API_ENDPOINT="https://api.chatanywhere.com.cn"

if 'OPENAI_API_KEY' in os.environ:
    OPENAI_API_KEY = os.environ['OPENAI_API_KEY']
else:
    OPENAI_API_KEY = getpass.getpass("Enter API Key: ")

def list_models():
    """list all models"""
    header = {"Authorization": f"Bearer {OPENAI_API_KEY}"}
    r = requests.get(f"{OPENAI_API_ENDPOINT}/v1/models", headers=header, timeout=10)
    aa = json.loads(r.text)
    for model in aa['data']:
        print(model['id'])

def talk_with_gpt4(prompt="", msg=""):
    """simple talk"""
    header = {"Authorization": f"Bearer {OPENAI_API_KEY}"}
    message_list = []
    if prompt != "":
        message_list.append({"role": "system", "content": prompt})
    message_list.append({"role": "user", "content": msg})
    req_body = {
        "model": "gpt-4-0613",
        "messages": message_list,
    }
    r = requests.post(
            f"{OPENAI_API_ENDPOINT}/v1/chat/completions",
            headers=header,
            json=req_body,
            timeout=600,
            stream=True,
    )
    all_data = b""
    for line in r.iter_content(1024):
        print("Got: ", len(line))
        all_data += line
    try:
        aa = json.loads(all_data)
        ret = f"{aa['model']}:\n"
        ret += f" -> {msg}\n"
        ret += f" <- {aa['choices'][0]['message']['content']}\n"
        ret += f" -- {aa['choices'][0]['finish_reason']}\n"
        ret += f"Usage: {aa['usage']['prompt_tokens']} + "
        ret += f"{aa['usage']['completion_tokens']} = "
        ret += f"{aa['usage']['total_tokens']}\n"
        print(ret)
    except Exception as e:
        print(r.text)

def talk_with_gpt4_streamed(prompt="", msg=""):
    header = {"Authorization": f"Bearer {OPENAI_API_KEY}"}
    message_list = []
    if prompt != "":
        message_list.append({"role": "system", "content": prompt})
    message_list.append({"role": "user", "content": msg})
    req_body = {
        "model": "gpt-4-0613",
        "messages": message_list,
        "stream": True,
    }
    r = requests.post(
            f"{OPENAI_API_ENDPOINT}/v1/chat/completions",
            headers=header,
            json=req_body,
            timeout=600,
            stream=True,
    )
    for line in r.iter_lines():
        if len(line) > 1 and "data" in line.decode():
            try:
                data = json.loads(line.decode()[5:])
                if 'content' in data['choices'][0]['delta']:
                    print(data['choices'][0]['delta']['content'], end="", flush=True)
                else:
                    print()
                    print(line)
            except Exception as e:
                print(line)

if __name__ == "__main__":
    list_models()
