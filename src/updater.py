import requests
import json
import base64


api_file = "https://api.github.com/repos/ZefirAndph/ESOAESO/contents/src/"
api_info = "https://api.github.com/repos/ZefirAndph/ESOAESO/contents/src"

resp = requests.get(api_info)
y = json.loads(resp.content)
print("\n\nGETTING DATA!\n\n")
for f in y:
	g = requests.get(api_file + f["name"])
	h = json.loads(g.content)
	open(f["name"], "wb").write(base64.b64decode(h["content"]))
	print("Saved: " + f["name"])

print("\nDONE!")

#open("tadada.lua", "wb").write(base64.b64decode(y["content"]))