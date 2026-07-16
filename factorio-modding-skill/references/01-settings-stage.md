# Settings Stage API Reference

The settings stage runs during game startup, **before** any game or prototype data exists. Its purpose is to define mod configuration options that appear in the in-game settings menu.

## Files Executed (in order)

1. `settings.lua` — Define your settings
2. `settings-updates.lua` — Modify settings from other mods
3. `settings-final-fixes.lua` — Final corrections before prototype stage

## Available Globals

| Global | Type | Description |
|--------|------|-------------|
| `data` | LuaData | Registry for prototypes. Use `data:extend{}` |
| `mods` | table | Mapping of mod name → version string for all active mods |

## Setting Prototype Types

### double-setting (numeric)
```lua
data:extend({
  {
    type = "double-setting",
    name = "my-mod-speed-multiplier",
    setting_type = "startup",  -- "startup", "runtime", or "runtime-per-user"
    default_value = 1.5,
    minimum_value = 0.1,
    maximum_value = 10.0,
    order = "a",
  }
})
```

### int-setting
```lua
data:extend({
  {
    type = "int-setting",
    name = "my-mod-max-items",
    setting_type = "runtime",
    default_value = 100,
    minimum_value = 1,
    maximum_value = 1000,
    order = "b",
  }
})
```

### string-setting
```lua
data:extend({
  {
    type = "string-setting",
    name = "my-mod-greeting",
    setting_type = "runtime-per-user",
    default_value = "Hello!",
    allowed_values = {"Hello!", "Hi!", "Greetings!"},  -- optional dropdown
    order = "c",
  }
})
```

### bool-setting
```lua
data:extend({
  {
    type = "bool-setting",
    name = "my-mod-enable-logging",
    setting_type = "startup",
    default_value = false,
    order = "d",
  }
})
```

## Setting Types Explained

| Type | When Changeable | Scope |
|------|----------------|-------|
| `startup` | Only in main menu before loading a save | Global |
| `runtime` | During gameplay | Global (all players share) |
| `runtime-per-user` | During gameplay | Per-player |

## Reading Settings in Prototype Stage

```lua
-- data.lua
local speed = settings.startup["my-mod-speed-multiplier"].value
log("Speed multiplier is: " .. tostring(speed))
```

## Reading Settings in Runtime Stage

```lua
-- control.lua
-- Startup settings (read-only at runtime)
local speed = settings.startup["my-mod-speed-multiplier"].value

-- Runtime settings (can be changed during gameplay)
local max_items = settings.global["my-mod-max-items"].value

-- Runtime-per-user settings (per player)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  local player = game.get_player(event.player_index)
  local value = player.mod_settings["my-mod-greeting"].value
  player.print("Your greeting is now: " .. value)
end)
```

## Setting Dependencies

Check if another mod's settings exist before using them:
```lua
if settings.startup["other-mod-setting"] then
  -- other mod is present and has this setting
end
```

## Example: Complete Settings File

```lua
-- settings.lua
data:extend({
  -- Startup setting: determines how the mod behaves globally
  {
    type = "bool-setting",
    name = "my-mod-enable-hard-mode",
    setting_type = "startup",
    default_value = false,
    order = "a",
  },
  {
    type = "double-setting",
    name = "my-mod-damage-multiplier",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    maximum_value = 100.0,
    order = "b",
  },

  -- Runtime setting: can change during a game
  {
    type = "int-setting",
    name = "my-mod-alert-threshold",
    setting_type = "runtime",
    default_value = 50,
    minimum_value = 1,
    maximum_value = 500,
    order = "c",
  },

  -- Per-user setting: each player has their own
  {
    type = "string-setting",
    name = "my-mod-display-name",
    setting_type = "runtime-per-user",
    default_value = "",
    allow_blank = true,
    order = "d",
  },
})
```
