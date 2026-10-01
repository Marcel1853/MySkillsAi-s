-- prototypes/fluids.lua
-- Fluid prototypes for the crystal-tech mod

data:extend({
  {
    type = "fluid",
    name = "molten-crystal",
    icon = "__base__/graphics/icons/fluid/crude-oil.png",
    icon_size = 64,
    default_temperature = 500,
    max_temperature = 1000,
    heat_capacity = "0.5kJ",
    base_color = {r = 0.8, g = 0.2, b = 1.0},
    flow_color = {r = 1.0, g = 0.5, b = 1.0},
    order = "a[molten-crystal]",
  },
})
