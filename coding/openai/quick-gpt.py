"""quick talk"""
import sys
import os
import commons

ii = sys.argv[1]

data = ""
if os.path.exists(ii):
    print("Using file")
    with open(ii, encoding='utf8') as f:
        data = f.read()
else:
    print("Using input")
    data = ii

commons.talk_with_gpt4("", data)
