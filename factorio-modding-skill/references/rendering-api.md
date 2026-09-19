# Factorio 2.1 API: Rendering & Visualization

> **Stand:** Signaturen geprüft gegen [LuaRendering](https://lua-api.factorio.com/latest/classes/LuaRendering.html)
> und [LuaRenderObject](https://lua-api.factorio.com/latest/classes/LuaRenderObject.html), Factorio 2.1.19 (Sept. 2026).
> Bei Unsicherheit immer die offizielle Doku prüfen.

## Wichtig: Was es in 2.x **nicht** mehr gibt

Ältere Beispiele (1.1) arbeiten mit Zahl-IDs und Funktionen auf `rendering`. In 2.x liefert jedes
`draw_*` ein **`LuaRenderObject`**; Änderungen und Löschen laufen über dieses Objekt.

| Gibt es nicht (1.1 / erfunden) | Stattdessen (2.x) |
|---|---|
| `rendering.destroy(id)` | `obj.destroy()` |
| `rendering.get(id)` | `rendering.get_object_by_id(id)` → `LuaRenderObject?` |
| `rendering.set_color(id, …)`, `rendering.is_valid(id)` | `obj.color = …`, `obj.valid` |
| Parameter `tag`, `rendering.destroy_by_tag`, `rendering.find_all` | Objekte selbst merken (Tabelle in `storage`) |
| Parameter `only_for_player`, `force`, `surface_forced` | `players = {…}`, `forces = {…}` |
| `draw_polygon{ points = … }` | `draw_polygon{ vertices = … }` (Dreiecks-Streifen) |
| `draw_light{ size = … }` | `draw_light{ scale = … }` |
| Event `on_mod_disabled` | gibt es nicht; beim Entfernen der Mod verschwinden ihre Render-Objekte ohnehin |

Alles, was die eigene Mod gezeichnet hat, auf einmal löschen: `rendering.clear(script.mod_name)`.
Alle eigenen Objekte holen: `rendering.get_all_objects(script.mod_name)`.

## Gemeinsame Parameter aller `draw_*`

`surface` (Pflicht), `time_to_live` (Ticks, danach automatisch weg), `blink_interval`,
`forces` (nur für diese Forces sichtbar), `players` (nur für diese Spieler), `visible`,
`only_in_alt_mode`, `render_mode` („game“/„chart“), `tall`. `draw_on_ground` bei Linie, Text,
Kreis, Rechteck, Bogen, Polygon. **`render_layer` nur bei `draw_sprite` und `draw_animation`.**

`target` ist eine `ScriptRenderTarget`: eine Position **oder** ein Entity (dann folgt das Objekt
dem Entity und verschwindet mit ihm).

## Die Zeichenfunktionen

```lua
local surface = game.surfaces["nauvis"]

-- Linie (optional gestrichelt)
local line = rendering.draw_line{
  surface = surface, from = {0, 0}, to = {10, 5},
  color = {r = 1, g = 0, b = 0}, width = 2,           -- width in Pixeln
  dash_length = 0.5, gap_length = 0.25,               -- optional
  time_to_live = 300, players = {1},                  -- nur Spieler 1
}

-- Text (String oder LocalisedString)
local label = rendering.draw_text{
  surface = surface, target = some_entity,            -- folgt dem Entity
  text = {"entity-name.assembling-machine-1"},
  color = {1, 1, 1}, scale = 1.5, alignment = "center",
  vertical_alignment = "middle", use_rich_text = true,
}

-- Kreis
local circle = rendering.draw_circle{
  surface = surface, target = {25, 25}, radius = 10,
  color = {r = 0, g = 0, b = 1, a = 0.3}, filled = true,
}

-- Rechteck
local rect = rendering.draw_rectangle{
  surface = surface, left_top = {0, 0}, right_bottom = {50, 50},
  color = {r = 0, g = 1, b = 0, a = 0.3}, filled = true, draw_on_ground = true,
}

-- Bogen / Ring-Ausschnitt
local arc = rendering.draw_arc{
  surface = surface, target = {0, 0}, min_radius = 4, max_radius = 5,
  start_angle = 0, angle = math.pi, color = {1, 0.5, 0},
}

-- Polygon: Dreiecks-Streifen; vertices = array[ScriptRenderTarget] (Positionen oder Entities)
local poly = rendering.draw_polygon{
  surface = surface, color = {r = 1, g = 0.5, b = 0, a = 0.5},
  vertices = { {0, 0}, {10, 0}, {0, 10}, {10, 10} },  -- ergibt ein Quadrat aus zwei Dreiecken
}

-- Sprite (hier gibt es render_layer)
local icon = rendering.draw_sprite{
  surface = surface, target = {10, 10}, sprite = "item/iron-plate",
  x_scale = 1, y_scale = 1, render_layer = "entity-info-icon",
}

-- Licht
local light = rendering.draw_light{
  surface = surface, target = {10, 10}, sprite = "utility/light_medium",
  scale = 2, intensity = 1, color = {r = 1, g = 0.8, b = 0.2},
}
```

Sprite-Pfade: `"item/<name>"`, `"entity/<name>"`, `"fluid/<name>"`, `"virtual-signal/<name>"`,
`"technology/<name>"`, `"utility/<name>"`.

## Objekte verwalten

```lua
-- Merken (LuaRenderObject darf in storage stehen)
storage.markers = storage.markers or {}
storage.markers[entity.unit_number] = rendering.draw_circle{
  surface = entity.surface, target = entity, radius = 3, color = {0, 1, 0}, filled = false,
}

-- Ändern
local obj = storage.markers[unit]
if obj and obj.valid then
  obj.color = {r = 1, g = 0, b = 0}
  obj.visible = false
end

-- Löschen
if obj and obj.valid then obj.destroy() end
storage.markers[unit] = nil

-- Alles von dieser Mod löschen (z. B. beim Neuaufbau)
rendering.clear(script.mod_name)
```

Über eine ID (z. B. aus einem Event oder einer anderen Mod): `rendering.get_object_by_id(id)`.

## Render-Layer (Auswahl)

Gültige Werte laut [RenderLayer](https://lua-api.factorio.com/latest/types/RenderLayer.html), u. a.:
`"ground-patch"`, `"floor"`, `"lower-object"`, `"object"`, `"higher-object-under"`,
`"higher-object-above"`, `"wires"`, `"entity-info-icon"`, `"entity-info-icon-above"`,
`"air-object"`, `"air-entity-info-icon"`, `"light-effect"`, `"selection-box"`, `"arrow"`, `"cursor"`.

## Leistung

1. Für Kurzlebiges `time_to_live` setzen – dann muss nichts aufgeräumt werden.
2. Für Dauerhaftes die Objekte in `storage` merken und gezielt `destroy()` aufrufen, statt jedes
   Mal neu zu zeichnen.
3. `target = entity` statt Position: folgt dem Entity ohne Script-Arbeit und verschwindet mit ihm.
4. Nicht in jedem Tick zeichnen; bei Markierungen `on_nth_tick` oder Ereignisse nutzen.
5. Anzahl begrenzen: eigene Zählung in `storage` führen.

## Muster

### Reichweite eines Roboports anzeigen
```lua
local function show_range(roboport)
  local radius = roboport.prototype.logistic_radius
  return rendering.draw_circle{
    surface = roboport.surface, target = roboport, radius = radius,
    color = {r = 0, g = 1, b = 0, a = 0.15}, filled = true, draw_on_ground = true,
    time_to_live = 600,
  }
end
```

### Verbindung zwischen zwei Entities
```lua
local function connect(a, b, player_index)
  return rendering.draw_line{
    surface = a.surface, from = a, to = b,           -- folgt beiden Entities
    color = {r = 1, g = 0.5, b = 0}, width = 3,
    players = {player_index}, time_to_live = 600,
  }
end
```
