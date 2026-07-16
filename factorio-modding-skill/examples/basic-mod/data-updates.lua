-- data-updates.lua — Modify existing prototypes after all mods have defined theirs

-- Example: Increase assembling-machine-3 speed based on our startup setting
if data.raw["assembling-machine"]["assembling-machine-3"] then
  data.raw["assembling-machine"]["assembling-machine-3"].crafting_speed = 2.0
end

-- Example: Add module slots to labs (Space Age feature)
if data.raw.lab["lab"] then
  data.raw.lab["lab"].module_slots = 2
  data.raw.lab["lab"].allowed_module_categories = {"speed", "productivity"}
end
