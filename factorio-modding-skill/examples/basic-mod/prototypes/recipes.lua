-- prototypes/recipes.lua
-- Recipe prototypes for the crystal-tech mod

data:extend({
  -- Smelt ore into refined crystal
  {
    type = "recipe",
    name = "refine-crystal",
    categories = {"smelting"},
    enabled = true,
    energy_required = 3.0,
    ingredients = {
      {type = "item", name = "crystal-ore", amount = 2},
    },
    results = {
      {type = "item", name = "refined-crystal", amount = 1},
    },
    allow_productivity = true,
    main_product = "refined-crystal",
  },

  -- Craft the processor
  {
    type = "recipe",
    name = "crystal-processor-recipe",
    categories = {"crafting-with-fluid"}, -- Wasser als Zutat: nur Maschinen mit Rohranschluss
    enabled = false,
    energy_required = 5.0,
    ingredients = {
      { type = "item", name = "refined-crystal", amount = 5 },
      { type = "item", name = "copper-cable", amount = 10 },
      {type = "fluid", name = "water", amount = 20},
    },
    results = {
      {type = "item", name = "crystal-processor", amount = 1},
    },
    allow_productivity = true,
  },

  -- Smelt ore into fluid
  {
    type = "recipe",
    name = "melt-crystal",
    categories = {"chemistry"},
    enabled = false,
    energy_required = 4.0,
    ingredients = {
      { type = "item", name = "crystal-ore", amount = 1 },
    },
    results = {
      {type = "fluid", name = "molten-crystal", amount = 50},
    },
    allow_productivity = false,
    crafting_machine_tint = {
      primary = {r = 0.8, g = 0.2, b = 1.0, a = 1.0},
    },
  },

  -- Craft the furnace
  {
    type = "recipe",
    name = "crystal-furnace-recipe",
    categories = {"crafting"},
    enabled = false,
    energy_required = 10.0,
    ingredients = {
      { type = "item", name = "stone-furnace", amount = 1 },
      { type = "item", name = "refined-crystal", amount = 10 },
      { type = "item", name = "steel-plate", amount = 5 },
    },
    results = {
      {type = "item", name = "crystal-furnace", amount = 1},
    },
  },
})
