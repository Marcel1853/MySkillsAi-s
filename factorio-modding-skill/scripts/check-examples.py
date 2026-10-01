#!/usr/bin/env python3
"""Lädt jedes Beispiel aus examples/ headless als eigene Wegwerf-Mod (Datenschritt-Dateien als
data.lua, Laufzeit-Dateien als control.lua, das Lebenszyklus-Beispiel an seinen Abschnitten
zerlegt, basic-mod komplett) und lässt es 300 Ticks laufen. Eine Zeile OK/FEHLER je Beispiel.
Aufruf: FACTORIO=/pfad/zu/factorio scripts/check-examples.py examples
Neue Beispiele unten in die Liste eintragen.
"""
import os, re, shutil, subprocess, sys, tempfile, json
EX = sys.argv[1]
FACTORIO = os.environ.get("FACTORIO", "factorio")
PATTERN = re.compile(r"Error |Error while (loading|running)|Failed to load mod|non-recoverable|Missing required dependency|doesn't contain key|Error ModManager|Unknown")

def mod(name, files, space_age):
    work = tempfile.mkdtemp()
    m = os.path.join(work, "mods", name)
    os.makedirs(m)
    deps = ["base >= 2.1"] + (["space-age"] if space_age else [])
    json.dump({"name": name, "version": "0.0.1", "title": name, "author": "t", "factorio_version": "2.1",
               "dependencies": deps}, open(os.path.join(m, "info.json"), "w"))
    for target, text in files.items():
        os.makedirs(os.path.dirname(os.path.join(m, target)) or m, exist_ok=True)
        open(os.path.join(m, target), "w").write(text)
    return work

def run(work, label):
    cfg = os.path.join(work, "config.ini")
    open(cfg, "w").write(f"[path]\nread-data=__PATH__executable__/../../data\nwrite-data={work}/data\n")
    mods = os.path.join(work, "mods")
    out = subprocess.run([FACTORIO, "-c", cfg, "--mod-directory", mods, "--create", os.path.join(work, "t.zip")],
                         capture_output=True, text=True).stdout
    if os.path.exists(os.path.join(work, "t.zip")):
        out += subprocess.run([FACTORIO, "-c", cfg, "--mod-directory", mods, "--benchmark", os.path.join(work, "t.zip"),
                               "--benchmark-ticks", "300"], capture_output=True, text=True).stdout
    log = open(os.path.join(work, "data", "factorio-current.log")).read() if os.path.exists(os.path.join(work, "data", "factorio-current.log")) else out
    bad = [l for l in (out + log).splitlines() if PATTERN.search(l)]
    ok = os.path.exists(os.path.join(work, "t.zip")) and not bad
    print(("OK    " if ok else "FEHLER") + " " + label)
    if not ok:
        lines = (out + log).splitlines()
        for i, l in enumerate(lines):
            if PATTERN.search(l):
                print("      " + "\n      ".join(lines[i:i + 12])); break
    shutil.rmtree(work, ignore_errors=True)

def read(p): return open(os.path.join(EX, p)).read()

# basic-mod komplett
work = tempfile.mkdtemp(); os.makedirs(os.path.join(work, "mods"))
shutil.copytree(os.path.join(EX, "basic-mod"), os.path.join(work, "mods", "crystal-tech"))
run(work, "basic-mod (crystal-tech)")

# Lebenszyklus-Beispiel zerlegen
text = read("data-lifecycle/basic-mod-example.lua")
parts = re.split(r"-- =+\n-- (\S+)[^\n]*\n-- =+\n", text)
files = {}
for i in range(1, len(parts), 2):
    name, body = parts[i], parts[i + 1]
    if name.endswith(".lua"): files[name] = files.get(name, "") + body
run(mod("skex-lifecycle", files, False), "data-lifecycle/basic-mod-example.lua → " + ", ".join(files))

for p, stage, sa in [
    ("prototype-stage/custom-entity-chain.lua", "data.lua", False),
    ("space-age/custom-planet-example.lua", "data.lua", True),
    ("space-age/quality-and-asteroids.lua", "data.lua", True),
    ("circuits/circuit-control-example.lua", "control.lua", False),
    ("gui/custom-gui-example.lua", "control.lua", False),
    ("trains/train-dispatcher.lua", "control.lua", False),
    ("runtime-stage/event-tracking-mod.lua", "control.lua", False),
    ("space-age/space-platform-runtime.lua", "control.lua", True),
    ("space-age/quality-runtime-handling.lua", "control.lua", True),
    ("space-age/space-platform-monitor/control.lua", "control.lua", True),
    ("space-age/quality-display/control.lua", "control.lua", True),
    ("space-age/asteroid-defense/control.lua", "control.lua", True),
]:
    run(mod("skex-" + re.sub(r"[^a-z]", "-", p.lower())[:40], {stage: read(p)}, sa), p)
