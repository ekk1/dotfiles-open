import os

if not os.path.exists("key.txt"):
    with open("key.txt", 'w', encoding="utf8") as f:
        f.truncate()

import commons

with open("io.txt", 'w', encoding="utf8") as f:
    f.write("PROMPT: \n")
    f.write(commons.SEPRATOR)
    f.write("USER: \n")
    f.write(commons.SEPRATOR)
