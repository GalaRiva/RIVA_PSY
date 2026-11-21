#!/usr/bin/env python3
"""Adds the Spanish versions of the five «Опора/Меланхолия» audios to Firestore.

Run ONLY after the files are in R2 (bucket riva-psy-audio, folder
audio/es/program_depression/). Without --apply it only checks that each file is
there with the right size. With --apply it PATCHes just name_es, fileName_es and
duration_ms_es of Audio/program_depression__* (the Russian fields stay as they are)
and saves a backup of the documents first.

  python3 write_program_depression_es.py            # check only
  python3 write_program_depression_es.py --apply    # check, then write
"""
import json, os, sys, urllib.parse
import importlib.util

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("w", os.path.join(HERE, "write_program_depression.py"))
w = importlib.util.module_from_spec(spec)
spec.loader.exec_module(w)
MANIFEST = os.path.join(HERE, "program_depression_es_manifest.json")


def main():
    apply = "--apply" in sys.argv
    man = json.load(open(MANIFEST, encoding="utf-8"))
    ok = True
    for m in man:
        size = w.r2_size(m["fileName_es"])
        state = "OK" if size == m["size"] else ("MISSING" if size is None else f"SIZE {size} != {m['size']}")
        print(f"{m['docId']:40s} {state}")
        ok = ok and state == "OK"
    if not ok:
        print("\nNot all files are in R2 with the right size. Nothing written.")
        return 1
    if not apply:
        print("\nAll files are in R2. Run again with --apply to write Firestore.")
        return 0
    tok = w.token()
    backup = {}
    for m in man:
        backup[m["docId"]] = w.fs("GET", "Audio/" + m["docId"], tok=tok)
        fields = {
            "name_es": {"stringValue": m["name_es"]},
            "fileName_es": {"stringValue": m["fileName_es"]},
            "duration_ms_es": {"integerValue": str(m["duration_ms_es"])},
        }
        mask = "&".join("updateMask.fieldPaths=" + k for k in fields)
        w.fs("PATCH", "Audio/" + m["docId"] + "?" + mask, {"fields": fields}, tok=tok)
        print("written", m["docId"])
    json.dump(backup, open(os.path.join(HERE, "program_depression_es_audio_backup.json"), "w"), ensure_ascii=False, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main())
