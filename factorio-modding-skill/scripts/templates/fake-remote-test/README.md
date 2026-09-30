# Fremde Mod-Schnittstelle headless nachbilden (geprüft mit Space Exploration)

Manche Mods lassen sich headless nicht vollständig testen (SE baut Aufzüge nur für Teams mit
Spielern). Dann den **eigenen** Code gegen eine Nachbildung der Schnittstelle prüfen:

1. Testmod mit Abhängigkeit auf den eigenen Mod, **ohne** die fremde Mod.
2. Im Hauptteil von `control.lua` (nicht in `on_init`):
   ```lua
   local STARTED = script.generate_event_name()        -- eigene Ereignis-IDs
   remote.add_interface("space-exploration", {          -- gleicher Name wie die echte Mod
     get_on_train_teleport_started_event = function() return STARTED end,
     get_space_elevator_info = function(data) … end,
   })
   ```
   Schnittstellen aus dem Hauptteil existieren schon, wenn der eigene Mod in `on_init`/`on_load`
   danach fragt.
3. Das Verhalten der fremden Mod per Script nachspielen (bei SE: neuer Zug auf der anderen
   Oberfläche, Fahrplan ohne `rail`-Einträge, `script.raise_event(STARTED/FINISHED, {…})`).
4. Ergebnisse in `storage` sammeln, nicht in einer lokalen Tabelle: `--create` und `--benchmark`
   sind zwei Prozesse – was `on_init` im ersten Prozess prüft, ist im zweiten sonst weg.
5. Danach **einmal grafisch mit der echten Mod** gegenprüfen (die Nachbildung zeigt nur, dass der
   eigene Code zur Schnittstelle passt, wie man sie gelesen hat).

Im Projekt: `tools/setest/utl-setest_0.0.1/control.lua` (14 Prüfungen: Lieferung Planet → Orbit,
neue Zug-ID, Wegpunkt, Heimweg, Abbruch drüben).
