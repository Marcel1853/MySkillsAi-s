-- control.lua — Runtime scripting for crystal-tech mod

-- Initialize storage
script.on_init(function()
  storage.crystals_mined = storage.crystals_mined or 0
  storage.furnaces_built = storage.furnaces_built or 0
end)

-- Track crystal furnace builds
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  if entity.name == "crystal-furnace" then
    storage.furnaces_built = storage.furnaces_built + 1

    local player = game.get_player(event.player_index)
    if player then
      player.print("Crystal Furnace #" .. storage.furnaces_built .. " built!")
    end
  end
end, {{filter = "name", name = "crystal-furnace"}})

-- Configuration changed handler
script.on_configuration_changed(function(event)
  if event.mod_changes["crystal-tech"] then
    local old_ver = event.mod_changes["crystal-tech"].old_version
    if old_ver == nil then
      game.print("Crystal Tech mod added to your save!")
    else
      game.print("Crystal Tech updated from " .. old_ver .. " to " .. event.mod_changes["crystal-tech"].new_version)
    end
  end
end)
