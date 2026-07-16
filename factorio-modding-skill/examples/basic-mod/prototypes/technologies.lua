-- prototypes/technologies.lua
-- Technology prototypes for the crystal-tech mod

data:extend({
  {
    type = "technology",
    name = "crystal-processing",
    icon = "__crystal-tech__/graphics/technology/crystal-processing.png",
    icon_size = 256,
    effects = {
      {type = "unlock-recipe", recipe = "crystal-processor-recipe"},
      {type = "unlock-recipe", recipe = "melt-crystal"},
      {type = "unlock-recipe", recipe = "crystal-furnace-recipe"},
    },
    prerequisites = {"metallurgy", "automation"},
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30,
    },
    order = "z[crystal-processing]",
  },
})
