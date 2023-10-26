"""quick talk"""
import sys
import commons
import os

ii = sys.argv[1]

data = ""
if os.path.exists(ii):
    print("Using file")
    f = open(ii)
    data = f.read()
    f.close()
else:
    print("Using input")
    data = ii

commons.talk_with_gpt4_streamed("", data)
