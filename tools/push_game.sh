#!/bin/bash
# push /home/user/game/index.html to GitHub via Contents API
TOKEN=$(cat /home/user/.secrets/github_token)
REPO=cepas1024-hub/cepas-the-seven-lands-of-beginning
SHA=$(curl -s "https://api.github.com/repos/$REPO/commits/main" -H "Authorization: token $TOKEN" | python3 -c "
import sys,json
t=json.load(sys.stdin)['commit']['tree']['sha']
print(t)")
FILESHA=$(curl -s "https://api.github.com/repos/$REPO/git/trees/$SHA" -H "Authorization: token $TOKEN" | python3 -c "
import sys,json
for e in json.load(sys.stdin)['tree']:
    if e['path']=='index.html': print(e['sha']); break")
python3 - "$FILESHA" <<'PY'
import base64,sys,json,urllib.request
sha=sys.argv[1]
data=base64.b64encode(open('/home/user/game/index.html','rb').read()).decode()
body={"message":"update game","content":data}
if sha: body["sha"]=sha
req=urllib.request.Request("https://api.github.com/repos/cepas1024-hub/cepas-the-seven-lands-of-beginning/contents/index.html",
  data=json.dumps(body).encode(), method="PUT",
  headers={"Authorization":"token "+open('/home/user/.secrets/github_token').read().strip(),
           "Accept":"application/vnd.github+json","Content-Type":"application/json"})
print(json.load(urllib.request.urlopen(req))['commit']['html_url'])
PY
