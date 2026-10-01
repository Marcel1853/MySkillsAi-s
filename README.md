# MySkillsAi-s

🇩🇪 [Deutsche Fassung weiter unten](#deutsch)

A collection of **skills for AI coding assistants** (made for Claude / Claude Code). A skill is a
folder with a `SKILL.md` and reference files: knowledge, checked pitfalls, templates and tools that
the AI reads when a task fits. More skills will be added over time.

## Skills

| Skill | Version | What it is for |
|---|---|---|
| [factorio-modding-skill](factorio-modding-skill) | 1.0.0 | Writing, testing and publishing **Factorio 2.1 mods** (incl. Space Age) |

### factorio-modding-skill

My first skill. It grew while building the train dispatcher
[Unified Train Logistics](https://mods.factorio.com/mod/UTLogistics) – but it is meant for **any**
Factorio mod, not only train mods.

- **API reference** for Factorio 2.1: data lifecycle, prototypes, runtime, GUI, circuits, trains,
  rendering, Space Age (planets, platforms, asteroids, quality), locale.
- **Checked pitfalls** – things that look right but fail in the game, each found and verified in a
  real project.
- **Testing**: headless self tests, load tests, compatibility tests with other mods, scenario checks,
  screenshots with graphics, tips & tricks scenes, lint like in VS Code (FMTK).
- **Publishing**: packaging, changelog, mod portal, GitHub release workflow.
- **Project workflow** for long projects with an AI: plan, ideas, approved plans, mod portal
  discussion log, wiki, blueprints turned into test scenarios.
- **Examples** that load and run in Factorio 2.1 (checked with `scripts/check-examples.py`).

Always verify against the official API documentation: https://lua-api.factorio.com/latest/ –
Factorio 2.1 still changes.

## Using a skill

- **Claude Code:** copy the skill folder (e.g. `factorio-modding-skill/`) to `~/.claude/skills/`
  (for all your projects) or to `.claude/skills/` inside a project.
- **Other tools:** give the AI the `SKILL.md` and let it read the referenced files when needed.

## Versions and updates

Each skill has a version line at the top of its `SKILL.md` and a `changelog.txt` (Factorio format).
A copied skill does **not** update itself, and it tells the AI not to check on its own. Ask your AI
"is there a newer version of the skill?" – it compares with this repository, shows what changed
and replaces files only after you agree.

## How it is made

The skills are written with the help of AI (Claude by Anthropic) and tested in real projects. I
decide what goes in and test the results myself. Corrections and ideas are welcome – open an issue.

## License

[MIT](LICENSE)

---

## Deutsch

Eine Sammlung von **Skills für KI-Programmierhelfer** (gemacht für Claude / Claude Code). Ein Skill
ist ein Ordner mit einer `SKILL.md` und Nachschlagedateien: Wissen, geprüfte Stolperfallen,
Vorlagen und Werkzeuge, die die KI liest, wenn eine Aufgabe dazu passt. Weitere Skills kommen
mit der Zeit dazu.

### Skills

| Skill | Version | Wofür |
|---|---|---|
| [factorio-modding-skill](factorio-modding-skill) | 1.0.0 | **Factorio-2.1-Mods** schreiben, testen und veröffentlichen (auch Space Age) |

#### factorio-modding-skill

Mein erster Skill. Er ist beim Bau des Zug-Dispatchers
[Unified Train Logistics](https://mods.factorio.com/mod/UTLogistics) entstanden – gedacht ist er
aber für **jede** Factorio-Mod, nicht nur für Zug-Mods.

- **API-Nachschlagewerk** für Factorio 2.1: Lebenszyklus der Daten, Prototypen, Laufzeit, GUI,
  Schaltungen, Züge, Rendering, Space Age (Planeten, Plattformen, Asteroiden, Qualität), Locale.
- **Geprüfte Stolperfallen** – Dinge, die richtig aussehen, im Spiel aber scheitern; jede in einem
  echten Projekt gefunden und nachgeprüft.
- **Testen**: Selbsttests ohne Grafik, Lasttests, Tests zusammen mit anderen Mods, Szenario-Prüfung,
  Screenshots mit Grafik, Tipps-&-Tricks-Szenen, Lint wie in VS Code (FMTK).
- **Veröffentlichen**: Packen, Changelog, Mod-Portal, Release-Workflow auf GitHub.
- **Arbeitsweise** für lange Projekte mit KI: Plan, Ideen, freigegebene Pläne, Mitschrift der
  Portal-Diskussion, Wiki, Blaupausen als Test-Szenarien.
- **Beispiele**, die in Factorio 2.1 laden und laufen (geprüft mit `scripts/check-examples.py`).

Immer gegen die offizielle API-Dokumentation prüfen: https://lua-api.factorio.com/latest/ –
Factorio 2.1 ändert sich noch.

### Einen Skill benutzen

- **Claude Code:** den Skill-Ordner (z. B. `factorio-modding-skill/`) nach `~/.claude/skills/`
  kopieren (für alle Projekte) oder nach `.claude/skills/` in einem Projekt.
- **Andere Werkzeuge:** der KI die `SKILL.md` geben und sie die genannten Dateien bei Bedarf lesen
  lassen.

### Versionen und Updates

Jeder Skill hat oben in der `SKILL.md` eine Versionszeile und eine `changelog.txt` (Factorio-Format).
Ein kopierter Skill aktualisiert sich **nicht** selbst und sagt der KI, nicht von sich aus
nachzusehen. Frag deine KI „Gibt es eine neuere Version des Skills?“ – sie vergleicht mit diesem
Repo, zeigt die Änderungen und ersetzt Dateien erst nach deinem Ja.

### Wie es entsteht

Die Skills entstehen mit Hilfe von KI (Claude von Anthropic) und werden in echten Projekten
getestet. Ich entscheide, was hineinkommt, und teste die Ergebnisse selbst. Korrekturen und Ideen
sind willkommen – gern als Issue.

### Lizenz

[MIT](LICENSE)
