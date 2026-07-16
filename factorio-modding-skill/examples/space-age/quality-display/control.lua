-- ============================================================
-- Quality Display — Factorio 2.1 Quality System Example
-- ============================================================
-- Demonstrates: Quality system, LuaEntity::quality,
-- force quality unlocking, quality effects
-- ============================================================

script.on_init(function()
  storage.quality_display = {
    enabled = true,
    show_quality_alerts = true
  }
end)

-- Notify player when they craft a quality item
script.on_event(defines.events.on_player_crafted_item, function(event)
  if not storage.quality_display or not storage.quality_display.enabled then return end

  local recipe = event.recipe
  if not recipe then return end

  -- Check if recipe produces quality items
  local results = recipe.products
  if results then
    for _, product in pairs(results) do
      if product.quality and product.quality.name ~= "normal" then
        local player = game.get_player(event.player_index)
        if player and storage.quality_display.show_quality_alerts then
          player.print(string.format(
            "Crafted %s with quality: %s",
            product.name,
            product.quality.name
          ))
        end
      end
    end
  end
end)

-- Custom command: check quality of selected entity
commands.add_command("check-quality", "Check the quality of the selected entity", function(command)
  local player = game.get_player(command.player_index)
  if not player then return end

  local selected = player.selected
  if not selected or not selected.valid then
    player.print("No entity selected.")
    return
  end

  local quality = selected.quality
  if quality then
    player.print(string.format(
      "Entity: %s | Quality: %s",
      selected.name,
      quality.name
    ))
    player.print(string.format(
      "  Health: %.0f/%.0f",
      selected.health,
      selected.max_health
    ))
    player.print(string.format(
      "  Shield: %.0f/%.0f",
      selected.shield or 0,
      selected.max_shield or 0
    ))
  else
    player.print("Entity has no quality: " .. selected.name)
  end
end)

-- Custom command: unlock quality
commands.add_command("unlock-quality", "Unlock a quality level for the player's force", function(command)
  local player = game.get_player(command.player_index)
  if not player then return end

  local quality_name = command.parameter
  if not quality_name then
    player.print("Usage: /unlock-quality <quality-name>")
    player.print("Available: normal, uncommon, rare, epic, legendary")
    return
  end

  local force = player.force
  if force then
    if force.is_quality_unlocked(quality_name) then
      player.print("Quality '" .. quality_name .. "' is already unlocked.")
    else
      force.unlock_quality(quality_name)
      player.print("Quality '" .. quality_name .. "' unlocked!")
    end
  end
end)
