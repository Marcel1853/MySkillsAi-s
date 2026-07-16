-- data.lua — Entry point for ALL prototype definitions
-- Prototypes are split into separate files for clarity and maintainability

-- Core prototypes (always loaded)
require("__crystal-tech__.prototypes.items")
require("__crystal-tech__.prototypes.recipes")
require("__crystal-tech__.prototypes.entities")
require("__crystal-tech__.prototypes.technologies")
require("__crystal-tech__.prototypes.fluids")

-- Space Age specific prototypes (only loaded if space-age is active)
if mods["space-age"] then
  require("__crystal-tech__.prototypes.space-age")
end
