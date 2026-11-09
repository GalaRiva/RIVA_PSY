#!/usr/bin/env python3
"""Mirror R2 audio into the Firebase Storage fallback bucket.

Workflow: new audio is uploaded to R2 by hand (Cloudflare dashboard) and its
Firestore `Audio` / `GuidedJournals` docs are written; then run this script.
It uploads every audio path that exists on R2 but is missing (or has a
different size) in the bucket. Safe to re-run; it never deletes anything.

    python3 -I tools/audio_mirror/mirror_audio.py            # sync
    python3 -I tools/audio_mirror/mirror_audio.py --dry-run  # only report

Needs: `curl`, and the Firebase CLI logged in as the project owner
(its OAuth token in ~/.config/configstore/firebase-tools.json is used).
See docs/audio-fallback.md.
"""
import json, os, subprocess, sys, tempfile, time, urllib.error, urllib.parse, urllib.request
from concurrent.futures import ThreadPoolExecutor

PROJECT = 'rigel-psy-9361c'
BUCKET = 'rigel-psy-9361c.firebasestorage.app'
R2_HOST = 'pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev'
# Cloudflare IPs that were reachable while the usual two (104.18.50.34 /
# 104.18.54.45) were blocked in Spain; only used if the normal route fails.
R2_ALT_IPS = ['8.47.69.0', '8.6.112.0']
DRY = '--dry-run' in sys.argv


def token():
    cfg = json.load(open(os.path.expanduser('~/.config/configstore/firebase-tools.json')))
    t = cfg['tokens']
    if t.get('expires_at', 0) / 1000 > time.time() + 120:
        return t['access_token']
    body = urllib.parse.urlencode({
        'grant_type': 'refresh_token', 'refresh_token': t['refresh_token'],
        'client_id': '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com',
        'client_secret': 'j9iVZfS8kkCEFUPaAeJV0sAi'}).encode()
    return json.load(urllib.request.urlopen(
        urllib.request.Request('https://www.googleapis.com/oauth2/v3/token', body)))['access_token']


TOK = token()


def jget(url):
    req = urllib.request.Request(url, headers={'Authorization': 'Bearer ' + TOK})
    return json.load(urllib.request.urlopen(req, timeout=60))


def firestore_docs(coll):
    out, pt = [], ''
    while True:
        j = jget(f'https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents/{coll}?pageSize=300{pt}')
        out += j.get('documents', [])
        if 'nextPageToken' not in j:
            return out
        pt = '&pageToken=' + j['nextPageToken']


def wanted_paths():
    paths = set()
    for d in firestore_docs('Audio'):
        f = {k: list(v.values())[0] for k, v in d['fields'].items()}
        for k in ('fileName', 'fileName_en', 'fileName_es'):
            if f.get(k):
                paths.add(f[k] + '.' + f.get('format', 'mp3'))
    # Guided Journals link single tracks by path (no extension); a value
    # without "/" is a group ("tab") name, not a file.
    for d in firestore_docs('GuidedJournals'):
        for k, v in d['fields'].items():
            s = v.get('stringValue', '')
            if 'audio' in k.lower() and k != 'linked_audio_tab' and '/' in s:
                paths.add(s if s.endswith('.mp3') else s + '.mp3')
    return paths


def bucket_sizes():
    have, pt = {}, ''
    while True:
        j = jget(f'https://storage.googleapis.com/storage/v1/b/{BUCKET}/o?prefix=audio/&maxResults=1000{pt}')
        for o in j.get('items', []):
            have[o['name']] = int(o['size'])
        if 'nextPageToken' not in j:
            return have
        pt = '&pageToken=' + j['nextPageToken']


def r2_url(p):
    return 'https://' + R2_HOST + '/audio/' + urllib.parse.quote(p)


def curl_r2(extra, p):
    """Run curl against R2 trying the normal route, then the alternate IPs."""
    routes = [[]] + [['--resolve', f'{R2_HOST}:443:{ip}'] for ip in R2_ALT_IPS]
    last = ''
    for r in routes:
        res = subprocess.run(['curl', '-s', '-m', '180'] + r + extra + [r2_url(p)], capture_output=True, text=True)
        last = res.stdout
        if extra[:1] == ['-I'] and last.startswith('HTTP') and ' 200' in last.splitlines()[0]:
            return last
        if extra[:1] != ['-I'] and last.strip() == '200':
            return last
    return None


def r2_size(p):
    out = curl_r2(['-I'], p)
    if not out:
        return None
    for line in out.splitlines():
        if line.lower().startswith('content-length'):
            return int(line.split(':')[1])
    return None


def sync_one(args):
    p, have, tmp = args
    key = 'audio/' + p
    n = r2_size(p)
    if n is None:
        return p, 'not-on-r2'
    if have.get(key) == n:
        return p, 'present'
    if DRY:
        return p, 'would-upload'
    local = os.path.join(tmp, p.replace('/', '__'))
    if curl_r2(['-o', local, '-w', '%{http_code}'], p) is None or os.path.getsize(local) != n:
        return p, 'download-failed'
    up = 'https://storage.googleapis.com/upload/storage/v1/b/%s/o?uploadType=media&name=%s' % (
        BUCKET, urllib.parse.quote(key, safe=''))
    code = subprocess.run(['curl', '-s', '-m', '300', '-o', '/dev/null', '-w', '%{http_code}', '-X', 'POST',
                           '-H', 'Authorization: Bearer ' + TOK, '-H', 'Content-Type: audio/mpeg',
                           '--data-binary', '@' + local, up], capture_output=True, text=True).stdout
    os.remove(local)
    return p, 'uploaded' if code == '200' else 'upload-failed:' + code


def main():
    paths = sorted(wanted_paths())
    have = bucket_sizes()
    with tempfile.TemporaryDirectory() as tmp:
        res = list(ThreadPoolExecutor(6).map(sync_one, [(p, have, tmp) for p in paths]))
    from collections import Counter
    print(dict(Counter(r[1].split(':')[0] for r in res)))
    for p, s in res:
        if s not in ('present', 'uploaded'):
            print(' ', s, p)


if __name__ == '__main__':
    main()
