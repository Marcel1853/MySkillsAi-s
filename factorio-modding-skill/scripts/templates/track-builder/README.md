# Gleisleger (Factorio 2.1, geprüft)

Baut Gleise Stück für Stück an ein offenes Gleisende an – mit `LuaRailEnd.get_rail_extensions`,
also denselben Bauangaben, die der Gleisplaner im Spiel benutzt. Passt dadurch auch an fremde
Gleise (z. B. die Innengleise des SE-Weltraumaufzugs), ohne Koordinaten zu raten.

```lua
local Track = require("track")
local ends = Track.open_ends(surface, center, 14)          -- offene Enden im Quadrat
local w = Track.walker(ends[1], surface, force, "rail")    -- Planer: "rail" oder z. B. "se-space-rail"
Track.straight(w, 10)   -- 10 gerade Stücke (je 2 Felder)
Track.signal(w)         -- Signal rechts, für die Fahrtrichtung
Track.turn(w, -1)       -- 90° links (4 × 22,5°)
Track.stop(w, "Depot")  -- Haltestelle rechts neben dem Ende (nur Hauptrichtungen)
Track.close(w, ziel_ende, 200) -- geradeaus bis zum Ende `ziel_ende` und verbinden
```

Eine Schleife mit vier Linkskurven gleicher Länge landet wieder auf der Ausgangshöhe – so lässt
sich eine Einbahn-Schleife von einer Ausfahrt zurück zu einer Einfahrt schließen.
Im Projekt: Szenario „UTL-Aufzug“ (212 Stücke je Seite, Planet und Orbit, geschlossen geprüft).
