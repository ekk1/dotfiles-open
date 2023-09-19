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
    req_body = {
        "model": "gpt-4-0613",
        "messages": [
            {"role": "system", "content": prompt},
            {"role": "user", "content": msg},
        ]
    }
    r = requests.post(
            f"{OPENAI_API_ENDPOINT}/v1/chat/completions",
            headers=header,
            json=req_body,
            timeout=30
    )
    aa = json.loads(r.text)
    ret = f"{aa['model']}:\n"
    ret += f" -> {msg}\n"
    ret += f" <- {aa['choices'][0]['message']['content']}\n"
    ret += f" -- {aa['choices'][0]['finish_reason']}\n"
    ret += f"Usage: {aa['usage']['prompt_tokens']} + "
    ret += f"{aa['usage']['completion_tokens']} = "
    ret += f"{aa['usage']['total_tokens']}\n"
    print(ret)

if __name__ == "__main__":
    # list_models()
    cmd_list = [
        "打开房间的空调, 并调整到 26 度",
        "房间空调温度: 26 度, 有点冷, 把空调温度调高一点",
    ]
    for cmd in cmd_list:
        talk_with_gpt4("你是一个智能助手, 你需要分析我的指令, 并返回特定格式的操作指令, 大致格式为: 动作-位置-物体-其他参数, 比如 打开-主卧-窗帘-0.5. 其他参数这里, 如果你觉得可以量化的话, 尽量使用数字来表示. 如果你觉得一条指令无法完成所有任务, 你也可以返回多条指令.", cmd)
