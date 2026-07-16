-- ============================================================
-- EXAMPLE: Quality System — Runtime Handling
-- ============================================================
-- Shows how to work with quality tiers at runtime.
-- Quality is a core 2.0 / Space Age feature that affects items,
-- entities, recipes, and more.
-- ============================================================

-- ===== QUALITY LEVELS =====
-- Built-in quality tiers:
-- 0 = Normal (default)
-- 1 = Uncommon (green)
-- 2 = Rare (blue)
-- 3 = Epic (purple)
-- 4 = Legendary (orange)

-- ===== QUALITY-AWARE ITEM CREATION =====

-- When creating items programmatically:
local function create_quality_item(item_name, quality, count)
  return {
    name = item_name,
    count = count,
    quality = quality,  -- "normal", "uncommon", "rare", "epic", "legendary"
  }
end

-- Insert a quality item into player inventory
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  -- Give the player a rare quality item
  player.insert(create_quality_item("iron-plate", "rare", 10))
end)

-- ===== QUALITY CHECKING =====

-- Check an entity's quality
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  if entity.quality then
    local quality_name = entity.quality
    local quality_level = prototypes.quality[quality_name].level

    if quality_level >= 3 then  -- Epic or better
      local player = game.get_player(event.player_index)
      if player then
        player.print("🌟 You built an " .. quality_name .. " " .. entity.name .. "!")
      end
    end
  end
end)

-- Check an item stack's quality
script.on_event(defines.events.on_player_crafted_item, function(event)
  local item_stack = event.item_stack
  if item_stack and item_stack.valid_for_read then
    local quality = item_stack.quality
    if quality and quality ~= "normal" then
      local player = game.get_player(event.player_index)
      if player then
        player.print("Crafted " .. quality .. " quality " .. item_stack.name .. "!")
      end
    end
  end
end)

-- ===== QUALITY MODIFIERS =====

-- Quality affects various entity stats
local function get_quality_bonus(entity)
  if not entity.quality then return 1.0 end
  local quality_proto = prototypes.quality[entity.quality]
  if not quality_proto then return 1.0 end

  -- Higher quality = better stats
  -- The exact bonus depends on the entity type
  local level = quality_proto.level
  return 1.0 + (level * 0.1)  -- 10% bonus per quality level
end

-- ===== QUALITY IN STORAGE =====

-- Track quality items in storage
script.on_init(function()
  storage.quality_stats = storage.quality_stats or {
    normal = 0,
    uncommon = 0,
    rare = 0,
    epic = 0,
    legendary = 0,
  }
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
  local item_stack = event.item_stack
  if item_stack and item_stack.valid_for_read then
    local quality = item_stack.quality or "normal"
    storage.quality_stats[quality] = (storage.quality_stats[quality] or 0) + item_stack.count
  end
end)

-- ===== QUALITY-AWARE RECIPES =====

-- Check if a recipe supports quality
local function recipe_supports_quality(recipe_name)
  local recipe_proto = prototypes.recipe[recipe_name]
  if recipe_proto then
    return recipe_proto.allow_quality or false
  end
  return false
end

-- ===== QUALITY MIGRATION =====

-- When updating a mod, handle quality changes
script.on_configuration_changed(function(event)
  if event.mod_changes["quality-examples"] then
    -- Migrate existing items to new quality system
    for _, player in pairs(game.players) do
      local inv = player.get_main_inventory()
      for i = 1, #inv do
        local stack = inv[i]
        if stack.valid_for_read and not stack.quality then
          -- Item was created before quality system existed
          -- Set it to normal quality
          stack.quality = "normal"
        end
      end
    end
  end
end)

-- ===== QUALITY IN GUI =====

-- Display quality info in a GUI element
local function show_quality_info(player, item_name)
  local proto = prototypes.item[item_name]
  if not proto then return end

  local qualities = {}
  for quality_name, quality_proto in pairs(prototypes.quality) do
    table.insert(qualities, {
      name = quality_name,
      level = quality_proto.level,
      icon = quality_proto.icon,
    })
  end

  -- Sort by level
  table.sort(qualities, function(a, b)
    return a.level < b.level
  end)

  -- Display to player
  player.print("Quality levels for " .. item_name .. ":")
  for _, q in ipairs(qualities) do
    player.print("  " .. q.name .. " (level " .. q.level .. ")")
  end
end

-- ===== QUALITY-DEPENDENT BEHAVIOR =====

-- Different behavior based on entity quality
script.on_event(defines.events.on_entity_damaged, function(event)
  local entity = event.entity
  if not entity or not entity.valid then return end

  -- Higher quality entities take less damage
  if entity.quality then
    local quality_proto = prototypes.quality[entity.quality]
    if quality_proto and quality_proto.level > 0 then
      local reduction = 1.0 - (quality_proto.level * 0.05)  -- 5% less per level
      -- Apply reduction (conceptual - actual damage is already applied)
      -- You could track this for statistics
    end
  end
end)
