# MySkillsAi-s

🇬🇧 [English version](README.md)

Eine Sammlung von **Skills für KI-Programmierhelfer** (gemacht für Claude / Claude Code). Ein Skill
ist ein Ordner mit einer `SKILL.md` und Nachschlagedateien: Wissen, geprüfte Stolperfallen,
Vorlagen und Werkzeuge, die die KI liest, wenn eine Aufgabe dazu passt. Weitere Skills kommen
mit der Zeit dazu.

## Skills

| Skill | Version | Wofür |
|---|---|---|
| [factorio-modding-skill](factorio-modding-skill) | 1.0.0 | **Factorio-2.1-Mods** schreiben, testen und veröffentlichen (auch Space Age) |

### factorio-modding-skill

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

## Einen Skill benutzen

- **Claude Code:** den Skill-Ordner (z. B. `factorio-modding-skill/`) nach `~/.claude/skills/`
  kopieren (für alle Projekte) oder nach `.claude/skills/` in einem Projekt.
- **Andere Werkzeuge:** der KI die `SKILL.md` geben und sie die genannten Dateien bei Bedarf lesen
  lassen.

## Versionen und Updates

Jeder Skill hat oben in der `SKILL.md` eine Versionszeile und eine `changelog.txt` (Factorio-Format).
Ein kopierter Skill aktualisiert sich **nicht** selbst und sagt der KI, nicht von sich aus
nachzusehen. Frag deine KI „Gibt es eine neuere Version des Skills?“ – sie vergleicht mit diesem
Repo, zeigt die Änderungen und ersetzt Dateien erst nach deinem Ja.

## Wie es entsteht

Die Skills entstehen mit Hilfe von KI (Claude von Anthropic) und werden in echten Projekten
getestet. Ich entscheide, was hineinkommt, und teste die Ergebnisse selbst. Korrekturen und Ideen
sind willkommen – gern als Issue.

## Lizenz

[MIT](LICENSE)
