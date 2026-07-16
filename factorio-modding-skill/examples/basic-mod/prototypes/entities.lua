-- prototypes/entities.lua
-- Entity prototypes for the crystal-tech mod

data:extend({
  {
    type = "furnace",
    name = "crystal-furnace",
    icon = "__crystal-tech__/graphics/icons/crystal-furnace.png",
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
    graphics_set = {
      working_visualisations = {
        {
          always_draw = true,
          animation = {
            filename = "__crystal-tech__/graphics/entity/crystal-furnace-working.png",
            width = 87,
            height = 99,
            frame_count = 12,
            line_length = 12,
            animation_speed = 0.5,
          },
        },
      },
      animation = {
        layers = {
          {
            filename = "__crystal-tech__/graphics/entity/crystal-furnace.png",
            width = 87,
            height = 99,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__crystal-tech__/graphics/entity/crystal-furnace-shadow.png",
            width = 111,
            height = 62,
            frame_count = 1,
            shift = {0.8, 0.5},
            draw_as_shadow = true,
          },
        },
      },
      fire_glow_flicker_enabled = true,
    },
    working_sound = {
      sound = {filename = "__base__/sound/electric-furnace.ogg", volume = 0.5},
      audible_distance_modifier = 0.5,
      max_sounds_per_type = 3,
    },
    fast_replaceable_group = "furnace",
    next_upgrade = "electric-furnace",
  },
})
