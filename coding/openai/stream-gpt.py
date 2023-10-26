"""quick talk"""
import commons


with open("io.txt", encoding="utf8") as f:
    data = f.read()

prompt, dialogue = commons.decode_io(data)

reply = commons.talk_with_gpt4_streamed(commons.load_keys(), prompt, dialogue)
with open("io.txt", 'a+', encoding="utf8") as f:
    f.write("ASSISTANT: " + reply)
    if len(reply) > 0 and reply[-1] != "\n":
        f.write("\n")
    elif len(reply) == 0:
        f.write("\n")
    f.write(commons.SEPRATOR)
    f.write("USER: \n")
    f.write(commons.SEPRATOR)
