local util = require("util")
-- prototypes/entities.lua
-- Entity prototypes for the crystal-tech mod

data:extend({
  {
    type = "furnace",
    name = "crystal-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "crystal-furnace"},
    max_health = 200,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    crafting_speed = 2.0,
    energy_usage = "360kW",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {pollution = 2},
    },
    crafting_categories = {"smelting"},
    result_inventory_size = 2,
    source_inventory_size = 1,
    module_slots = 2,
    allowed_effects = {"speed", "productivity", "consumption"},
    graphics_set = util.table.deepcopy(data.raw["furnace"]["steel-furnace"].graphics_set), -- Platzhalter: Grafik des Stahlofens
    working_sound = {
      sound = {filename = "__base__/sound/electric-furnace.ogg", volume = 0.5},
      audible_distance_modifier = 0.5,
      max_sounds_per_type = 3,
    },
    fast_replaceable_group = "furnace",
    -- next_upgrade nur auf ein Gebäude gleicher Größe (2×2 → 3×3 geht nicht)
  },
})
