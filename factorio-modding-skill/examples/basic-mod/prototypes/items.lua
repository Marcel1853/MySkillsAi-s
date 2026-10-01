-- prototypes/items.lua
-- Item prototypes for the crystal-tech mod

data:extend({
  -- Raw resource item
  {
    type = "item",
    name = "crystal-ore",
    icon = "__base__/graphics/icons/uranium-ore.png",
    icon_size = 64,
    subgroup = "raw-resource",
    order = "a[crystal-ore]",
    stack_size = 50,
    weight = 500,
  },

  -- Processed material
  {
    type = "item",
    name = "refined-crystal",
    icon = "__base__/graphics/icons/plastic-bar.png",
    icon_size = 64,
    subgroup = "raw-material",
    order = "b[refined-crystal]",
    stack_size = 100,
    weight = 200,
  },

  -- Final product
  {
    type = "item",
    name = "crystal-processor",
    icon = "__base__/graphics/icons/processing-unit.png",
    icon_size = 64,
    subgroup = "intermediate-product",
    order = "c[crystal-processor]",
    stack_size = 50,
    weight = 100,
  },

  -- Placeable entity item
  {
    type = "item",
    name = "crystal-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 64,
    subgroup = "smelting-machine",
    order = "d[crystal-furnace]",
    place_result = "crystal-furnace",
    stack_size = 10,
  },
})
