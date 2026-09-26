# GUI API Reference (Factorio 2.1)

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle GUI-Elemente IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 (experimental) ändert sich wöchentlich. Wichtige 2.1-Neuerungen: `LuaGuiElement` Typ `"inventory"`, `on_gui_inventory_action` Event, neue `choose-elem-button` Typen (`quality`, `shortcut`, `space-connection`, `surface`, `virtual-signal`, `airborne-pollutant`, `ammo-category`).

## Table of Contents

- [GUI Roots](#gui-roots)
- [Creating GUI Elements](#creating-gui-elements)
- [GUI Element Types](#gui-element-types)
  - [Flow layout container](#flow-layout-container)
  - [Frame window/container](#frame-window/container)
  - [Label text](#label-text)
  - [Button](#button)
  - [Sprite Button](#sprite-button)
  - [Sprite](#sprite)
  - [Textfield single-line input](#textfield-single-line-input)
  - [Textfield with Icon Selector 2.0 addition](#textfield-with-icon-selector-2.0-addition)
  - [Text Box multi-line input](#text-box-multi-line-input)
  - [Text Box with Icon Selector 2.0 addition](#text-box-with-icon-selector-2.0-addition)
  - [Drop-down](#drop-down)
  - [List Box](#list-box)
  - [Check Box](#check-box)
  - [Slider](#slider)
  - [Progress Bar](#progress-bar)
  - [Table grid layout](#table-grid-layout)
  - [Scroll Pane](#scroll-pane)
  - [Tabbed Pane](#tabbed-pane)
  - [Switch](#switch)
  - [Camera entity preview](#camera-entity-preview)
  - [Choose Elem Button](#choose-elem-button)
  - [Line](#line)
  - [Empty Widget spacer](#empty-widget-spacer)
  - [Entity Preview](#entity-preview)
- [GUI Events](#gui-events)
- [GUI Styles](#gui-styles)
- [Complete GUI Window Example](#complete-gui-window-example)


- [GUI Roots](#)
- [Creating GUI Elements](#)
- [GUI Element Types](#)
- [GUI Events](#)
- [GUI Styles](#)
- [Complete GUI Window Example](#)



Factorio's GUI system allows mods to create custom interfaces. All GUI operations happen through `LuaGuiElement`.

## GUI Roots

Every player has built-in GUI roots:

```lua
player.gui.screen    -- fullscreen overlays (always visible)
player.gui.top       -- top bar (next to the quickbar)
player.gui.left      -- left side panel
player.gui.center    -- main center area (used for screens like research)
player.gui.relative  -- anchored relative to other elements
```

## Creating GUI Elements

```lua
-- Add to the top bar
player.gui.top.add{
  type = "sprite-button",
  name = "my-mod-button",
  sprite = "utility/build",
  tooltip = {"my-mod-tooltip"},
  style = "slot_button",
}

-- Add a frame (window-like container)
local frame = player.gui.screen.add{
  type = "frame",
  name = "my-mod-frame",
  direction = "vertical",
}

frame.auto_center = true
frame.style.minimal_width = 400
frame.style.maximal_width = 400

-- Add a titlebar
frame.add{
  type = "flow",
  name = "titlebar",
  style = "frame_header_flow",
}
frame.titlebar.add{
  type = "label",
  name = "title",
  caption = {"my-mod-frame-title"},
  style = "frame_title",
  ignored_by_interaction = true,
}
frame.titlebar.add{
  type = "empty-widget",
  style = "draggable_space",
  ignored_by_interaction = true,
  style_modifiers = {horizontally_stretchable = true},
}
frame.titlebar.add{
  type = "sprite-button",
  name = "close_button",
  sprite = "utility/close",
  style = "frame_action_button",
  mouse_button_filter = {"left"},
}
```

## GUI Element Types

### Flow (layout container)

```lua
local flow = parent.add{
  type = "flow",
  name = "my-flow",
  direction = "vertical",  -- or "horizontal"
}
flow.style.vertical_spacing = 8
flow.style.horizontal_spacing = 8
```

### Frame (window/container)

```lua
local frame = parent.add{
  type = "frame",
  name = "my-frame",
  direction = "vertical",
  style = "inside_shallow_frame",  -- or "frame", "inside_deep_frame", "bordered_frame"
}
frame.style.horizontally_stretchable = true
frame.style.vertically_stretchable = true
```

### Label (text)

```lua
local label = parent.add{
  type = "label",
  name = "my-label",
  caption = {"my-mod-label-text"},  -- uses locale, or just a string
}
label.style.font_color = {r = 1, g = 1, b = 1}
label.style.font = "default-font"
```

### Button

```lua
local button = parent.add{
  type = "button",
  name = "my-button",
  caption = {"my-mod-button-caption"},
  style = "button",  -- "button", "tool_button", "red_button", "green_button", etc.
  enabled = true,
  tooltip = {"my-mod-tooltip"},
}
```

### Sprite Button

```lua
local sprite_btn = parent.add{
  type = "sprite-button",
  name = "my-sprite-button",
  sprite = "utility/build",
  style = "slot_button",  -- "slot_button", "tool_button", etc.
  number = 5,  -- optional number overlay (like item counts)
  enabled = true,
}
```

### Sprite

```lua
local sprite = parent.add{
  type = "sprite",
  name = "my-sprite",
  sprite = "my-mod/my-item-icon",
  resize_to_sprite = true,
}
```

### Textfield (single-line input)

```lua
local textfield = parent.add{
  type = "textfield",
  name = "my-textfield",
  text = "default value",
  numeric = false,  -- restrict to numbers
  allow_negative = true,  -- only if numeric
  clear_and_focus_on_right_click = true,
}
textfield.style.horizontally_stretchable = true
textfield.style.maximal_width = 200
```

### Textfield with Icon Selector (2.0 addition)

```lua
local textfield = parent.add{
  type = "textfield",
  name = "my-icon-textfield",
  text = "",
  icon_selector = "item",  -- "item", "entity", "recipe", "technology", "signal", "sprite", "equipment"
}
```

### Text Box (multi-line input)

```lua
local textbox = parent.add{
  type = "text-box",
  name = "my-textbox",
  text = "multi-line\ntext\ngoes here",
  word_wrap = true,
}
textbox.style.minimal_height = 200
textbox.style.horizontally_stretchable = true
```

### Text Box with Icon Selector (2.0 addition)

```lua
local textbox = parent.add{
  type = "text-box",
  name = "my-icon-textbox",
  icon_selector = "item",  -- same options as textfield icon_selector
}
```

### Drop-down

```lua
local dropdown = parent.add{
  type = "drop-down",
  name = "my-dropdown",
  items = {"Option A", "Option B", "Option C"},
  selected_index = 1,
}
```

### List Box

```lua
local listbox = parent.add{
  type = "list-box",
  name = "my-listbox",
  items = {"Item 1", "Item 2", "Item 3"},
  item_count = 5,  -- visible items
}
```

### Check Box

```lua
local checkbox = parent.add{
  type = "checkbox",
  name = "my-checkbox",
  caption = {"my-mod-checkbox-label"},
  state = false,
}
```

### Slider

```lua
local slider = parent.add{
  type = "slider",
  name = "my-slider",
  minimum_value = 0,
  maximum_value = 100,
  value = 50,
  value_step = 1,
}
```

### Progress Bar

```lua
local progress = parent.add{
  type = "progressbar",
  name = "my-progress",
  value = 0.5,  -- 0.0 to 1.0
}
```

### Table (grid layout)

```lua
local table = parent.add{
  type = "table",
  name = "my-table",
  column_count = 3,
  style = "slot_table",  -- or just default
}

-- Add cells
table.add{type = "sprite", sprite = "item/iron-plate"}
table.add{type = "label", caption = "Iron Plate"}
table.add{type = "label", caption = "100"}
```

### Scroll Pane

```lua
local scroll = parent.add{
  type = "scroll-pane",
  name = "my-scroll",
  vertical_scroll_policy = "auto",
  horizontal_scroll_policy = "never",
}
scroll.style.maximal_height = 300
scroll.style.horizontally_stretchable = true
```

### Tabbed Pane

```lua
local tabs = parent.add{
  type = "tabbed-pane",
  name = "my-tabs",
}

local tab1 = tabs.add{type = "tab", name = "tab1", caption = "Tab 1"}
local tab2 = tabs.add{type = "tab", name = "tab2", caption = "Tab 2"}

tabs.add_tab(tab1, "content_for_tab1")
tabs.add_tab(tab2, "content_for_tab2")
```

### Switch

```lua
local switch = parent.add{
  type = "switch",
  name = "my-switch",
  switch_state = "left",  -- "left", "right", or "none"
  left_label_caption = "Off",
  right_label_caption = "On",
}
```

### Camera (entity preview)

```lua
local camera = parent.add{
  type = "camera",
  name = "my-camera",
  position = {x = 0, y = 0},
  surface_index = 1,
  zoom = 1.0,
}
camera.style.minimal_width = 200
camera.style.minimal_height = 200

-- Einem Objekt folgen (checked in-game, 2.1): `entity` ist schreibbar, die Kamera fährt mit.
-- Bei einer anderen Oberfläche zuerst surface_index setzen.
camera.surface_index = train.front_stock.surface_index
camera.entity = train.front_stock
```

Schwebender Text über einem Objekt, das eine Kamera im Fenster zeigt: `rendering.draw_text{ …,
target = { entity = e, offset = { 0, -3 } }, scale_with_zoom = false }`. Mit `scale_with_zoom =
true` behält der Text seine Bildschirmgröße – in einer kleinen, weit herausgezoomten Kamera
(zoom 0.35) verdeckt er dann das ganze Bild. Den Text später ändern: `obj.text = { "key", … }`,
`obj.color = { … }` (LuaRenderObject, beides schreibbar).

### Choose Elem Button

```lua
local choose = parent.add{
  type = "choose-elem-button",
  name = "my-choose",
  elem_type = "item",  -- "item", "fluid", "entity", "tile", "recipe", "technology", "signal", "virtual-signal", "decorative", "achievement"
}
```

### Line

```lua
parent.add{
  type = "line",
  name = "my-line",
  direction = "horizontal",
}
```

### Empty Widget (spacer)

```lua
parent.add{
  type = "empty-widget",
  name = "my-spacer",
  style_modifiers = {horizontally_stretchable = true},
}
```

### Entity Preview

```lua
parent.add{
  type = "entity-preview",
  name = "my-entity-preview",
  style = "wide_entity_button",
}
-- Then set the entity to preview:
element.set_entity("assembling-machine-3")
```

### Inventory (2.1+)

```lua
parent.add{
  type = "inventory",
  name = "my-inventory-gui",
  -- New in 2.1: interactive inventory GUI element
  -- See LuaGuiElement inventory-related properties:
  -- inventory, slots_per_row, empty_slot_info,
  -- handle_cursor_transfer, handle_cursor_split,
  -- handle_open_item, handle_open_mod_item,
  -- handle_send_stack_to_trash, handle_send_stacks_to_trash
}
```

> **2.1+ Note:** The `"inventory"` GUI element type and `on_gui_inventory_action` event are new in Factorio 2.1. See [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/) for full property and event details.

---

## Erklärfenster für Szenarien (Vorlage)

Fertige Vorlage: **`scripts/templates/explain-panel/`** (Lua-Datei + Texte DE/EN). Ein Fenster, das
Spielern in einem Szenario oder Tutorial erklärt, was gerade passiert:

- Titelleiste zum Verschieben (`drag_target`) und Knopf zum Einklappen (gemerkt je Spieler)
- Einleitung, Kopfzeile mit optionalem eigenem Knopf (z. B. Modus umschalten)
- Schritte: erledigte mit Häkchen, der aktuelle hervorgehoben, kommende grau
- Kamera, die einem Objekt folgt (meist einem Zug)
- große Zeile (z. B. aktuelle Menge) und Notiz (z. B. Zähler)

```lua
local Explain = require("__my-mod__/scripts/lib/explain-panel")

Explain.create(player, { name = "my_demo", title = { "my-demo.title" }, intro = { "my-demo.intro" },
  button = { action = "mode", tooltip = { "my-demo.mode-tooltip" } } })

-- einmal pro Sekunde (on_nth_tick(60)), nur Texte:
Explain.update(player, "my_demo", {
  headline = { "my-demo.round", round },
  steps = { { "my-demo.step-1" }, { "my-demo.step-2" }, { "my-demo.step-3" } },
  current = step,
  follow = locomotive,
  big = { "my-demo.cargo", amount },
  note = { "my-demo.stats", trips },
})

script.on_event(defines.events.on_gui_click, function(event)
  if Explain.on_click(event) == "mode" then --[[ eigenen Knopf behandeln ]] end
end)
```

Wie es sich bewährt hat (Szenario „UTL-Nachladen“ in Unified Train Logistics): Ablauf als
Zustandsautomat im Szenario (`storage.phase`, `storage.step`), das Fenster nur als Anzeige
davon. Dazu schwebende Texte in der Welt über den beteiligten Objekten und Anzeigefelder mit
Erklärung an den Stationen – dann sieht man, was passiert, statt es nur im Chat zu lesen.

**Headless lässt sich das Fenster nicht testen** (kein Spieler, kein Fenster). Den Ablauf dahinter
schon: Zustand per `/c log(serpent.line(storage.…))` über stdin abfragen.

## GUI Events

```lua
-- Button clicked
script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "my-mod-button" then
    game.print("Button clicked!")
  end
end)

-- Textfield text changed
script.on_event(defines.events.on_gui_text_changed, function(event)
  local text = event.element.text
  game.print("Text changed to: " .. text)
end)

-- Selection state changed (checkbox, switch, slider, etc.)
script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  local element = event.element
  if element.type == "checkbox" then
    game.print("Checkbox is " .. (element.state and "checked" or "unchecked"))
  end
end)

-- Dropdown selection changed
script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  if event.element.type == "drop-down" then
    game.print("Selected: " .. event.element.get_item(event.element.selected_index))
  end
end)

-- Tab changed (on_gui_selected_tab_changed; event.element = the tabbed-pane)
script.on_event(defines.events.on_gui_selected_tab_changed, function(event)
  game.print("Selected tab index: " .. event.element.selected_tab_index)
end)

-- Location changed (camera, scroll-pane)
script.on_event(defines.events.on_gui_location_changed, function(event)
  game.print("Scrolled or moved camera")
end)

-- Elem changed (choose-elem-button)
script.on_event(defines.events.on_gui_elem_changed, function(event)
  local elem = event.element.elem_value
  if elem then
    game.print("Selected: " .. elem.name)
  end
end)

-- Confirmed (textfield enter key)
script.on_event(defines.events.on_gui_confirmed, function(event)
  game.print("Textfield confirmed: " .. event.element.text)
end)

-- Checked state changed (checkbox, switch)
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  game.print("Checked: " .. tostring(event.element.state))
end)

-- Value changed (slider, progressbar)
script.on_event(defines.events.on_gui_value_changed, function(event)
  game.print("Value: " .. event.element.slider_value)
end)

-- Opened/closed (custom GUIs, not standard factorio GUIs)
-- Use script.on_event("on_gui_opened") and "on_gui_closed" for custom dialogs
```

---

## GUI Styles

Factorio provides many built-in styles (set them with `style = "…"` when adding elements). Note: `game.player` only exists in console commands – in mod code use `game.get_player(event.player_index)`:

```lua
-- Common styles:
"frame"                -- standard frame
"inside_shallow_frame" -- recessed frame
"inside_deep_frame"    -- deeply recessed frame
"bordered_frame"       -- framed border
"slot_button"          -- inventory-style button
"tool_button"          -- toolbar button
"button"               -- standard button
"red_button"           -- danger/destructive action
"green_button"         -- positive action
"label"                -- text label
"bold_label"           -- bold text
"subtitle_label"       -- larger label
"caption_label"        -- smaller label
"heading_1_label"      -- large heading
"heading_2_label"      -- medium heading
"description_label"    -- descriptive text
"frame_title"          -- window title text
"frame_header_flow"    -- titlebar flow
"scroll_pane"          -- scrollable area
"slot_table"           -- table styled like slots
"taller_list_box"      -- taller list box
"wide_entity_button"   -- entity preview button
```

Apply styles:
```lua
element.style = "my-custom-style"
element.style.font_color = {r = 1, g = 0, b = 0}
element.style.font = "default-large-bold"
element.style.top_padding = 10
element.style.horizontally_stretchable = true
element.style.vertically_stretchable = true
element.style.minimal_width = 200
element.style.maximal_width = 400
element.style.minimal_height = 50
```

---

## Complete GUI Window Example

```lua
-- control.lua

local function open_my_gui(player)
  -- Remove existing GUI if present
  if player.gui.screen["my-mod-window"] then
    player.gui.screen["my-mod-window"].destroy()
  end

  -- Create main frame
  local frame = player.gui.screen.add{
    type = "frame",
    name = "my-mod-window",
    direction = "vertical",
  }
  frame.auto_center = true
  frame.style.minimal_width = 400

  -- Title bar
  local title_flow = frame.add{
    type = "flow",
    name = "titlebar",
    style = "frame_header_flow",
  }
  title_flow.add{
    type = "label",
    name = "title",
    caption = {"my-mod-window-title", player.name},
    style = "frame_title",
  }
  title_flow.add{
    type = "empty-widget",
    style = "draggable_space",
    ignored_by_interaction = true,
    style_modifiers = {horizontally_stretchable = true},
  }
  local close_btn = title_flow.add{
    type = "sprite-button",
    name = "close",
    sprite = "utility/close",
    style = "frame_action_button",
  }

  -- Content area
  local content = frame.add{
    type = "flow",
    name = "content",
    direction = "vertical",
  }
  content.style.padding = 12
  content.style.vertical_spacing = 8

  -- Info label
  content.add{
    type = "label",
    name = "info",
    caption = "This is a mod window!",
  }

  -- Input field
  content.add{
    type = "textfield",
    name = "input_field",
    text = "Enter text here",
  }

  -- Action buttons
  local btn_flow = content.add{
    type = "flow",
    name = "buttons",
    direction = "horizontal",
  }
  btn_flow.style.horizontal_spacing = 8

  btn_flow.add{
    type = "button",
    name = "action_1",
    caption = "Do Thing 1",
    style = "green_button",
  }
  btn_flow.add{
    type = "button",
    name = "action_2",
    caption = "Do Thing 2",
    style = "button",
  }
end

-- Event handlers
script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  local player = game.get_player(event.player_index)
  if not player then return end

  if element.name == "close" then
    if element.parent then
      element.parent.destroy()
    end
  elseif element.name == "action_1" then
    player.print("Action 1 performed!")
  elseif element.name == "action_2" then
    player.print("Action 2 performed!")
  end
end)

-- Open GUI when player joins
script.on_event(defines.events.on_player_joined_game, function(event)
  -- Don't auto-open, just prepare
end)

-- Add a button to the top bar to open the GUI
script.on_init(function()
  for _, player in pairs(game.players) do
    player.gui.top.add{
      type = "sprite-button",
      name = "my-mod-open-gui",
      sprite = "utility/build",
      tooltip = "Open My Mod GUI",
    }
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "my-mod-open-gui" then
    local player = game.get_player(event.player_index)
    if player then
      open_my_gui(player)
    end
  end
end)

-- Handle new players
script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  if player then
    player.gui.top.add{
      type = "sprite-button",
      name = "my-mod-open-gui",
      sprite = "utility/build",
      tooltip = "Open My Mod GUI",
    }
  end
end)
```
