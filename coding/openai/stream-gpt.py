"""quick talk"""
import string
import sys
import os
import json
import requests

# OPENAI_API_ENDPOINT="https://api.chatanywhere.cn"
# OPENAI_API_ENDPOINT="https://api.chatanywhere.com.cn"
OPENAI_API_ENDPOINT="https://api.openai.com"
SEPRATOR = "<<>>++__--!!@@##--<<>>\n"

print("Using: ", OPENAI_API_ENDPOINT)

QUICK_PROMPT = {
    "ff": "帮我翻译一下我发过来的内容到中文",
}

def load_keys():
    with open("key.txt", 'r', encoding='utf8') as f:
        data = f.read()
    return data.strip()

def init_io_file():
    print("快速 prompt: ")
    for kk in QUICK_PROMPT:
        print(kk + ":", QUICK_PROMPT[kk])
    pp = input("Prompt: ")
    if pp in QUICK_PROMPT:
        prom = QUICK_PROMPT[pp]
    else:
        prom = pp
    with open("io.txt", 'w', encoding="utf8") as f:
        f.write(f"PROMPT: {prom}\n")
        f.write(SEPRATOR)

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
    # print(message_list)
    req_body = {
        "model": model,
        "messages": message_list,
        "stream": True,
    }
    r = requests.post(
        f"{OPENAI_API_ENDPOINT}/v1/chat/completions",
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

if not os.path.exists("key.txt"):
    with open("key.txt", 'w', encoding="utf8") as f:
        f.truncate()
    print("Please put the key in key.txt")
    sys.exit(2)

models = [
    "gpt-3.5-turbo-16k-0613",
    "gpt-4-0613",
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

if not os.path.exists("io.txt"):
    init_io_file()

print("[Input cc to clear context]")

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
    if len(inp) == 0:
        print("Input cannot be empty.")
        continue
    dialogue.append({"role": "user", "content": inp})
    print("ASSISTANT: ", end="", flush=True)
    reply = talk_with_gpt4_streamed(load_keys(), prompt, dialogue, use_model)
    dialogue.append({"role": "assistant", "content": reply.strip()})
    with open("io.txt", 'a+', encoding="utf8") as f:
        f.write("USER: " + inp.strip() + "\n")
        f.write(SEPRATOR)
        f.write("ASSISTANT: " + reply.strip() + "\n")
        f.write(SEPRATOR)
