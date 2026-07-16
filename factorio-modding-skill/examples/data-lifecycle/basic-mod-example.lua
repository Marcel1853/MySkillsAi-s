-- ============================================================
-- EXAMPLE: Basic Mod Structure (data lifecycle walkthrough)
-- ============================================================
-- This shows the complete file structure for a simple Factorio 2.1 mod
-- and how data flows through the three stages.
--
-- Directory structure:
--   basic-mod/
--   ├── info.json
--   ├── settings.lua
--   ├── data.lua
--   ├── data-updates.lua
--   ├── control.lua
--   └── locale/en/basic-mod.cfg
-- ============================================================

-- ============================================================
-- info.json (not Lua, but shown for completeness)
-- ============================================================
--[[
{
  "name": "basic-mod",
  "version": "1.1.0",
  "title": "Basic Mod Example",
  "author": "Your Name",
  "factorio_version": "2.1",
  "dependencies": ["base >= 2.1", "+ space-age"],
  "description": "A simple mod demonstrating the Factorio 2.1 data lifecycle."
}
]]

-- ============================================================
-- settings.lua — Stage 1: Settings
-- ============================================================
-- Runs at game startup. Define configuration options here.

data:extend({
  -- Startup setting (changeable only in main menu)
  {
    type = "bool-setting",
    name = "basic-mod-enable-special-machine",
    setting_type = "startup",
    default_value = true,
    order = "a",
  },

  -- Runtime setting (changeable during gameplay)
  {
    type = "int-setting",
    name = "basic-mod-machine-speed",
    setting_type = "runtime",
    default_value = 2,
    minimum_value = 1,
    maximum_value = 10,
    order = "b",
  },
})

-- ============================================================
-- data.lua — Stage 2: Prototypes
-- ============================================================
-- Runs after settings. Define items, recipes, entities, etc.

-- Read startup settings
local enable_machine = settings.startup["basic-mod-enable-special-machine"].value

-- Add a custom item
data:extend({
  {
    type = "item",
    name = "basic-mod-gear",
    icon = "__basic-mod__/graphics/icons/gear.png",
    icon_size = 64,
    subgroup = "intermediate-product",
    order = "z[basic-mod-gear]",
    stack_size = 100,
    weight = 200,  -- grams (2.1)
  },
})

-- Add a recipe (conditionally)
if enable_machine then
  data:extend({
    {
      type = "recipe",
      name = "basic-mod-gear-recipe",
      enabled = false,  -- unlocked by technology
      energy_required = 2.0,
      categories = {"crafting"},
      ingredients = {
        {"iron-plate", 2},
        {"copper-plate", 1},
      },
      results = {
        {type = "item", name = "basic-mod-gear", amount = 1},
      },
      allow_productivity = true,
    },
    {
      type = "technology",
      name = "basic-mod-gear-tech",
      icon = "__basic-mod__/graphics/technology/gear-tech.png",
      icon_size = 256,
      effects = {
        {type = "unlock-recipe", recipe = "basic-mod-gear-recipe"},
      },
      prerequisites = {"automation"},
      unit = {
        count = 30,
        ingredients = {{"automation-science-pack", 1}},
        time = 15,
      },
      order = "z[basic-mod]",
    },
  })
end

