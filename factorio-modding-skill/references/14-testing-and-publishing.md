# Testen, Packen und Veröffentlichen (Factorio 2.1)

> Erfahrungen aus einem echten Mod-Projekt (Zug-Dispatcher, Sept. 2026, Factorio 2.1.19).
> Regeln zu info.json/Changelog geprüft gegen
> [mod-structure](https://lua-api.factorio.com/latest/auxiliary/mod-structure.html) und
> [changelog-format](https://lua-api.factorio.com/latest/auxiliary/changelog-format.html).
> Die Scripts dazu liegen in `scripts/` (siehe Tabelle am Ende).

## 1. Headless testen (ohne Grafik, läuft auch bei offenem Spiel)

Factorio lässt sich mit **eigenem Datenordner** starten. So bleiben Einstellungen, Spielstände
und `mod-list.json` des Spielers unberührt, und ein offenes Spiel stört nicht.

```bash
WORK=$(mktemp -d); mkdir -p "$WORK/mods" "$WORK/data"
ln -s "$MOD_DIR" "$WORK/mods/$(basename "$MOD_DIR")"      # Mod als Ordner verlinken
ln -s ~/.factorio/mods/flib_*.zip "$WORK/mods/"           # Abhängigkeiten verlinken
cp -r my-selftest_0.0.1 "$WORK/mods/"                     # Testmod (hängt vom Mod ab)
printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s/data\n' "$WORK" > "$WORK/config.ini"
factorio -c "$WORK/config.ini" --mod-directory "$WORK/mods" --create "$WORK/t.zip"
factorio -c "$WORK/config.ini" --mod-directory "$WORK/mods" --benchmark "$WORK/t.zip" --benchmark-ticks 3600
grep -o "\[SELFTEST\].*" "$WORK/data/factorio-current.log"
```

- Der **Testmod** baut in `on_nth_tick` eine Testwelt (Gleise, Haltestellen, Züge), ruft den Mod
  über `remote.call` auf und schreibt Ergebnisse per `log("[SELFTEST] PASS …")`.
- `--benchmark` läuft so schnell wie möglich; 72 000 Ticks (20 Spielminuten) dauern Sekunden.
- Laden/Entladen im Test per Script (`wagon.insert`, `insert_fluid`, `clear_fluid_inside`),
  dann wird der Zug-Ablauf deterministisch.
- **Achtung Testgeometrie:** Auf einer geraden Strecke ohne Schleife müssen die Ziele in
  Fahrtrichtung liegen (oder der Zug hat Loks an beiden Enden).
- Vorlage: `scripts/headless-test.sh` + `scripts/templates/selftest-mod/`.

### Messen (UPS)

```bash
factorio ... --benchmark save.zip --benchmark-ticks 36000 --benchmark-verbose all
```

- `--benchmark-verbose` akzeptiert **nur `all`** – einzelne Spaltennamen führen zum Absturz.
- Ausgabe in `factorio-current.log` als CSV, Zeiten in **Nanosekunden**; nützliche Spalten:
  `wholeUpdate`, `scriptUpdate` (alle Mods), `trains`, `trainPathFinder`.
- Headless heißt: **keine FPS**. Und eine sonst leere Testkarte zeigt nur, was der Mod selbst
  kostet – in der README dazuschreiben, dass eine echte Fabrik zusätzlich UPS/FPS kostet.
- Pro-Funktion messen: `helpers.create_profiler()` um eine Aufgabe legen und bei Bedarf loggen.

## 2. Lint wie in VS Code (FMTK + sumneko)

Die VS-Code-Erweiterung *Factorio Modding Tool Kit* erzeugt die API-Typen unter
`~/.config/Code/User/workspaceStorage/<id>/justarandomgeek.factoriomod-debug/sumneko-3rd/factorio/library`.
Mit diesen Typen findet `lua-language-server --check` dieselben Warnungen wie der Editor
(`scripts/lint.sh`). Achtung: Pfade mit `--` bricht lua-language-server ab (hält es für eine Option) – `lint.sh` kopiert solche Ziele vorher um. Häufige Warnungen und ihre Lösung:

| Warnung | Ursache | Lösung |
|---|---|---|
| `need-check-nil` | Feld eines möglicherweise `nil`-Werts | eigene `if x then … end`-Prüfung (Kurzform `x and x.y` erkennt der Linter nicht immer) |
| `undefined-field nauvis` | `game.surfaces.nauvis` | `game.surfaces["nauvis"]`, ebenso `game.forces["player"]` |
| `undefined-field` auf `remote.call`-Ergebnis | Rückgabe ist untypisiert | Hilfsfunktion mit `---@return MeinTyp?` oder `--[[@as MeinTyp?]]` |
| `undefined-field` auf „nil“-Variable | `local x = nil` und später Tabelle | `local x ---@type Typ?` |

## 3. Packen

- Zip-Name und **Ordner in der Zip**: `<name>_<version>` (z. B. `MyMod_1.2.0/info.json`).
- Nicht mitpacken: `docs/`, `tools/`, `.github/`, `.vscode/`, `.git*`, `CLAUDE.md`, `dist/`,
  Skill-Kopien. Vorlage: `scripts/package.sh` (rsync mit Ausschlüssen, Größenwarnung).
- Portal-Grenze pro Datei beachten (Stand 2026: 262,1 MB); Code ist klein, Größe kommt von
  Grafiken. Wird es zu groß: Grafiken in einen eigenen Mod auslagern, Logik in einem Mod lassen.
- Die Zip **nicht** zusätzlich in `~/.factorio/mods/` legen, solange dort der Ordner derselben
  Mod liegt (doppelte Mod).

## 4. info.json, Name, Changelog, Thumbnail

- **Name:** Das Portal verlangt **mehr als 3 und weniger als 50 Zeichen**, nur Buchstaben,
  Ziffern, `-` und `_`. Der interne Name **lässt sich nach dem ersten Upload nicht ändern**
  (Titel und Beschreibung schon). Vorher prüfen, ob frei:
  `curl -s -o /dev/null -w "%{http_code}" https://mods.factorio.com/api/mods/<name>` → 404 = frei.
- **Umbenennen vor der Veröffentlichung:** `info.json`, Ordnername, alle `__alter-name__/`-Pfade
  (auch in Szenarien, Tipps-Simulationen `mods = {…}`, Testmods), Abhängigkeiten der Testmods,
  Eintrag in `mod-list.json`. Spielstände mit dem alten Namen verlieren die Mod-Entities.
- **description** in info.json erscheint in der Mod-Liste im Spiel → Englisch.
- **Changelog:** Format streng (Trennlinie aus 99 `-`, `Version:`, `Date:`, Kategorie mit zwei
  Leerzeichen, Einträge mit vier Leerzeichen + `- `). Nur die **erkannten Kategorien** nutzen,
  sonst warnt der Linter „Non-standard category name“: Major Features, Features, Minor Features,
  Graphics, Sounds, Optimizations, Balancing, Combat Balancing, Circuit Network, Changes, Bugfixes,
  Modding, Scripting, Gui, Control, Translation, Debug, Ease of use, Info, Locale, Compatibility.
  Changelog **englisch**; für die erste Veröffentlichung reicht „Initial release“ + Features.
- **thumbnail.png:** ideal 144 × 144 px im Mod-Ordner; ohne Namen im Bild, falls der Name
  sich noch ändert.
- **Migrationen:** Solange nichts veröffentlicht ist, wird beim Entwickeln oft `storage` umgebaut
  ohne Versionswechsel – dafür entstandene Migrationen können vor dem ersten Release weg.
  Sicherheitsnetz: in `on_configuration_changed` fehlende Felder mit Standardwerten ergänzen.

## 5. Mod-Portal

| Feld | Empfehlung |
|---|---|
| Kategorie | `Content`, wenn eigene Entities/Items dabei sind; `Utilities` für reine Oberfläche/Werkzeuge; `Overhaul` nur für Gesamtumbauten |
| Tags | nur passende; Achtung: **Transportation** = Transport *des Spielers* (Fahrzeuge, Teleporter), **Logistics** = Güter (Bänder, Greifarme, Rohre), **Trains** für Züge |
| Lizenz | MIT (offen, verbreitet) oder restriktiver; Entscheidung des Autors |
| Summary | kurz, englisch (wird oft aus info.json `description` vorbefüllt) |
| Description | Markdown; README (englisch zuerst) passt |
| Source URL | GitHub-Repo |

API zum Nachsehen (öffentlich, ohne Login):
- `https://mods.factorio.com/api/mods/<name>` – Kurzinfo inkl. `releases[].version`
- `https://mods.factorio.com/api/mods/<name>/full` – mit Beschreibung, Tags, Lizenz, Bildern

**Download** von Mods (z. B. um den Code einer Vorlage-Mod zu lesen):
`https://mods.factorio.com/download/<name>/<id>?username=…&token=…` – Zugangsdaten stehen in
`~/.factorio/player-data.json` (`service-username`, `service-token`); **nie ausgeben oder loggen**.
Die Antwort ist eine Weiterleitung auf `dl-mod.factorio.com` → mit `curl -L` laden.
Heruntergeladene Mods in `mod-list.json` deaktiviert eintragen, wenn sie nur gelesen werden.

**Upload per API** (`scripts/release.yml`):
- `POST https://mods.factorio.com/api/v2/mods/releases/init_upload` mit
  `Authorization: Bearer <API-Key>` und `mod=<name>` → `upload_url`; dann Datei als `file=@…zip`
  an `upload_url` senden.
- `init_upload` geht **nur für Mods, die es schon gibt** – die **erste Version von Hand**
  im Portal hochladen.
- API-Key auf factorio.com mit Recht „ModPortal: Upload Mods“, im Repo als Secret ablegen.

## 6. GitHub Actions (Vorlage `scripts/release.yml`)

- Bei jedem Push auf `main`: Version aus info.json lesen; auf dem Portal prüfen, ob es sie gibt;
  nur dann bauen und hochladen. **Fehler vermeiden:** `exit 0` in einem Schritt beendet nur diesen
  Schritt – die folgenden laufen weiter. Stattdessen Ausgaben setzen und jeden folgenden Schritt
  mit `if:` bedingen.
- `permissions: contents: write`, sonst kann der Workflow keine Tags/Releases/Branches pushen.
- Zusätzlich GitHub-Release: `gh release create vX.Y.Z dist/…zip --notes-file notes.md`
  (Text = Abschnitt der Version aus changelog.txt, per `awk` herausgeschnitten), getrennt
  geprüft mit `gh release view`, damit auch schon hochgeladene Versionen ein Release bekommen.
- Emojis in Workflow-Meldungen können beim Kopieren falsch kodiert werden → Klartext.
- `.gitignore`: `docs/`, `dist/`, `CLAUDE.md`, Skill-Kopien. Bereits eingecheckte Dateien
  zusätzlich mit `git rm --cached <datei>` austragen (bleiben in der Git-Historie).

## 7. Screenshots für die Mod-Seite (mit Grafik)

Headless rendert nichts. Mit Grafik: `factorio -c <eigene config.ini> --mod-directory <ordner>
--load-scenario <mod>/<szenario> --window-size 1920x1080 --disable-audio` und ein kleiner
Hilfsmod (`scripts/templates/screenshot-mod/`), der nach einer Laufzeit
`game.take_screenshot{player=…, by_player=…, surface=…, position=…, zoom=…, resolution={1920,1080},
show_gui=…, show_entity_info=true, daytime=0, path="shots/01-name.jpg"}` aufruft.

**Lehren (teuer gelernt):**
- `take_screenshot` wird **erst beim Rendern** ausgeführt. Ein Fenster, das im selben Tick
  geschlossen wird, fehlt auf dem Bild → Schließen in einen späteren Schritt legen.
- Bilder landen in `<write-data>/script-output/`. **Nie** diesen Ordner vor einem neuen Lauf
  löschen; **jedes fertige Bild sofort** an den Zielort kopieren. Erst kopieren, wenn die Datei
  vollständig ist (z. B. nach `done.txt` oder mit PIL-`load()` prüfen) – halb geschriebene JPGs
  sind kaputt.
- Das Steam-Factorio startet sich über **Steam neu** (`steam://run/427520`). Beenden **nur**
  die eigenen Prozesse: `pgrep -x factorio`, dann über `/proc/<pid>/cmdline` auf den eigenen
  `config.ini`-Pfad prüfen, mit `SIGTERM` beenden. **Kein** `pkill -f`/`kill -9` mit Muster –
  das trifft die eigene Shell, andere Programme (Editor, Steam) oder bringt sie zum Absturz.
  Besser: dem Nutzer sagen, dass er das Fenster am Ende selbst schließt.
- Entity-Fenster über die **Spielfigur** öffnen (teleportieren, `player.opened = entity`),
  nicht aus der Fernsicht – sonst sind Karten-Leisten mit im Bild.
- Fenster bei 1920 × 1080 aufnehmen und danach zuschneiden; kleinere Auflösungen schneiden
  mittig angeordnete Fenster ab.
- Labor-Boden (Karomuster) sieht auf Werbebildern schlecht aus → vorher `surface.set_tiles`
  mit Gras unter das Motiv.

## 8. Tipps & Tricks mit Szenen

- `tips-and-tricks-item` mit `simulation = { init = "<Lua-Code>", mods = { "<mod>" } }` –
  `mods` lädt die Runtime-Scripts der Mod in der Simulation (die Mod läuft wirklich).
- **Sichtbarkeit:** Standard ist `starting_status = "locked"`. Ein Auslöser wie
  `{ type = "research", technology = … }` feuert **nicht nachträglich**, wenn die Technologie
  schon erforscht war → Einträge bleiben unsichtbar. Für Bedienungs-Hilfen
  `starting_status = "unlocked"` setzen. Spieler können mit `/unlock-tips` alles freischalten.
- Szenen-Code als **Text in einer Lua-Datei** ablegen (z. B. `prototypes/tips/simulation-code.lua`),
  dann kann ein Headless-Testmod denselben Code mit `load()` ausführen und prüfen.
- Testspieler: `game.simulation.create_test_player{name=…}`, `camera_player`, `camera_position`,
  `camera_alt_info = true`; Ablauf mit `require("__core__/lualib/story")` + `tip_story_init`.
  Ohne `story_jump_to(...)` am Ende läuft die Szene einmal und bleibt stehen.
- Maus-Aktionen: `game.simulation.move_cursor{position=…}` als Bedingung,
  `control_down/control_up{control="copy-entity-settings"}` bzw. `"paste-entity-settings"`.
- Entity-Fenster in kleinen Szenen können vom Vanilla-Schaltungs-Panel aus dem Bild geschoben
  werden → Mod-eigenes Fenster in der Szene als eigenständiges `screen`-Fenster öffnen.
- `length` der Simulation ist für das Hauptmenü gedacht; Tipps-Szenen laufen ohne.
- Szenen kurz halten: Greifarm-Bonus setzen (`force.bulk_inserter_capacity_bonus`), sonst dauert
  das Beladen länger, als jemand zuschaut.

## Scripts in diesem Skill

| Datei | Zweck |
|---|---|
| `scripts/package.sh` | Zip `<name>_<version>` nach `dist/`, ohne Entwicklungsdateien, Größenwarnung |
| `scripts/headless-test.sh` | Mod + Testmod headless starten, `[SELFTEST]`-Zeilen ausgeben |
| `scripts/templates/selftest-mod/` | Testmod-Vorlage (`check()`, Phasen per `on_nth_tick`) |
| `scripts/lint.sh` | `lua-language-server --check` mit den FMTK-Typen, nur Warnungen |
| `scripts/release.yml` | GitHub-Workflow: Portal-Upload bei neuer Version + GitHub-Release |
| `scripts/templates/screenshot-mod/` | Hilfsmod für Bilder (mit Grafik), inkl. sicherem Start-/Stop-Script |
| `scripts/generate_mod.py` | Mod-Gerüst inkl. `.gitignore`, `tools/package.sh`, Workflow |
| `scripts/gen_defines_reference.py` | erzeugt `references/09-defines.md` neu aus der offiziellen API (bei neuen Factorio-Versionen ausführen) |
