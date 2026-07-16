-- prototypes/space-age.lua
-- Space Age specific prototypes (only loaded when space-age mod is active)

-- Quality-aware items
data:extend({
  {
    type = "item",
    name = "quantum-crystal",
    icon = "__crystal-tech__/graphics/icons/quantum-crystal.png",
    icon_size = 64,
    subgroup = "intermediate-product",
    order = "e[quantum-crystal]",
    stack_size = 50,
    weight = 100,
    random_quality_on_item_creation = "always",
    default_import_location = "fulgora",
  },
})

-- Quality-aware recipe
data:extend({
  {
    type = "recipe",
    name = "quantum-crystal-recipe",
    categories = {"crafting"},
    enabled = false,
    energy_required = 5.0,
    ingredients = {
      {"refined-crystal", 2},
      {"processing-unit", 1},
    },
    results = {
      {type = "item", name = "quantum-crystal", amount = 1, ignored_by_quality = {"quality"}},
    },
    allow_productivity = true,
    allow_quality = true,
  },
})
