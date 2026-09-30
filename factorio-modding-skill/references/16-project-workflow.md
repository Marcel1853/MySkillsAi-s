# Arbeitsweise an einem Mod-Projekt mit KI (im Projekt geprüft)

Wie ein Mod über viele Sitzungen sauber vorankommt: Pläne, Ideen, Rückmeldungen der Spieler, Wiki,
Bilder und Testwelten liegen in einem `docs/`-Ordner im Mod – **nicht** im veröffentlichten Mod
(`docs/` steht in `.gitignore` und in der Ausschlussliste des Pakets). Gilt für jede Art Mod, nicht
nur für ein bestimmtes Thema. Vorlagen: `scripts/templates/docs/`.

## Der `docs/`-Ordner

| Datei / Ordner | Wozu |
|---|---|
| `PLAN.md` | Der laufende Plan: Stand, erledigte Meilensteine (mit Commit), offene Punkte, Entscheidungen mit Datum. Nach jedem Schritt eine kurze Notiz. |
| `IDEAS.md` (bei deutschen Projekten `IDEEN.md`) | Ideen der Spieler und des Autors, je mit Datum und Stand (Idee / geplant x.y.z / umgesetzt / verworfen). Auch „Korrekturen am Skill“: wo sich der Skill als falsch erwies. |
| `plans/` (`pläne/`) | Jeder freigegebene Plan als eigene Datei `JJJJ-MM-TT_<version>-<thema>.md`, dazu `README.md` mit einer Tabelle (Datum, Version, Thema, Stand). So bleibt nachvollziehbar, was wann beschlossen wurde. |
| `DISCUSSION.md` (`DISKUSSION.md`) | Mitschrift der Diskussion auf dem Mod-Portal, siehe unten. |
| `wiki/` | Lokale Kopie des GitHub-Wikis (`git clone <repo>.wiki.git wiki/repo`), siehe unten. |
| `screenshots/` | Bilder aus Tests und für Wiki/Portal – mit der Screenshot-Vorlage (`scripts/templates/screenshot-mod/`) aufgenommen, nie löschen, je Lauf ein Unterordner. |
| `blueprints/` (`blaupausen/`) | Blaupausen-Texte vom Spieler, aus denen Testwelten und Szenarien gebaut werden, siehe unten. |

Nicht hinein gehört, was schon im Code oder in der Git-Geschichte steht.

## Pläne

- Größere Vorhaben erst planen, den Plan vom Autor freigeben lassen, dann **Meilenstein für
  Meilenstein** umsetzen und nach jedem auf das Weiter warten.
- Der freigegebene Plan wird nach `plans/` kopiert (Datum im Dateinamen) und in der README-Tabelle
  eingetragen. `PLAN.md` verweist darauf und hält den Fortschritt fest.
- Jede Änderung an gespeicherten Daten bekommt ihre Migration – ein Plan nennt sie ausdrücklich,
  damit niemand einen neuen Spielstand anfangen muss.

## Diskussion auf dem Mod-Portal verfolgen

Sobald der Mod auf mods.factorio.com steht:

1. **Einmal je Sitzung**, bei der ersten Nachricht des Autors: `https://mods.factorio.com/mod/<name>/discussion`
   öffnen – Thread-Liste (Titel, Autor, Zahl der Antworten, letzte Aktivität) und jeden Thread mit
   neuer Aktivität lesen.
2. In `DISCUSSION.md` eintragen: eine Zeile in der Prüf-Tabelle (Datum, „Neues? ja/nein“, kurz was)
   und je Thread ein Abschnitt mit Link, Beiträgen (Autor, Datum, Inhalt in einem Satz),
   Entscheidung des Autors und Stand (offen / beantwortet / erledigt).
3. Neues kurz melden. **Antworten schreibt der Autor selbst** – auf Wunsch einen Textvorschlag
   liefern (in der Sprache des Threads, kurz, nichts versprechen, was noch nicht fertig ist:
   „kommt mit x.y.z“ statt „geht jetzt“).

