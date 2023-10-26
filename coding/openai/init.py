import os

if not os.path.exists("key.txt"):
    with open("key.txt", 'w', encoding="utf8") as f:
        f.truncate()

import commons

if os.path.exists("io.txt"):
    with open("io.txt", 'r', encoding='utf8') as f:
        dd = f.read()
    prompt = commons.decode_io(dd)

with open("io.txt", 'w', encoding="utf8") as f:
    f.write(f"PROMPT: {prompt[0]}\n")
    f.write(commons.SEPRATOR)
    f.write("USER: \n")
    f.write(commons.SEPRATOR)
