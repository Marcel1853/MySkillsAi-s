-- settings.lua — Mod configuration options for crystal-tech

data:extend({
  -- Startup setting: affects prototype definitions
  {
    type = "bool-setting",
    name = "crystal-tech-enable-quantum",
    setting_type = "startup",
    default_value = false,
    order = "a",
  },

  -- Runtime setting: changeable during gameplay
  {
    type = "double-setting",
    name = "crystal-tech-furnace-speed",
    setting_type = "runtime",
    default_value = 2.0,
    minimum_value = 0.5,
    maximum_value = 10.0,
    order = "b",
  },
})
