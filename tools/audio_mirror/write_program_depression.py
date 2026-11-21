#!/usr/bin/env python3
"""Writes the five new «Опора» audio docs to Firestore (Audio/program_depression__*).

Run ONLY after the files are uploaded to R2 (bucket riva-psy-audio, folder
audio/program_depression/). Without --apply it only checks: for each file it asks
the public R2 domain for the object and compares its size with the manifest.
With --apply (and only if every file is present with the right size) it writes the
docs and saves a backup of what it replaced.

  python3 write_program_depression.py            # check only
  python3 write_program_depression.py --apply    # check, then write
"""
import json, os, sys, time, urllib.request, urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
MANIFEST = os.path.join(HERE, "program_depression_manifest.json")
R2 = "https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/"
PROJECT = "rigel-psy-9361c"


def r2_size(file_name):
    req = urllib.request.Request(R2 + file_name + ".mp3", method="HEAD", headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return int(r.headers.get("Content-Length", "0"))
    except Exception as e:
        return None


def token():
    cfg = json.load(open(os.path.expanduser("~/.config/configstore/firebase-tools.json")))["tokens"]
    if cfg.get("expires_at", 0) / 1000 > time.time() + 60:
        return cfg["access_token"]
    data = urllib.parse.urlencode({
        "grant_type": "refresh_token", "refresh_token": cfg["refresh_token"],
        "client_id": "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com",
        "client_secret": "j9iVZfS8kkCEFUPaAeJV0sAi"}).encode()
    return json.load(urllib.request.urlopen(urllib.request.Request("https://www.googleapis.com/oauth2/v3/token", data=data)))["access_token"]


def fs(method, path, body=None, tok=None):
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents/{path}"
    req = urllib.request.Request(url, method=method, data=json.dumps(body).encode() if body else None,
                                 headers={"Authorization": "Bearer " + tok, "Content-Type": "application/json"})
    try:
        return json.load(urllib.request.urlopen(req))
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def main():
    apply = "--apply" in sys.argv
    man = json.load(open(MANIFEST, encoding="utf-8"))
    ok = True
    for m in man:
        size = r2_size(m["fileName"])
        state = "OK" if size == m["size"] else ("MISSING" if size is None else f"SIZE {size} != {m['size']}")
        print(f"{m['docId']:40s} {state}")
        ok = ok and state == "OK"
    if not ok:
        print("\nNot all files are in R2 with the right size. Nothing written.")
        return 1
    if not apply:
        print("\nAll files are in R2. Run again with --apply to write Firestore.")
        return 0
    tok = token()
    backup = {}
    for m in man:
        backup[m["docId"]] = fs("GET", "Audio/" + m["docId"], tok=tok)
        fields = {
            "name": {"stringValue": m["name"]},
            "fileName": {"stringValue": m["fileName"]},
            "format": {"stringValue": "mp3"},
            "folder": {"stringValue": "audio"},
            "tab": {"stringValue": "program_depression"},
            "emotions": {"stringValue": ""},
            "duration_ms": {"integerValue": str(m["duration_ms"])},
        }
        fs("PATCH", "Audio/" + m["docId"], {"fields": fields}, tok=tok)
        print("written", m["docId"])
    json.dump(backup, open(os.path.join(HERE, "program_depression_audio_backup.json"), "w"), ensure_ascii=False, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main())
