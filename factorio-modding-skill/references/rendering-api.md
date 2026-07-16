# Factorio 2.1 API: Rendering & Visualization

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Rendering-APIs IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 (experimental) ändert sich wöchentlich. Die Rendering-API hat sich seit 2.0 nicht wesentlich geändert, aber neue Render-Layer oder Parameter können hinzugekommen sein.

## Table of Contents

- [LuaRendering Methods](#luarendering-methods)
  - [rendering.draw_sprite](#rendering.draw_sprite)
  - [rendering.draw_text](#rendering.draw_text)
  - [rendering.draw_line](#rendering.draw_line)
  - [rendering.draw_rectangle](#rendering.draw_rectangle)
  - [rendering.draw_circle](#rendering.draw_circle)
  - [rendering.draw_polygon](#rendering.draw_polygon)
  - [rendering.draw_light](#rendering.draw_light)
- [Render Object Management](#render-object-management)
- [Render Layers](#render-layers)
- [Performance Tips](#performance-tips)
- [Common Visualization Patterns](#common-visualization-patterns)
  - [Entity Range Indicator](#entity-range-indicator)
  - [Selection Box Highlight](#selection-box-highlight)
  - [Arrow Indicator](#arrow-indicator)
  - [Player Position Marker](#player-position-marker)


- [LuaRendering Methods](#)
- [Render Object Management](#)
- [Render Layers](#)
- [Performance Tips](#)
- [Common Visualization Patterns](#)



Complete reference for the LuaRendering API, used to draw visual elements in the game world.

## LuaRendering Methods

All rendering methods return a `LuaRenderObject` with a unique ID that can be used to manage the render element.

### rendering.draw_sprite

Draw a sprite (icon/texture) at a position in the game world.

```lua
local sprite = rendering.draw_sprite{
  sprite = "utility/transport_belt",      -- Sprite path
  target = {x = 10, y = 10},             -- MapPosition or LuaEntity
  surface = game.surfaces["nauvis"],     -- LuaSurface
  time_to_live = 600,                    -- Ticks before auto-removal (optional)
  render_layer = "entity-info-icon",     -- Layer (optional, default: "above-inserters")
  only_for_player = false,               -- Show only to specific player
  force = nil,                           -- Show only to specific force
  players = nil,                         -- Show only to specific players (array of indices)
  tag = "my_mod_label"                   -- Custom tag for batch operations
}

-- Sprite paths:
-- "utility/transport_belt" — belt arrow
-- "utility/close_white" — close button icon
-- "item/iron-plate" — item icons
-- "entity/assembling-machine-3" — entity sprites
-- "virtual-signal/signal-A" — virtual circuit signals
```

### rendering.draw_text

Draw text label at a position.

```lua
local text = rendering.draw_text{
  text = "Factory Zone A",              -- String or LocalisedString
  target = {x = 50, y = 50},           -- MapPosition or LuaEntity
  surface = game.surfaces["nauvis"],    -- LuaSurface
  color = {r = 1, g = 1, b = 1, a = 1}, -- RGBA color (default: white)
  scale = 1.5,                          -- Text scale (default: 1.0)
  time_to_live = 1200,                  -- Auto-remove after ticks
  alignment = "center",                 -- "left", "center", "right"
  render_layer = "entity-info-icon",    -- Drawing layer
  only_for_player = false,
  tag = "zone_labels",
  surface_forced = game.surfaces["nauvis"]  -- Force surface
}

-- LocalisedString example:
local loc_text = rendering.draw_text{
  text = {"", {"entity-name.assembling-machine-1"}, ": ", {"item-productivity.productivity-bonus-description", 10}},
  target = {x = 0, y = 0},
  surface = surface
}
```

### rendering.draw_line

Draw a line between two points.

```lua
local line = rendering.draw_line{
  from = {x = 0, y = 0},              -- Start position
  to = {x = 100, y = 100},            -- End position
  color = {r = 1, g = 0, b = 0},      -- Line color
  width = 2,                           -- Line width in pixels
  surface = game.surfaces["nauvis"],   -- LuaSurface
  time_to_live = 300,                  -- Duration in ticks
  render_layer = "higher-object-above",
  tag = "boundary_lines",
  players = {1}                        -- Show only to player 1
}
```

### rendering.draw_rectangle

Draw a rectangular outline or filled rectangle.

```lua
local rect = rendering.draw_rectangle{
  left_top = {x = 0, y = 0},          -- Top-left corner
  right_bottom = {x = 50, y = 50},    -- Bottom-right corner
  color = {r = 0, g = 1, b = 0, a = 0.3},  -- RGBA
  filled = true,                       -- Fill the rectangle
  surface = game.surfaces["nauvis"],
  time_to_live = 600,
  render_layer = "lower-object",
  tag = "selection_area"
}
```

### rendering.draw_circle

Draw a circle (outline or filled).

```lua
local circle = rendering.draw_circle{
  target = {x = 25, y = 25},          -- Center position or LuaEntity
  radius = 10,                         -- Circle radius
  color = {r = 0, g = 0, b = 1},      -- Circle color
  filled = false,                      -- Filled or outline
  surface = game.surfaces["nauvis"],
  time_to_live = 600,
  render_layer = "entity-info-icon",
  tag = "range_indicator"
}
```

### rendering.draw_polygon

Draw a polygon shape.

```lua
local poly = rendering.draw_polygon{
  points = {                           -- Array of positions
    {x = 0, y = 0},
    {x = 10, y = 0},
    {x = 10, y = 10},
    {x = 5, y = 15},
    {x = 0, y = 10}
  },
  color = {r = 1, g = 0.5, b = 0, a = 0.5},
  filled = true,
  surface = game.surfaces["nauvis"],
  time_to_live = 3600,
  tag = "zone_boundaries"
}
```

### rendering.draw_light

Draw a light effect at a position.

```lua
local light = rendering.draw_light{
  target = {x = 10, y = 10},
  sprite = "utility/light_medium",     -- Light sprite
  intensity = 1.0,                     -- Light brightness
  color = {r = 1, g = 0.8, b = 0.2},  -- Light color
  size = 15,                           -- Light radius
  surface = game.surfaces["nauvis"],
  time_to_live = 1200,
  tag = "area_lights"
}
```

## Render Object Management

```lua
-- Get a render object by ID
local obj = rendering.get(render_object_id)

-- Destroy a single render object
rendering.destroy(render_object_id)

-- Destroy all render objects with a specific tag
rendering.destroy_by_tag("my_mod_label")

-- Find all render objects matching criteria
local all_labels = rendering.find_all{
  tag = "zone_labels",
  surface = game.surfaces["nauvis"],
  type = "text"  -- "sprite", "text", "line", "rectangle", "circle", "polygon", "light"
}

-- Iterate and update
for _, obj in ipairs(all_labels) do
  if obj.valid then
    -- Update position, color, etc.
    obj.color = {r = 0, g = 1, b = 0}
  end
end
```

## Render Layers

Available layers (draw order, bottom to top):
- `ground` — Below everything
- `ground-corrected` — Ground with cliff correction
- `remnants` — Entity remnants
- `lower-object` — Below normal objects
- `object` — Normal objects
- `higher-object-above` — Above normal objects
- `air-object` — Air-level objects
- `air` — Highest layer
- `entity-info-icon` — Special layer for info overlays

## Performance Tips

```lua
-- 1. Always set time_to_live to prevent memory leaks
rendering.draw_text{
  text = "temp label",
  target = position,
  surface = surface,
  time_to_live = 300  -- Auto-cleanup after 5 seconds
}

-- 2. Use tags for batch management
rendering.draw_circle{
  target = pos,
  radius = 5,
  color = {r = 1, g = 0, b = 0},
  surface = surface,
  tag = "my_mod_selection"  -- Use this for bulk cleanup
}

-- Cleanup on mod disable
script.on_event(defines.events.on_mod_disabled, function(event)
  rendering.destroy_by_tag("my_mod_selection")
end)

-- 3. Limit the number of active render objects
-- Keep a counter and cap at a reasonable number
local MAX_RENDER_OBJECTS = 1000
local render_count = #rendering.find_all{tag = "my_mod_objects"}
if render_count > MAX_RENDER_OBJECTS then
  rendering.destroy_by_tag("my_mod_objects")  -- Clear all and redraw
end

-- 4. Use entity targets instead of positions for automatic following
rendering.draw_text{
  text = "My Factory",
  target = silo_entity,  -- Follows the entity automatically
  surface = surface,
  time_to_live = 600
}
```

## Common Visualization Patterns

### Entity Range Indicator
```lua
-- Draw the range circle of a roboport
local roboport = surface.find_entity("roboport", {0, 0})
if roboport then
  local prototype = roboport.prototype
  local radius = prototype.logistics_radius

  rendering.draw_circle{
    target = roboport,
    radius = radius,
    color = {r = 0, g = 1, b = 0, a = 0.3},
    filled = true,
    surface = roboport.surface,
    time_to_live = 600
  }

  rendering.draw_circle{
    target = roboport,
    radius = radius,
    color = {r = 0, g = 1, b = 0},
    filled = false,
    surface = roboport.surface,
    time_to_live = 600
  }
end
```

### Selection Box Highlight
```lua
-- Highlight a specific area
local area = {{x1, y1}, {x2, y2}}

rendering.draw_rectangle{
  left_top = area[1],
  right_bottom = area[2],
  color = {r = 1, g = 1, b = 0, a = 0.2},
  filled = true,
  surface = surface,
  time_to_live = 1800
}

rendering.draw_rectangle{
  left_top = area[1],
  right_bottom = area[2],
  color = {r = 1, g = 1, b = 0},
  filled = false,
  surface = surface,
  time_to_live = 1800
}
```

### Arrow Indicator
```lua
-- Draw an arrow from entity A to entity B
local silo = surface.find_entity("rocket-silo", {0, 0})
local pad = surface.find_entity("cargo-landing-pad", {50, 50})

if silo and pad then
  rendering.draw_line{
    from = silo.position,
    to = pad.position,
    color = {r = 1, g = 0, b = 0},
    width = 3,
    surface = surface,
    time_to_live = 600,
    tag = "route_indicator"
  }

  rendering.draw_text{
    text = "→ Rocket Route",
    target = {
      x = (silo.position.x + pad.position.x) / 2,
      y = (silo.position.y + pad.position.y) / 2 - 2
    },
    surface = surface,
    color = {r = 1, g = 0.5, b = 0},
    scale = 1.5,
    time_to_live = 600,
    tag = "route_indicator"
  }
end
```

### Player Position Marker
```lua
-- Mark player's current position
script.on_nth_tick(60, function(event)
  for _, player in pairs(game.connected_players) do
    if player.character and player.character.valid then
      rendering.draw_circle{
        target = player.position,
        radius = 1,
        color = {r = 0, g = 0, b = 1, a = 0.5},
        filled = true,
        surface = player.surface,
        time_to_live = 120,
        tag = "player_markers"
      }
    end
  end
end)
```
