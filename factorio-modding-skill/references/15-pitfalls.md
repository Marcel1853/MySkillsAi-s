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
| Takt-Anmeldungen nach dem Laden | `script.on_nth_tick` aus `on_init` oder aus einem Handler gilt **nicht** nach dem Laden eines Spielstands → in `on_load` wieder anmelden, was noch offen ist (Merker in `storage`). |
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
| Zwei Züge hintereinander setzen | Mit 7 Feldern Abstand kuppeln sie zu **einem** Zug zusammen (alte `LuaTrain`-Referenzen werden ungültig). Alle Teile mit `auto_connect = false` erzeugen und danach gezielt `carriage.connect_rolling_stock(defines.rail_direction.front)`; anschließend `#train.carriages` prüfen. |
| Zug per Script erzeugt fährt nicht los | Er steht im Handbetrieb – nach `schedule.go_to_station(1)` noch `train.manual_mode = false` setzen. |
| Eigenen Setzversuch abräumen | Zerstört man einen Wagen, der sich an einen fremden Zug gehängt hat, wird **dieser geteilt und steht danach im Handbetrieb**. Deshalb nie ohne `auto_connect = false` bauen. |
| Fahrzeug unter einem Hochgleis | Lässt sich nicht setzen (`create_entity` liefert nil, ohne Meldung) → Stelle 2 Felder weiter versuchen und den Fehlversuch zählen, sonst entstehen still zu kurze Züge. |
| Wagenslots filtern | `inventory.set_filter(slot, {name = …, quality = "normal", comparator = "="})` liefert **false**, wenn der Slot belegt ist → `sort_and_merge()` vorher, später nachbessern. `set_bar(n)` sperrt den Rest (Greifarme respektieren beides, Script-`insert` nicht immer). Eigene Filter des Spielers an `is_filtered()`/`get_bar()` erkennen und in Ruhe lassen. |

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
| `entity.fluidbox` | Gibt es in 2.1 **nicht mehr** (Fehler „LuaEntity doesn't contain key fluidbox“). Anschlüsse: `entity.get_fluid_box_pipe_connections(index)` → `PipeConnection` mit `target_position`; Nachbarn: `get_fluid_box_neighbours(index)`. |
| Tank, Pumpe und Rohr gerechnet setzen | Objekte rasten je nach Größe verschieden ein (1 × 1 auf .5, 2 × 2 auf .0 …) – gerechnete Punkte liegen dann neben dem Anschluss oder auf dem Gleis. Sicher: am **tatsächlichen** Vorgänger ausrichten (`entity.position`, `get_fluid_box_pipe_connections`) und vor dem Bauen mit `find_entities_filtered` prüfen, ob dort Gleis liegt. |
| Unendlich-Kiste prüfen | Sie füllt sich erst über ein paar Ticks – direkt nach `create_entity` ist sie leer. Erst nach ~100 Ticks prüfen. |
| Greifarm-Filter aus dem Schaltnetz | `inserter.use_filters = true` **und** `control_behavior.circuit_set_filters = true`; dann setzt das Netz die Filter. Praktisch, wenn ein Zug nur bestimmte Waren annimmt. |
| Eigenes Signal in einen Konstant-Kombinator schreiben | Bei `min ≠ 0` braucht der Eintrag `quality = "normal"` **und** `comparator = "="`, sonst: „Can't specify non zero request with non trivial item filter condition“. Also `section.set_slot(i, {value = {type = "virtual", name = …, quality = "normal", comparator = "="}, min = n})`. |

## Blaupausen per Script bauen

| Falle | Richtig |
|---|---|
| `create_entities_from_blueprint_string` | Nur in Simulationen (Tipps & Tricks). Im Spiel: `game.create_inventory(1)` → `set_stack{name="blueprint"}` → `import_stack(text)` → `build_blueprint{…}` → jedes `entity-ghost` mit `revive{raise_revive = true}`. Oder die Blaupause vorher in eine Lua-Tabelle umwandeln und mit `create_entity` bauen (schneller, deterministisch). |
| Blaupause verschieben | Nur um **gerade** Beträge: Gleise liegen auf ungeraden Koordinaten. Eine ungerade Verschiebung verdreht das Raster, die Gleise rasten um ein Feld zurück, und die Signale finden ihr Gleis nicht mehr. |
| Reihenfolge beim Bauen | Erst **alle Gleise**, dann Signale und Haltestellen: Ein Signal ohne sein Gleis rutscht beim Setzen an das nächstbeste – danach stehen die Signale kreuz und quer. Prüfen mit `#signal.get_connected_rails() == 0`. |
| Hochgleise (2.1) | Die Blaupause trägt an Signalen `rail_layer = "elevated"`. Ohne `rail_layer = defines.rail_layer.elevated` in `create_entity` landen sie auf der Bodenebene: Die Hochbahn ist dann ein einziger Block, und die Züge fahren auf. Stützen und Rampen vor den Hochgleisen setzen. |
| Kabel aus der Blaupause | Gehen beim Umwandeln in eine Lua-Tabelle verloren (`wires`-Liste). Entweder mit übernehmen oder im Script neu verbinden (z. B. Combinator → nächstgelegene Haltestelle). |
| Deckungsgleiche Nachbarblöcke | Setzt man ein Raster aus Blöcken, schlagen die gemeinsamen Randstücke beim Nachbarn fehl. Das ist normal – solche „Doppelstücke“ getrennt zählen, sonst sieht die Fehlerzahl im Log dramatisch aus. |

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

## Prototypen und Tipps & Tricks

- **Technologie-Name auf `-<Zahl>`** (z. B. `utl-networks-1`): Factorio lässt die Zahl bei der
  Übersetzung weg und sucht `technology-name.utl-networks` → „Unknown key“. Entweder die Schlüssel
  ohne Zahl anlegen (dann steht nur die Zahl am Symbol) oder je Stufe
  `localised_name = { "technology-name.<name>" }` und `localised_description` setzen.
  Quelle: TechnologyPrototype, Feld `name`.
- `effect_description` einer Technologie: Parameter im Datenstadium als **Text** (`"1"`), keine Zahl.
- Tipps-Szenen können nicht in Mod-Fenster klicken: Klicks lösen keine Mod-Events aus. Stattdessen
  per `remote.call` die Aktion ausführen und das Fenster neu öffnen; Sichtbares (Textfeld füllen,
  Listeneintrag wählen) direkt an `player.gui` über die `tags` der Elemente setzen – das löst
  ebenfalls kein Event aus, zeigt aber, was der Spieler tun würde.
- **Anzeigefeld (`display-panel`) per Script** (im Spiel geprüft, 2.1): `entity.display_panel_text`,
  `display_panel_icon` (SignalID), `display_panel_always_show` (Text in der Alt-Ansicht dauerhaft),
  `display_panel_show_in_chart` (Text auf der Karte). Die Meldungen mit Bedingung liegen am
  `LuaDisplayPanelControlBehavior` als `records` / `add_record{ text, icon, condition }` (nicht mehr
  `messages`). Text ist einfacher Text, keine LocalisedString. `player.locale` hilft nicht: Beim
  Aufbau (Szenario-Tick 1, Tipps-Simulation) steht die Sprache noch nicht fest, es kam „en“ heraus.
  Übersetzter Text in der Welt → `rendering.draw_text{ text = { "key" }, … }` über das Feld, das
  zeigt jedem Spieler seine Sprache. `create_entity` prüft keine Kollision → vorher `can_place_entity`.
- Tipps-Szene: Text nah am Rand wird abgeschnitten. Bei `camera_zoom = 0.75` ist das Bild etwa
  ±29 Felder breit – Schilder mit langem Text höchstens bei ±22 setzen.
- Headless-Server für Szenario-Tests: `--start-server-load-scenario <mod>/<szenario>` mit
  `--server-settings` (braucht `name`) und `auto_pause = false`, sonst läuft ohne Spieler kein Tick;
  stdin offen halten (`sleep N | timeout -s INT M factorio …`), sonst beendet EOF den Server.
- **Fahrpläne kennen keine Teams** (im Spiel geprüft, 2.1): Ein Halt im Fahrplan ist nur ein
  *Name*. Ein Zug der Force „rot“ fährt zur gleichnamigen Haltestelle der Force „player“, wenn die
  näher liegt. Wer Teams trennen will, muss (a) vor den Halt einen Gleis-Wegpunkt setzen
  (`rail`, `rail_direction`) und (b) bei der Ankunft `stop.force_index` gegen
  `train.front_stock.force_index` prüfen.
- **Zuglimit der Haltestelle wirkt nicht bei Wegpunkt-Fahrten**: Fährt ein Zug per Gleis-Wegpunkt
  vor eine Haltestelle, zählt `stop.trains_count` ihn erst bei der Ankunft. Wer so dispatcht, muss
  die unterwegs befindlichen Züge selbst mitzählen (und beim Abbruch/Umbau wieder freigeben).
- **Kein Ereignis für „Spieler lädt einen wartenden Zug von Hand“**: Man braucht einen seltenen
  Blick (Heartbeat) auf die freien Züge – aber mit Budget, `train.get_contents()` je Zug ist teuer
  (im Lasttest mit 384 Zügen kostete ein ungedeckelter Durchlauf spürbar UPS).
- **`fuel_category` gibt es nicht mehr** (2.1, im Spiel geprüft): Im Prototyp heißt es
  `fuel_categories = { "chemical" }` (Liste), zur Laufzeit `LuaItemPrototype.fuel_categories`
  (Array von Strings). Achtung, die beiden sind **nicht** dasselbe: `LuaBurner.fuel_categories`
  und `LuaBurnerPrototype.fuel_categories` sind ein **Dictionary** `name → true`. Der alte Zugriff
  wirft beim Laden „ItemPrototype::fuel_category was removed“ bzw. zur Laufzeit
  „LuaItemPrototype doesn't contain key fuel_category“. Wer nur wissen will, wie voll ein Tank ist,
  braucht die Kategorie gar nicht: `locomotive.get_fuel_inventory()` und `stack.count /
  stack.prototype.stack_size` genügen und arbeiten mit jedem Mod-Treibstoff.
- **`LuaForce.get_trains` gibt es nicht** (2.1): Züge holt man über den Zug-Verwalter,
  `game.train_manager.get_trains({ surface = …, force = … })`. Ebenso `get_train_by_id` und
  `get_train_stops` dort.
- **Fremde Item-Zeilen umhängen**: Wer Items anderer Mods in eine eigene Registerkarte sortiert,
  darf eine **Subgruppe** nur dann mitnehmen, wenn dort ausschließlich eigene Sachen liegen
  (zählen: Items je Subgruppe gegen passende Items je Subgruppe). Nach dem Namen zu entscheiden
  („enthält train/rail“) reißt gemischte Zeilen fremder Mods aus ihrem Reiter.
- **`vertical_spacing` an einem Frame stürzt ab** (2.1, im Spiel): „Expected Table or Flow or
  VerticalFlow or TabbedPane style type but was Frame“. Zeilenabstand (und `horizontal_spacing`)
  gibt es nur bei Flows und Tabellen. Muster: Frame → Flow (mit Abstand) → Inhalt. Headless fällt
  das nicht auf, weil dort kein Fenster gebaut wird.