-- Add a custom assembling machine (conditionally)
if enable_machine then
  data:extend({
    {
      type = "assembling-machine",
      name = "basic-mod-super-assembler",
      icon = "__basic-mod__/graphics/icons/super-assembler.png",
      icon_size = 64,
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      minable = {mining_time = 1.0, result = "basic-mod-super-assembler"},
      max_health = 500,
      corpse = "big-remnants",
      crafting_speed = 3.0,  -- 3x normal speed!
      crafting_categories = {"crafting", "advanced-crafting", "chemistry"},
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = -1},  -- Cleans pollution!
      },
      energy_usage = "300kW",
      module_slots = 6,
      allowed_effects = {"speed", "productivity", "consumption", "pollution"},
      collision_box = {{-1.9, -1.9}, {1.9, 1.9}},
      selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
      graphics_set = {
        animation = {
          filename = "__basic-mod__/graphics/entity/super-assembler.png",
          width = 128,
          height = 128,
          frame_count = 1,
          direction_count = 4,
        },
      },
      fast_replaceable_group = "assembling-machine",
      next_upgrade = nil,
    },
    {
      type = "item",
      name = "basic-mod-super-assembler",
      icon = "__basic-mod__/graphics/icons/super-assembler.png",
      icon_size = 64,
      subgroup = "production-machine",
      order = "z[basic-mod-super-assembler]",
      place_result = "basic-mod-super-assembler",
      stack_size = 10,
    },
    {
      type = "recipe",
      name = "basic-mod-super-assembler-recipe",
      enabled = false,
      energy_required = 10.0,
      categories = {"crafting"},
      ingredients = {
        {"assembling-machine-3", 1},
        {"basic-mod-gear", 10},
        {"processing-unit", 5},
      },
      results = {
        {type = "item", name = "basic-mod-super-assembler", amount = 1},
      },
    },
  })
end

-- ============================================================
-- data-updates.lua — Stage 2b: Modify existing prototypes
-- ============================================================
-- Modify prototypes defined by base game or other mods

-- Increase assembler 3 speed based on our runtime setting
local speed_mult = settings.global and settings.global["basic-mod-machine-speed"]
if speed_mult then
  if data.raw["assembling-machine"]["assembling-machine-3"] then
    local base_speed = data.raw["assembling-machine"]["assembling-machine-3"].crafting_speed
    data.raw["assembling-machine"]["assembling-machine-3"].crafting_speed = base_speed * speed_mult.value
  end
end

-- Add our gear as an ingredient to an existing recipe
if data.raw.recipe["electronic-circuit"] then
  -- table.insert(data.raw.recipe["electronic-circuit"].ingredients, {"basic-mod-gear", 1})
  -- (Commented out — just showing the pattern)
end

-- ============================================================
-- control.lua — Stage 3: Runtime
-- ============================================================

-- Initialize storage
script.on_init(function()
  storage.counter = storage.counter or 0
  storage.machines_built = storage.machines_built or {}
end)

-- Track when our super assembler is built
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  if entity.name == "basic-mod-super-assembler" then
    storage.counter = storage.counter + 1
    table.insert(storage.machines_built, entity.unit_number)
    
    local player = game.get_player(event.player_index)
    if player then
      player.print("Super Assembler built! Total: " .. storage.counter)
    end
  end
end, {{filter = "name", name = "basic-mod-super-assembler"}})

-- Print a message every 60 seconds
script.on_nth_tick(3600, function(event)
  if storage.counter > 0 then
    for _, player in pairs(game.connected_players) do
      player.print("You have built " .. storage.counter .. " super assemblers.")
    end
  end
end)

-- Handle configuration changes (mod updates)
script.on_configuration_changed(function(event)
  if event.mod_changes["basic-mod"] then
    local old = event.mod_changes["basic-mod"].old_version
    if old == nil then
      game.print("Basic Mod was added to your save!")
    else
      game.print("Basic Mod updated from " .. old .. " to " .. event.mod_changes["basic-mod"].new_version)
    end
  end
end)

-- ============================================================
-- locale/en/basic-mod.cfg — Localisation
-- ============================================================
--[[
[item-name]
basic-mod-gear=Special Gear

[item-description]
basic-mod-gear=A special gear used in advanced crafting.

[recipe-name]
basic-mod-gear-recipe=Special Gear Recipe

[entity-name]
basic-mod-super-assembler=Super Assembler

[entity-description]
basic-mod-super-assembler=An extremely fast assembling machine that also cleans pollution.

[technology-name]
basic-mod-gear-tech=Special Gear Manufacturing

[mod-name]
basic-mod=Basic Mod Example

[mod-description]
basic-mod=A simple mod demonstrating the Factorio 2.1 data lifecycle.
]]
