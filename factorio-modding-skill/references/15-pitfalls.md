# Stolperfallen – im Projekt geprüft (Factorio 2.1.19)

> Jede Zeile wurde in einem echten Mod headless oder im Spiel bestätigt (Sept. 2026) bzw. gegen
> [lua-api.factorio.com](https://lua-api.factorio.com/latest/) geprüft. Neue Funde hier ergänzen.
>
> **Schnellprüfung eigener Codes:** `scripts/lint.sh <ordner>` findet mit den FMTK-Typen erfundene
> Felder/Methoden; alle Beispiele und Referenz-Codeblöcke dieses Skills sind so geprüft.

## Lua und Lebenszyklus

| Falle | Richtig |
|---|---|
| „In `storage` keine LuaObjects speichern, nur `unit_number`“ | **Falsch.** Referenzen auf LuaObjects sind erlaubt ([Storage](https://lua-api.factorio.com/latest/auxiliary/storage.html)). Verboten: Funktionen (Fehler beim Speichern). Nicht registrierte Metatables gehen verloren. Vor Nutzung `.valid` prüfen. |
| `table.deepcopy()` zur Laufzeit | Nur in der Prototyp-Stufe. In control.lua: `local util = require("util")` → `util.table.deepcopy(t)`. |
| `require` in einer Funktion zur Laufzeit | Fehler „Require can't be used outside of control.lua parsing“ → alle `require` oben in der Datei. |
| Szenario richtet Mods in seinem `on_init` ein (`remote.call`) | Das Szenario-`on_init` läuft **vor** dem der Mods, und der `storage` einer Mod wird bei *ihrem* `on_init` angelegt → Einrichtung im **ersten Tick** (`script.on_nth_tick(1, …)`, danach abmelden; in `on_load` neu registrieren, falls noch nicht fertig). Die Mod selbst sollte Aufrufe vor ihrem `on_init` abfangen (`State.ensure()`: fehlende Tabellen anlegen). |
| Zahlen als Text-Schlüssel | Factorio-Lua rechnet mit Kommazahlen; `-0` wird als `"-0"` geschrieben → Schlüssel nicht aus Rechenergebnissen bilden (`key = x .. ":" .. y`). |
| `LuaEntity.copy_settings()` per Script | Löst **kein** `on_entity_settings_pasted` aus → Kopier-Logik der Mod als eigene Funktion aufrufbar machen. |
| Rechnen in Textfeldern | `helpers.evaluate_expression(text)` in `pcall`, `nan`/`inf` verwerfen. |
| `obj:methode()` auf LuaObjects | Factorio-Methoden mit **Punkt** aufrufen: `platform.can_leave_current_location()`. |
| `game.paused`, `game.ticks_per_second`, `player.online` | gibt es nicht → `game.tick_paused`, `player.connected` (60 Ticks = 1 s bei Geschwindigkeit 1). |
| Zwei `script.on_nth_tick(n, …)` mit gleichem `n` | Der zweite Aufruf **ersetzt** den ersten Handler → Arbeit in einem Handler bündeln. |
| Event-Felder raten (`event.new_state`, `event.player_index` bei `on_entity_died` …) | Felder je Event auf [events.html](https://lua-api.factorio.com/latest/events.html) nachsehen; neuer Zug-Zustand = `train.state`. |
| `defines.comparator`, `defines.quality`, `defines.circuit_connector` | gibt es nicht – Liste in `references/09-defines.md` (aus der API erzeugt). |
| `settings.global["fremde-einstellung"] = …` | Fehler „Settings can only be changed by the owning player or the mod that made the setting“ – fremde Map-Einstellungen darf eine Mod nicht setzen. |
| Ordnername des Mods | muss `<name>` **oder** `<name>_<version>` sein, sonst „Directory name of mod … doesn't match“. Ohne Version im Ordnernamen entfällt das Umbenennen bei jeder neuen Version. |

## GUI

| Falle | Richtig |
|---|---|
| `frame.style.vertical_spacing = …` | Fehler „Expected Table or Flow or VerticalFlow or TabbedPane style type but was Frame“ → Abstand an einem **Flow** im Frame setzen. |
| Panel an einem Vanilla-Fenster (`gui.relative`, Position rechts) | Rechts sitzt bei verkabelten Entities das **Schaltungs-Panel** – beides zusammen passt oft nicht auf den Bildschirm → Panel **links** anhängen. Den Klappzustand des Vanilla-Schaltungs-Panels kann eine Mod nicht setzen. |
| Alte Fenster nach einem Mod-Update | Fenster tragen eine `GUI_VERSION` im `storage`; stimmt sie nicht, schließen statt auffrischen (sonst Absturz beim Zugriff auf fehlende Elemente). |
| `player.opened = entity`, wenn schon dieses Entity offen ist | Schließt/öffnet neu → nur zuweisen, wenn `player.opened ~= entity`. |
| Setzen von `player.opened` | löst `on_gui_opened` aus – eigene Panels hängen sich wie beim Klick an. |

## Züge

| Falle | Richtig |
|---|---|
| Fahrplan überschreiben | Temporäre Halte mit `schedule.add_record{…, temporary = true, index = {schedule_index = n}}` einfügen – eigener Fahrplan, Zuggruppe und Interrupts bleiben. Temporäre Records gelten **pro Zug**, auch in einer Gruppe. |
| Gleichnamige Haltestellen | Vor die Station einen Schienen-Wegpunkt (`rail = stop.connected_rail`, `rail_direction = stop.connected_rail_direction`) setzen → genau diese Haltestelle. Dabei greift das Vanilla-Zuglimit nicht → `trains_count < trains_limit` selbst prüfen. |
| Wartebedingungen mischen | Liste wird als (A UND B …) ODER (C …) ausgewertet; `compare_type = "or"` beginnt eine neue Gruppe. „Ware = 0“ je Ware (`item_count`/`fluid_count`, `comparator = "="`, `constant = 0`) statt `empty`, wenn der Zug nacheinander mehrere Stationen anfährt. |
| Pfadsuche | `game.train_manager.request_train_path{train, goals = {{train_stop = s}, …}, steps_limit}` liefert `found_path`, `goal_index`; mit `type = "all-goals-accessible"` → `amount_accessible`. Eine Suche über viele Ziele ist billiger als viele einzelne. |
| Losschicken ist teuer | `go_to_station` löst die Pfadsuche des Spiels aus (Spitzen 5–15 ms bei großen Netzen) → pro Heartbeat nur wenige Züge losschicken. |
| Gleise per Script setzen | Gleise liegen auf **ungeraden** Koordinaten. Baut man ein Gleisnetz relativ zu einem geraden Ursprung, rutschen Haltestellen, Greifarme und Wagen um ein Feld gegeneinander – Greifarme erreichen den Wagen dann nicht. |
| Zug an Haltestelle platzieren | Lok-Mitte liegt 3 Felder hinter der Haltestelle, jeder weitere Wagen 7 Felder. Auf waagerechten Gleisen rücken Wagen beim Setzen um bis zu 2 Felder → jeden Wagen relativ zur **tatsächlichen** Position des vorherigen setzen, sonst koppeln sie nicht. |

## Entities, Kabel, Flüssigkeiten

| Falle | Richtig |
|---|---|
| Greifarm mit `pickup_position`/`drop_position` | Nur bei Prototypen mit `allow_custom_vectors`; **Bulk-Greifarme ignorieren es still**. Stattdessen `direction` = Seite, **von der** gegriffen wird (Nord = 0 greift von Norden). |
| Mehrere Waren in einer Kiste für einen Greifarm | Ein Greifarm nimmt aus einer gemischten (Unendlich-)Kiste nur eine Sorte → je Ware eine Kiste/einen Greifarm. |
| Kabelreichweite | Standard 9 Felder (`circuit_wire_max_distance`); `connect_to` liefert `false`, wenn zu weit → Rückgabe prüfen, ggf. Mast als Zwischenstück. |
| Kabel verbinden | `a.get_wire_connector(defines.wire_connector_id.circuit_green, true).connect_to(b.get_wire_connector(…, true))`; Combinator-Ein-/Ausgang: `combinator_input_green`/`combinator_output_green`. Kabeländerungen lösen **kein** Event aus → Zuordnung regelmäßig oder beim Bau prüfen. |
| Pumpe am Flüssigkeitswagen | Funktioniert an **jeder** Stelle entlang des Wagens (2.x); Pumpe direkt neben das Gleis (Mitte 2 Felder von der Gleisachse), Ausgang zum Wagen (Laden) bzw. vom Wagen weg (Entladen). |
| Lagertank-Anschlüsse | Tank (Richtung Nord) hat Anschlüsse bei Nordseite x = -1, Südseite x = +1, Ostseite y = +1, Westseite y = -1 → Tank um 1 Feld entlang der Gleisachse versetzen, damit ein Anschluss vor der Pumpe liegt. |
| Unendlich-Rohr als Quelle/Abfluss | `set_infinity_pipe_filter{name = fluid, percentage = 1, mode = "at-least"}` bzw. `percentage = 0, mode = "exactly"`. |
| „Kreativmod nötig“ für Testkarten | Nein: `infinity-chest`, `infinity-pipe`, `electric-energy-interface` sind Vanilla-Entities (nur im Baumenü versteckt) und per Script baubar. |

## 2.x-Gleisgeometrie (im Spiel ermittelt, relativ zu geradem Gleis auf ungeraden Koordinaten)

- 90°-Kurve: 4 Stücke, Ende ±14/±14. Wendeschleife: 8 Stücke, 26 breit.
- Abzweig/Einmündung (parallel versetzt): 4 Stücke, Versatz 6, gerades Nebengleis beginnt bei ±20.
- Waagerecht → schräg (Südost): `curved-rail-a` Richtung 6 bei (3, 0), `curved-rail-b` 6 bei (8, 2),
  danach schräges gerades Gleis (Richtung 6) bei (11, 5), Schritt (2, 2).
- Signale: rechts neben dem Gleis im Abstand 1,5, Blickrichtung gegen die Fahrtrichtung.

## Leistung (gemessen, 384 Züge, 880 Haltestellen, sonst leere Karte)

- Ein einziger `on_nth_tick`-Takt mit festem Budget; Stationen reihum lesen; nur geänderte
  Stationen neu auswerten.
- Ohne freien Zug keine Anbieter-Suche; Erreichbarkeit je Depot-Name cachen und bei Gleis-/
  Signal-Bau verwerfen; höchstens eine neue Pfadsuche pro Durchlauf.
- Ergebnis: Mod im Schnitt 0,03–0,07 ms pro Tick; die Kosten stecken in den Zügen des Spiels.
