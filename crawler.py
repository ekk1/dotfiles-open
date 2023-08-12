# This is a script to download from seedhost box
# apt install python3-requests
# apt install python3-socks
# apt install python3-redis
# apt install redis-server

import requests
import argparse
import urllib.parse
import pprint
import redis

parser = argparse.ArgumentParser()

parser.add_argument("-u", "--url", required=True)
parser.add_argument("-d", "--depth", default=0, type=int)
parser.add_argument("-s", "--secret")

args = parser.parse_args()

r = redis.Redis()

START_URL = args.url
MAX_CRAW_DEPTH = args.depth
PASSWORD_FILE = args.secret

PENGDING_LIST   = []

USERNAME = ""
PASSWORD = ""

CURRENT_PATH = ""

RESOURCE_PACK = dict()

if PASSWORD_FILE is not None:
    f = open(PASSWORD_FILE)
    a = f.read()
    f.close()
    content = a.split("\n")
    USERNAME, PASSWORD = content[0], content[1]

def craw_page(s: requests.Session, _url: str):
    print("Fetching: ", _url)
    p = s.get(_url)
    page_content = p.text
    decode_page(_url, page_content)
    r.set(_url, page_content)

def decode_page(_url, page_content):
    resource_count = 0
    dir_count = 0
    for _line in page_content.split("\n"):
        # print(_line)
        if "<h1>" in _line:
            CURRENT_PATH = _line.split("Index of")[1].split("</h1>")[0].strip()
            print("Current decoding: ", CURRENT_PATH)
        if "[DIR]" in _line:
            target_link = _line.split("href")[1].split(">")[0].split('"')[1]
            if target_link not in ["filezilla/", "rtorrent/", "watch/"]:
                # print("Found next dir: ", target_link)
                dir_count += 1
                PENGDING_LIST.append(_url + target_link)
        if "VID" in _line:
            target_link = _line.split("href")[1].split(">")[0].split('"')[1]
            # print("Found resource: ", target_link, urllib.parse.unquote(target_link))
            resource_count += 1
            if CURRENT_PATH not in RESOURCE_PACK:
                RESOURCE_PACK[CURRENT_PATH] = dict()
            RESOURCE_PACK[CURRENT_PATH][urllib.parse.unquote(target_link)] = _url + target_link
    print(f"Found {dir_count} dirs in this page")
    print(f"Found {resource_count} resources in this page")

s = requests.session()
s.proxies = {
    "https": "socks5h://127.0.0.1:10099",
    "https": "socks5h://127.0.0.1:10099"
}
if USERNAME != "":
    s.auth = (USERNAME, PASSWORD)

# craw_page(s, START_URL)

PENGDING_LIST.append(START_URL)
CURRENT_DEPTH = 0
PENGDING_LIST_CURSOR = 0

while len(PENGDING_LIST) != PENGDING_LIST_CURSOR:
    if CURRENT_DEPTH >= MAX_CRAW_DEPTH and MAX_CRAW_DEPTH != 0:
        break
    current_target = PENGDING_LIST[PENGDING_LIST_CURSOR]
    if r.exists(current_target):
        print("Cache hit for: ", current_target)
        decode_page(current_target, r.get(current_target).decode())
    else:
        craw_page(s, PENGDING_LIST[PENGDING_LIST_CURSOR])
    PENGDING_LIST_CURSOR += 1
    CURRENT_DEPTH += 1

# pprint.pprint(RESOURCE_PACK) 
# TODO: download file directly in python, curl sometimes fails to download
for DIRR in RESOURCE_PACK:
    print(f"{DIRR}: {len(RESOURCE_PACK[DIRR])}")
    with open(f"downloader/download-{DIRR.replace('/', '-')}.sh", 'w+') as f:
        for file in RESOURCE_PACK[DIRR]:
            f.write(f'mkdir -p "..{DIRR}"\n')
            f.write(f'while true; do curl --limit-rate 4M --speed-limit 5000 --speed-time 30 -JL -C - -x socks5h://127.0.0.1:10099 --netrc-file ../netrc "{RESOURCE_PACK[DIRR][file]}" -o "..{DIRR}/{file}" ; if [[ $? != 18 ]]; then sleep 5; break; fi ; done\n')
