-- ============================================================
-- EXAMPLE: Space Age — Custom Planet with Space Location
-- ============================================================
-- Demonstrates creating a new planet, space connections,
-- surface properties, and asteroid spawning.
--
-- Requires: space-age mod as dependency
-- ============================================================

local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")
local effects = require("__core__.lualib.surface-render-parameter-effects")
local planet_map_gen = require("__space-age__.prototypes.planet.planet-map-gen")

-- ===== SURFACE PROPERTY (if you want a custom one) =====
-- Note: The built-in ones are: day-night-cycle, magnetic-field, solar-power, pressure, gravity

-- ===== NEW PLANET: "Ignis" (a hot volcanic planet) =====

data:extend({
  -- Planet prototype
  {
    type = "planet",
    name = "ignis",
    icon = "__space-planet-example__/graphics/icons/ignis.png",
    icon_size = 256,
    starmap_icon = "__space-planet-example__/graphics/icons/starmap-ignis.png",
    starmap_icon_size = 512,
    gravity_pull = 15,
    distance = 25,  -- further from nauvis than vulcanus
    orientation = 0.65,
    magnitude = 1.2,
    order = "e[ignis]",
    subgroup = "planets",
    map_gen_settings = planet_map_gen.vulcanus(),  -- reuse vulcanus map gen as base
    pollutant_type = nil,
    solar_power_in_space = 200,  -- Less solar power due to distance
    platform_procession_set = {
      arrival = {"planet-to-platform-b"},
      departure = {"platform-to-planet-a"},
    },
    planet_procession_set = {
      arrival = {"platform-to-planet-b"},
      departure = {"planet-to-platform-a"},
    },
    -- Procession catalogue determines visual appearance during travel
    -- Use a custom one or reuse an existing
    procession_graphic_catalogue = "ignis-catalogue",
    surface_properties = {
      ["day-night-cycle"] = 4 * minute,
      ["magnetic-field"] = 30,
      ["solar-power"] = 100,  -- Low solar due to volcanic ash
      pressure = 8000,  -- Very high pressure
      gravity = 25,  -- High gravity
    },
    asteroid_spawn_influence = 1.5,
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(
      asteroid_util.vulcanus,  -- base on vulcanus asteroid types
      0.8
    ),
    persistent_ambient_sounds = {
      base_ambience = {filename = "__space-planet-example__/sound/ignis-wind.ogg", volume = 0.8},
      wind = {filename = "__space-planet-example__/sound/ignis-rumble.ogg", volume = 0.9},
      crossfade = {
        order = {"wind", "base_ambience"},
        curve_type = "cosine",
        from = {control = 0.35, volume_percentage = 0.0},
        to = {control = 2, volume_percentage = 100.0},
      },
      semi_persistent = {
        {
          sound = {variations = {
            {filename = "__space-planet-example__/sound/eruption-1.ogg", volume = 0.4},
            {filename = "__space-planet-example__/sound/eruption-2.ogg", volume = 0.5},
          }},
          delay_mean_seconds = 20,
          delay_variance_seconds = 10,
        },
      },
    },
    surface_render_parameters = {
      fog = effects.default_fog_effect_properties(),
      day_night_cycle_color_lookup = {
        {0.00, "__space-planet-example__/graphics/lut/ignis-day.png"},
        {0.25, "__space-planet-example__/graphics/lut/ignis-sunset.png"},
        {0.50, "__space-planet-example__/graphics/lut/ignis-night.png"},
        {0.75, "__space-planet-example__/graphics/lut/ignis-night.png"},
      },
    },
  },

  -- Procession catalogue (visual effects during travel)
  {
    type = "procession-catalogue",
    name = "ignis-catalogue",
    space_catalogue = {
      procession_graphic = "__space-planet-example__/graphics/entity/space-ignis.png",
    },
  },
})

-- ===== SPACE CONNECTION: Nauvis → Ignis =====

data:extend({
  {
    type = "space-connection",
    name = "nauvis-to-ignis",
    from = "nauvis",
    to = "ignis",
    order = "c",
    asteroid_spawn_definitions = {
      {probability = 0.15, asteroid = "asteroid-chunk-iron"},
      {probability = 0.15, asteroid = "asteroid-chunk-copper"},
      {probability = 0.10, asteroid = "asteroid-chunk-stone"},
      {probability = 0.10, asteroid = "asteroid-chunk-carbon"},
      {probability = 0.05, asteroid = "asteroid-chunk-ice"},
    },
  },
})

-- ===== TECHNOLOGY: Unlock the planet =====