Vorlage: `scripts/templates/docs/DISCUSSION.md`.

## Wiki

- GitHub-Wiki lokal klonen (`docs/wiki/repo`), Seiten je Sprache in Unterordnern (`de/`, `en/`),
  `_Sidebar.md` und `Home.md` verlinken beide Sprachen.
- Mit jedem Feature die Wiki-Seiten gleich mitschreiben und **lokal committen**; gepusht wird erst
  zum Release – sonst beschreibt das Wiki Dinge, die es noch nicht gibt.
- Bilder im Wiki-Repo (`images/…`) und per `raw.githubusercontent.com/wiki/<user>/<repo>/images/…`
  einbinden.

## Blaupausen → Testwelten und Szenarien

Der Spieler baut im Spiel, was er testen will (einen Rundkurs, einen Bahnhof, eine Fabrik), kopiert
die Blaupause als Text in `blueprints/`. Daraus:

1. `scripts/blueprint2lua.py <blaupause.txt> <ziel.lua>` → Lua-Tabelle (Name, Position, Richtung;
   Stützen und Gleise zuerst).
2. Ein Szenario oder Testmod baut die Tabelle mit `create_entity` nach – schneller und vorhersehbarer
   als `build_blueprint`. Kabel und Einstellungen gehen beim Umwandeln verloren und werden im Script
   gesetzt. Verschieben nur um gerade Beträge (Fallen: `references/15-pitfalls.md`).

## Szenarien für Spieler und Tests

- **Übungs-Szenarien** im Mod (`scenarios/<Name>/`): eine fertige kleine Welt, in der Spieler sehen,
  wie der Mod arbeitet (Beschreibung und Begrüßung in allen Sprachen der Locale). Gebaut wird im
  ersten Tick, nicht in `on_init` (Szenario-Scripte laufen vor den Mods).
- **Test-Szenarien** nur für die Entwicklung gehören in einen eigenen Werkzeug-Mod unter `tools/`
  (wird nicht veröffentlicht). Sie können Bilder aufnehmen (Screenshot-Vorlage) und sich selbst
  beenden.
- Szenario **ohne Spieler auf Ladefehler prüfen**: `scripts/scenario-check.sh`. Was erst für einen
  Spieler gebaut wird (manche Mods erlauben Dinge nur Teams mit Spielern), prüft nur ein grafischer
  Lauf.
- Braucht ein Szenario eine andere Mod-Auswahl (etwa eine Mod, die sich mit einem DLC nicht
  verträgt): `scripts/play-with-mods.sh` – eigener Mod-Ordner, die normale Mod-Liste bleibt, wie sie ist.

## Werkzeuge im Überblick

| Script | Wozu |
|---|---|
| `scripts/test-all.sh` | Lint je Ordner und alle Headless-Tests parallel, eine Zeile je Prüfung |
| `scripts/headless-test.sh` | Mod + Testmod headless, `[SELFTEST]`-Zeilen |
| `scripts/compat-test.sh` | wie oben, zusammen mit anderen Mods (nur verlinkt), DLC abschaltbar |
| `scripts/load-test.sh` | Lasttest: Zeit je Tick (Schnitt, 99 %, Max, Spitzen) |
| `scripts/scenario-check.sh` | Szenario ohne Spieler laden, Fehler melden |
| `scripts/play-with-mods.sh` | Spiel mit eigenem Mod-Satz starten |
| `scripts/screenshots.sh` + `templates/screenshot-mod/` | Bilder mit Grafik aufnehmen |
| `scripts/blueprint2lua.py` | Blaupause → Lua-Tabelle |
| `templates/fake-remote-test/` | Schnittstelle einer fremden Mod headless nachbilden |

Details zu Tests und Veröffentlichung: `references/14-testing-and-publishing.md`.
