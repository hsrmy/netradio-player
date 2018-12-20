#!/usr/bin/env python3
import urllib.request
import json

# ヘッダーのセット
def set_header(url):
    headers={
        "X-Requested-With":"XMLHttpRequest",
        "Origin":"http://hibiki-radio.jp"
    }
    return urllib.request.Request(url, None, headers)

def get_list_json(url):
    try:
        request = set_header(url)
        response = urllib.request.urlopen(request)
        html = response.read().decode('utf-8')
        json_data = json.loads(html)
        return json_data
    except urllib.error.HTTPError as e:
        print('HTTPError: ', e)
    except json.JSONDecodeError as e:
        print('JSONDecodeError: ', e)

def get_prog_json(id):
    try:
        url = "https://vcms-api.hibiki-radio.jp/api/v1/programs/"+id
        request = set_header(url)
        response = urllib.request.urlopen(request)
        html = response.read().decode('utf-8')
        json_data = json.loads(html)
        return json_data
    except urllib.error.HTTPError as e:
        print('HTTPError: ', e)
    except json.JSONDecodeError as e:
        print('JSONDecodeError: ', e)

if __name__ == '__main__':
    url = "https://vcms-api.hibiki-radio.jp/api/v1/programs"
    prog_list = get_list_json(url)

    list = {}
    dow = ["sun","mon","tue","wed","thu","fri","sat"]
    for i in range(1,7):
        list.setdefault(dow[i],[])

    for prog in prog_list:
        if prog["latest_episode_id"] != None:
            info = get_prog_json(prog["access_id"])
            if info["episode"]["video"] != None:
                data = {
                    "name" : prog["name"],
                    "cast" : info["cast"],
                    "id" : prog["access_id"],
                    "description" : info["description"],
                    "image": prog["sp_image_url"],
                    "video_id" : str(info["episode"]["video"]["id"])
                }
                list[dow[prog["day_of_week"]]].append(data)

    print(json.dumps(list,ensure_ascii=False))