data:extend({
  {
    type = "technology",
    name = "ignis-space-travel",
    icon = "__space-planet-example__/graphics/technology/ignis-travel.png",
    icon_size = 256,
    effects = {
      {type = "unlock-space-location", space_location = "ignis", use_icon_overlay = true},
    },
    prerequisites = {"rocket-turret", "rocket-fuel"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 60,
    },
    order = "z[ignis-travel]",
  },
})

-- ===== PLANET-SPECIFIC RESOURCES =====

-- A unique resource found on Ignis
data:extend({
  {
    type = "item",
    name = "ignis-crystal",
    icon = "__space-planet-example__/graphics/icons/ignis-crystal.png",
    icon_size = 64,
    subgroup = "raw-resource",
    order = "a[ignis-crystal]",
    stack_size = 50,
    weight = 300,
    default_import_location = "ignis",  -- Space Age: shows where it comes from
  },

  {
    type = "resource",
    name = "ignis-crystal",
    icon = "__space-planet-example__/graphics/icons/ignis-crystal-resource.png",
    icon_size = 64,
    flags = {"placeable-neutral"},
    order = "z",
    autoplace = {
      probability_expression = "random_penalty_at(ignis_crystal) * 0.001",
      richness_expression = "random_penalty_at(ignis_crystal_richness) * 500",
    },
    minable = {
      mining_time = 2.0,
      result = "ignis-crystal",
      minable_sound = {filename = "__space-planet-example__/sound/crystal-mine.ogg"},
    },
    stage_counts = {0},
    map_color = {r = 0.9, g = 0.2, b = 0.3},
    mining_particle = "stone-particle",
    mining_sound = {
      filename = "__base__/sound/deconstruct-bricks.ogg",
      volume = 0.4,
    },
    mined_sound = {
      filename = "__base__/sound/deconstruct-bricks.ogg",
      volume = 0.4,
    },
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    autoplace_control_name = "ignis-crystal",
  },

  -- Autoplace control for map generation
  {
    type = "autoplace-control",
    name = "ignis-crystal",
    localised_name = {"autoplace-control-name.ignis-crystal"},
    richness = true,
    order = "z-d",
    categories = {"resource"},
  },
})

-- ===== PLANET-SPECIFIC ENTITY =====

-- A machine that only works efficiently on high-pressure Ignis
data:extend({
  {
    type = "assembling-machine",
    name = "pressure-forge",
    icon = "__space-planet-example__/graphics/icons/pressure-forge.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "pressure-forge"},
    max_health = 400,
    corpse = "big-remnants",
    crafting_speed = 1.0,  -- base speed (boosted by pressure on Ignis)
    crafting_categories = {"metallurgy", "chemistry"},
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
    },
    energy_usage = "500kW",
    module_slots = 4,
    allowed_effects = {"speed", "productivity", "consumption"},
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    graphics_set = {
      animation = {
        filename = "__space-planet-example__/graphics/entity/pressure-forge.png",
        width = 128,
        height = 128,
        frame_count = 32,
        line_length = 8,
      },
    },
    -- Special: bonus on high-pressure surfaces
    surface_conditions = {
      {
        property = "pressure",
        min = 5000,  -- Only works above 5000 hPa
        max = 15000,
      },
    },
  },
  {
    type = "item",
    name = "pressure-forge",
    icon = "__space-planet-example__/graphics/icons/pressure-forge.png",
    icon_size = 64,
    subgroup = "production-machine",
    order = "z[pressure-forge]",
    place_result = "pressure-forge",
    stack_size = 10,
  },
  {
    type = "recipe",
    name = "pressure-forge-recipe",
    enabled = false,
    energy_required = 15.0,
    categories = {"crafting"},
    ingredients = {
      {"steel-plate", 20},
      {"processing-unit", 10},
      {"ignis-crystal", 5},
    },
    results = {
      {type = "item", name = "pressure-forge", amount = 1},
    },
  },
})

-- ===== ITEM RECIPE USING IGNIS CRYSTAL =====

data:extend({
  {
    type = "recipe",
    name = "crystal-alloy",
    categories = {"metallurgy"},
    enabled = false,
    energy_required = 8.0,
    ingredients = {
      {"ignis-crystal", 2},
      {"steel-plate", 5},
    },
    results = {
      {type = "item", name = "crystal-alloy", amount = 1},
    },
    allow_productivity = true,
    main_product = "crystal-alloy",
    surface_conditions = {
      {property = "pressure", min = 5000},  -- Must be on a high-pressure surface
    },
  },
  {
    type = "item",
    name = "crystal-alloy",
    icon = "__space-planet-example__/graphics/icons/crystal-alloy.png",
    icon_size = 64,
    subgroup = "raw-material",
    order = "b[crystal-alloy]",
    stack_size = 50,
    weight = 400,
  },
})
