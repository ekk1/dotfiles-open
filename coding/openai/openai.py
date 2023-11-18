"""general openai bot"""
import string
import sys
import os
import json
import requests
import binascii

SEPRATOR = "<<>>++__--!!@@##--<<>>\n"

key_list = []

QUICK_PROMPT = {
    "ff": "帮我翻译一下我发过来的内容到中文",
}

models = [
    "gpt-4-1106-preview",
    "gpt-3.5-turbo-1106",
    "dall-e-3",
]

def load_all_keys():
    """load all keys from db file"""
    with open("key.txt", encoding="utf8") as f:
        for k in json.loads(f.read()):
            key_list.append(k)

def init_io_file():
    """init io result file"""
    print("快速 prompt: ")
    for kk in QUICK_PROMPT:
        print(kk + ":", QUICK_PROMPT[kk])
    pp = input("请输入 Prompt: ")
    prom = QUICK_PROMPT[pp] if QUICK_PROMPT.get(pp, "") != "" else pp
    with open("io.txt", 'w', encoding="utf8") as f:
        f.write(f"PROMPT: {prom}\n{SEPRATOR}")

def decode_io(data):
    """decode io file"""
    data_parts = data.split(SEPRATOR)
    prompt_part = data_parts[0]
    prompt = prompt_part.split("PROMPT: ")[1].strip()
    ret = []
    for parts in data_parts[1:]:
        if parts.startswith("USER: "):
            cc = parts.split("USER: ")[1].strip()
            ret.append({"role": "user", "content": cc})
        elif parts.startswith("ASSISTANT: "):
            cc = parts.split("ASSISTANT: ")[1].strip()
            ret.append({"role": "assistant", "content": cc})
    return prompt, ret

def list_models(k):
    """list all models"""
    header = {"Authorization": f"Bearer {k['key']}"}
    if 'org' in k:
        header['OpenAI-Origanization'] = k['org']
    r = requests.get(f"{k['endpoint']}/v1/models", headers=header, timeout=10)
    model_list = []
    try:
        aa = json.loads(r.text)
        for model in aa['data']:
            interest_list = ['gpt', 'dall', 'whis', 'tts']
            for it in interest_list:
                if it in model['id']:
                    print(model['id'])
                    model_list.append(model['id'])
    except:
        print("Failed to list models")
        print(r.text)
    return model_list

def gpt_text(k, prompt, msg, model):
    """send request to openai gpt text model"""
    if len(msg) == 0:
        raise RuntimeError("Message cannot be empty array")
    if msg[-1]['role'] != "user":
        raise RuntimeError("Last messgae has to be user")
    if msg[-1]['content'] == "":
        raise RuntimeError("Message cannot be empty")
    header = {"Authorization": f"Bearer {k['key']}"}
    if 'org' in k:
        header['OpenAI-Origanization'] = k['org']
    message_list = []
    if prompt != "":
        message_list.append({"role": "system", "content": prompt})
    for mm in msg:
        message_list.append(mm)
    req_body = {
        "model": model,
        "messages": message_list,
        "stream": True,
    }
    r = requests.post(
        f"{k['endpoint']}/v1/chat/completions",
        headers=header, json=req_body, timeout=600, stream=True,
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
            except Exception as e:
                print("DONE")
    return all_ret + "\n"

def gpt_img(k, prompt, model, quality, size):
    """send request to openai gpt text model"""
    if len(prompt) == 0:
        raise RuntimeError("Prompt cannot be empty")
    header = {"Authorization": f"Bearer {k['key']}"}
    if 'org' in k:
        header['OpenAI-Origanization'] = k['org']
    req_body = {
        "model": model,
        "prompt": prompt,
        "quality": quality,
        "size": size,
        "response_format": "b64_json",
    }
    r = requests.post(
        f"{k['endpoint']}/v1/images/generations",
        headers=header, json=req_body, timeout=600,
    )
    data = r.json()
    image_base64 = data['data'][0]['b64_json']
    image_bytes = binascii.a2b_base64(image_base64)
    with open("result.jpg", 'wb') as f:
        f.write(image_bytes)

if not os.path.exists("key.txt"):
    with open("key.txt", 'w', encoding="utf8") as f:
        f.write(json.dumps([{
                "name": "123", "key": "sk-xxx",
                "org": "org-", "endpoint": "",
        }]))
    print("Please put the key in key.txt")
    sys.exit(2)

load_all_keys()
using_key = key_list[0]

print("Choose key, default [0]:")
for ii in range(0, len(key_list)):
    print(f"[{ii}]: {key_list[ii]['name']}: {key_list[ii]['endpoint']}")

while True:
    a = input("Select: ")
    if len(a) == 0:
        break
    if a not in string.digits:
        print("No such model")
        use_model = models[0]
        continue
    if int(a) < len(key_list):
        using_key = key_list[int(a)]
        break
    print("No such key")
print("Using key: ", using_key['name'])

use_model = models[0]

print("Choose model, default [0]:")
for ii in range(0, len(models)):
    print(f"[{ii}]: {models[ii]}")

while True:
    a = input("Select: ")
    if len(a) == 0:
        use_model = models[0]
        break
    if a == "ll":
        mlist = list_models(using_key)
        for mm in models.copy():
            if mm not in mlist:
                models.remove(mm)
        for mm in mlist:
            if mm not in models:
                models.append(mm)
        print("Choose model, default [0]:")
        for ii in range(0, len(models)):
            print(f"[{ii}]: {models[ii]}")
        continue
    try:
        int(a)
    except:
        print("Please enter digits")
        continue
    if int(a) < len(models):
        use_model = models[int(a)]
        break
    print("No such model")

print("Using model: ", use_model)

if not os.path.exists("io.txt"):
    init_io_file()
print("[Input cc to clear context]")
print("[Input dr to start drawing]")

with open("io.txt", encoding="utf8") as f:
    data = f.read()
prompt, dialogue = decode_io(data)

print("Using prompt: ", prompt)
print("Previous dialogue: ")
for d in dialogue:
    if len(d['content']) > 30:
        print(d['role'].upper() + ": " + d['content'][:30] + "[TRUNCATED]")
    else:
        print(d['role'].upper() + ": " + d['content'])

while True:
    inp = input("USER: ")
    if inp == "cc":
        dialogue.clear()
        init_io_file()
        with open("io.txt", encoding="utf8") as f:
            data = f.read()
        prompt, dialogue = decode_io(data)
        print("Using prompt: ", prompt)
        continue
    if inp == "dr":
        ppp = input("请输入提示词: ")
        qqq = input("请选择清晰度(hd/sd)，默认标准: ")
        if qqq == "":
            qqq = "standard"
        size_list = ['1024x1024', '1792x1024', '1024x1792']
        for ii in range(0, len(size_list)):
            print(f"[{ii}]: {size_list[ii]}")
        sss = input("请选择 size: ")
        if len(sss) == 0:
            sss = size_list[0]
        else:
            sss = size_list[int(sss)]
        gpt_img(using_key, ppp, "dall-e-3", qqq, sss)
        continue
    if len(inp) == 0:
        print("Input cannot be empty.")
        continue
    dialogue.append({"role": "user", "content": inp})
    print("ASSISTANT: ", end="", flush=True)
    reply = gpt_text(using_key, prompt, dialogue, use_model)
    dialogue.append({"role": "assistant", "content": reply.strip()})
    with open("io.txt", 'a+', encoding="utf8") as f:
        f.write("USER: " + inp.strip() + "\n")
        f.write(SEPRATOR)
        f.write("ASSISTANT: " + reply.strip() + "\n")
        f.write(SEPRATOR)
