"""common functions"""
import os
import json
import requests

# OPENAI_API_ENDPOINT="https://api.chatanywhere.com.cn"
OPENAI_API_ENDPOINT="https://api.chatanywhere.cn"

SEPRATOR = "<<>>++__--!!@@##--<<>>\n"

def load_keys():
    if 'OPENAI_API_KEY' in os.environ:
        return os.environ['OPENAI_API_KEY']
    with open("key.txt", 'r', encoding='utf8') as f:
        data = f.read()
        while True:
            if data[-1] == "\n":
                data = data[:-1]
            else:
                break
    return data

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

def decode_io(data):
    data_parts = data.split(SEPRATOR)
    prompt_part = data_parts[0]
    prompt = prompt_part.split("PROMPT: ")[1]
    while True:
        if len(prompt) == 0:
            break
        if prompt[-1] == "\n":
            prompt = prompt[:-1]
        else:
            break
    ret = []
    for parts in data_parts[1:]:
        if parts.startswith("USER: "):
            cc = parts.split("USER: ")[1]
            while True:
                if len(cc) == 0:
                    break
                if cc[-1] == "\n":
                    cc = cc[:-1]
                else:
                    break
            ret.append({"role": "user", "content": cc})
        elif parts.startswith("ASSISTANT: "):
            cc = parts.split("ASSISTANT: ")[1]
            while True:
                if len(cc) == 0:
                    break
                if cc[-1] == "\n":
                    cc = cc[:-1]
                else:
                    break
            ret.append({"role": "assistant", "content": cc})
    return prompt, ret

def talk_with_gpt4_streamed(k, prompt, msg, model):
    if len(msg) == 0:
        raise RuntimeError("Message cannot be empty array")
    if msg[-1]['role'] != "user":
        raise RuntimeError("Last messgae has to be user")
    if msg[-1]['content'] == "":
        raise RuntimeError("Message cannot be empty")
    header = {"Authorization": f"Bearer {k}"}
    message_list = []
    if prompt != "":
        message_list.append({"role": "system", "content": prompt})
    for mm in msg:
        message_list.append(mm)
    print(message_list)
    req_body = {
        "model": model,
        # "model": "gpt-3.5-turbo-16k-0613",
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
    all_ret = ""
    for line in r.iter_lines():
        if len(line) > 1 and "data" in line.decode():
            try:
                data = json.loads(line.decode()[5:])
                if 'content' in data['choices'][0]['delta']:
                    cc = data['choices'][0]['delta']['content']
                    print(cc, end="", flush=True)
                    all_ret += cc
                else:
                    print()
                    print("Done")
            except Exception as e:
                print("DONE")
    return all_ret + "\n"

if __name__ == "__main__":
    list_models(load_keys())
