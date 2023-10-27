"""quick talk"""
import commons
import string
import sys
import os

if not os.path.exists("key.txt"):
    with open("key.txt", 'w', encoding="utf8") as f:
        f.truncate()

print("Using: ", commons.OPENAI_API_ENDPOINT)

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
    commons.init_io_file()

print("[Input cc to clear context]")

with open("io.txt", encoding="utf8") as f:
    data = f.read()
prompt, dialogue = commons.decode_io(data)
print("Using prompt: ", prompt)
print("Previous dialogue: ")
for d in dialogue:
    if len(d['content']) > 30:
        print(d['role'].upper() + ": " + d['content'][:30])
    else:
        print(d['role'].upper() + ": " + d['content'])

while True:
    inp = input("USER: ")
    if inp == "cc":
        dialogue.clear()
        commons.init_io_file()
        with open("io.txt", encoding="utf8") as f:
            data = f.read()
        prompt, dialogue = commons.decode_io(data)
        print("Using prompt: ", prompt)
        continue
    if len(inp) == 0:
        print("Input cannot be empty.")
        continue
    dialogue.append({"role": "user", "content": inp})
    print("ASSISTANT: ", end="", flush=True)
    reply = commons.talk_with_gpt4_streamed(commons.load_keys(), prompt, dialogue, use_model)
    dialogue.append({"role": "assistant", "content": reply})
    with open("io.txt", 'a+', encoding="utf8") as f:
        f.write("USER: " + inp)
        if len(inp) > 0 and inp[-1] != "\n":
            f.write("\n")
        f.write(commons.SEPRATOR)
        f.write("ASSISTANT: " + reply)
        if len(reply) > 0 and reply[-1] != "\n":
            f.write("\n")
        elif len(reply) == 0:
            f.write("\n")
        f.write(commons.SEPRATOR)
