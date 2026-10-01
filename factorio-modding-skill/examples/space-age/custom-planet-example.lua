local util = require("util")
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
local resource_autoplace = require("resource-autoplace") -- __core__/lualib, wie die Erze des Spiels

-- ===== SURFACE PROPERTY (if you want a custom one) =====
-- Note: The built-in ones are: day-night-cycle, magnetic-field, solar-power, pressure, gravity

-- ===== NEW PLANET: "Ignis" (a hot volcanic planet) =====

data:extend({
  -- Planet prototype
  {
    type = "planet",
    name = "ignis",
    icon = "__space-age__/graphics/icons/vulcanus.png",
    icon_size = 256,
    starmap_icon = "__space-age__/graphics/icons/starmap-planet-vulcanus.png",
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
    surface_properties = {
      ["day-night-cycle"] = 4 * minute,
      ["magnetic-field"] = 30,
      ["solar-power"] = 100,  -- Low solar due to volcanic ash
      pressure = 8000,  -- Very high pressure
      gravity = 25,  -- High gravity
    },
    asteroid_spawn_influence = 1.5,
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(
      asteroid_util.nauvis_vulcanus,  -- asteroid mix of the route nauvis → vulcanus
      0.9  -- position on that route (0.1 = start, 0.9 = destination), as in space-age/planet.lua
    ),
    -- Geräusche: hier von Vulcanus geliehen (eigene .ogg-Dateien gehören in sound/ der Mod)
    persistent_ambient_sounds = util.table.deepcopy(data.raw["planet"]["vulcanus"].persistent_ambient_sounds),
    surface_render_parameters = {
      fog = effects.default_fog_effect_properties(),
      day_night_cycle_color_lookup = {
        {0.00, "__space-age__/graphics/lut/vulcanus-1-day.png"},
        {0.25, "__space-age__/graphics/lut/vulcanus-1-day.png"},
        {0.50, "__space-age__/graphics/lut/vulcanus-2-night.png"},
        {0.75, "__space-age__/graphics/lut/vulcanus-2-night.png"},
      },
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
    -- Asteroiden entlang der Strecke: ohne zweiten Wert gilt die ganze Route (Space Age macht es so)
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus),
  },
})

-- ===== TECHNOLOGY: Unlock the planet =====

data:extend({
  {
    type = "technology",
    name = "ignis-space-travel",
    icon = "__space-age__/graphics/technology/vulcanus.png",
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
    icon = "__space-age__/graphics/icons/tungsten-ore.png",
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
    icon = "__space-age__/graphics/icons/tungsten-ore.png",
    icon_size = 64,
    flags = {"placeable-neutral"},
    order = "z",
    -- Lage über das Werkzeug des Spiels (legt auch die nötigen Noise-Ausdrücke an)
    autoplace = resource_autoplace.resource_autoplace_settings({
      name = "ignis-crystal",
      order = "z",
      base_density = 2,
      has_starting_area_placement = false,
      regular_rq_factor_multiplier = 1.1,
    }),
    minable = {
      mining_time = 2.0,
      result = "ignis-crystal",
    },
    -- Abbau-Stufen (Bilder je Restmenge): hier vom Wolfram-Erz geliehen
    stages = util.table.deepcopy(data.raw["resource"]["tungsten-ore"].stages),
    stage_counts = util.table.deepcopy(data.raw["resource"]["tungsten-ore"].stage_counts),
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
    category = "resource",
  },
})

-- ===== PLANET-SPECIFIC ENTITY =====

-- A machine that only works efficiently on high-pressure Ignis
data:extend({
  {
    type = "assembling-machine",
    name = "pressure-forge",
    icon = "__space-age__/graphics/icons/foundry.png",
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
    graphics_set = util.table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"].graphics_set), -- Platzhalter
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
    icon = "__space-age__/graphics/icons/foundry.png",
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
      { type = "item", name = "steel-plate", amount = 20 },
      { type = "item", name = "processing-unit", amount = 10 },
      { type = "item", name = "ignis-crystal", amount = 5 },
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
      { type = "item", name = "ignis-crystal", amount = 2 },
      { type = "item", name = "steel-plate", amount = 5 },
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
    icon = "__space-age__/graphics/icons/tungsten-plate.png",
    icon_size = 64,
    subgroup = "raw-material",
    order = "b[crystal-alloy]",
    stack_size = 50,
    weight = 400,
  },
})
