#!/usr/bin/env python3
import urllib.request
from bs4 import BeautifulSoup
import json
import sys

def get_list(url):
    try:
        response = urllib.request.urlopen(url)
        html = response.read().decode('utf-8')
        return html
    except urllib.error.HTTPError as e:
        print('HTTPError: ', e)

def get_jsonp(id):
    try:
        url = "http://www.onsen.ag/data/api/getMovieInfo/"+id
        response = urllib.request.urlopen(url)
        jsonp = response.read().decode('utf-8')
        return jsonp
    except urllib.error.HTTPError as e:
        print('HTTPError: ', e)

def convert_json(jsonp):
    try:
        json_data = jsonp.replace("callback(","").replace(");","")
        return json.loads(json_data)
    except json.JSONDecodeError as e:
        print('JSONDecodeError: ', e)

def get_description(id):
    try:
        url = "http://www.onsen.ag/program/"+id+"/"
        response = urllib.request.urlopen(url)
        html = response.read().decode('utf-8')
        soup = BeautifulSoup(html, "lxml")
        section = soup.find("section",attrs={"class":"programCont","id":"introductionWrap"})
        section.div.replace_with("")
        section.img.replace_with("")
        section.a.replace_with("")
        description = section.text.strip()
        return description
    except urllib.error.HTTPError as e:
        print('HTTPError: ', e)
    except AttributeError as e:
        sys.stderr.write("AttributeError => "+id+"\n")
        return ""

if __name__ == '__main__':
    list = {}
    dow = ["mon","tue","wed","thu","fri","sat"]
    for day in dow:
        list.setdefault(day,[])

    html = get_list("http://www.onsen.ag")
    soup = BeautifulSoup(html, "lxml")
    li = soup.select(".listWrap .clr li")
    for prog in li:
        day = prog.get("data-week")
        id = prog.get("id")
        jsonp = get_jsonp(id)
        info = convert_json(jsonp)
        data = {
            "name" : info["title"],
            "cast" : info["personality"],
            "id" : id, 
            "description" : get_description(id),
            "image" : "http://www.onsen.ag"+info["thumbnailPath"],
            "count" : info["count"],
            "video_url" : info["moviePath"]["pc"]
        }
        list[day].append(data)

    print(json.dumps(list,ensure_ascii=False))
