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

  -- Use event.item_stack.quality (LuaQualityPrototype) — recipe.products[].quality does NOT exist
  local item_stack = event.item_stack
  if not item_stack or not item_stack.valid_for_read then return end

  local quality = item_stack.quality  -- LuaQualityPrototype
  if quality and quality.name ~= "normal" then
    local player = game.get_player(event.player_index)
    if player and storage.quality_display.show_quality_alerts then
      player.print(string.format(
        "Crafted %s with quality: %s",
        item_stack.name,
        quality.name
      ))
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
    if selected.health then
      player.print(string.format(
        "  Health: %.0f/%.0f",
        selected.health,
        selected.max_health
      ))
    end
    -- selected.shield / selected.max_shield do NOT exist on LuaEntity;
    -- use selected.grid.shield / selected.grid.max_shield (equipment grid)
    if selected.grid then
      player.print(string.format(
        "  Shield: %.0f/%.0f",
        selected.grid.shield or 0,
        selected.grid.max_shield or 0
      ))
    end
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
