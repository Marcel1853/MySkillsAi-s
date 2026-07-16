-- ============================================================
-- EXAMPLE: Custom GUI with Full Window
-- ============================================================
-- Demonstrates creating a custom GUI with tabs, buttons,
-- textfields, and event handling.
-- ============================================================

-- ===== GUI CREATION =====

local function create_main_gui(player)
  -- Remove existing GUI if present
  if player.gui.screen["mod-example-main"] then
    player.gui.screen["mod-example-main"].destroy()
  end

  -- Main frame
  local frame = player.gui.screen.add{
    type = "frame",
    name = "mod-example-main",
    direction = "vertical",
  }
  frame.auto_center = true
  frame.style.minimal_width = 500

  -- Titlebar
  local title_flow = frame.add{
    type = "flow",
    name = "titlebar",
    style = "frame_header_flow",
  }
  title_flow.add{
    type = "label",
    name = "title",
    caption = "Mod Example GUI",
    style = "frame_title",
  }
  title_flow.add{
    type = "empty-widget",
    name = "drag-space",
    style = "draggable_space",
    ignored_by_interaction = true,
    style_modifiers = {horizontally_stretchable = true},
  }
  title_flow.add{
    type = "sprite-button",
    name = "close-btn",
    sprite = "utility/close",
    style = "frame_action_button",
  }

  -- Tabbed pane
  local tabs = frame.add{
    type = "tabbed-pane",
    name = "tabbed-pane",
  }

  -- Tab 1: Status
  local status_tab = tabs.add{type = "tab", name = "status-tab", caption = "Status"}
  local status_content = tabs.add_tab(status_tab, "status-content")
  status_content.style.padding = 12
  status_content.style.vertical_spacing = 8

  status_content.add{
    type = "label",
    name = "info-label",
    caption = "Current tick: " .. game.tick,
    style = "bold_label",
  }

  local stats_table = status_content.add{
    type = "table",
    name = "stats-table",
    column_count = 2,
    style = "slot_table",
  }
  stats_table.add{type = "label", caption = "Entities tracked:"}
  stats_table.add{type = "label", caption = "0"}
  stats_table.add{type = "label", caption = "Builds today:"}
  stats_table.add{type = "label", caption = "0"}
  stats_table.add{type = "label", caption = "Surface:"}
  stats_table.add{type = "label", caption = player.surface.name}

  -- Tab 2: Controls
  local controls_tab = tabs.add{type = "tab", name = "controls-tab", caption = "Controls"}
  local controls_content = tabs.add_tab(controls_tab, "controls-content")
  controls_content.style.padding = 12
  controls_content.style.vertical_spacing = 8

  controls_content.add{
    type = "label",
    name = "controls-label",
    caption = "Configure the mod:",
    style = "bold_label",
  }

  -- Textfield for input
  controls_content.add{
    type = "textfield",
    name = "message-input",
    text = "Hello Factorio!",
  }

  -- Checkbox
  controls_content.add{
    type = "checkbox",
    name = "enable-notifications",
    caption = "Enable notifications",
    state = true,
  }

  -- Slider
  controls_content.add{
    type = "slider",
    name = "speed-slider",
    minimum_value = 1,
    maximum_value = 100,
    value = 50,
  }

  -- Action buttons
  local btn_flow = controls_content.add{
    type = "flow",
    name = "btn-flow",
    direction = "horizontal",
  }
  btn_flow.style.horizontal_spacing = 8

  btn_flow.add{
    type = "button",
    name = "send-btn",
    caption = "Send Message",
    style = "green_button",
  }
  btn_flow.add{
    type = "button",
    name = "clear-btn",
    caption = "Clear Log",
  }
  btn_flow.add{
    type = "button",
    name = "refresh-btn",
    caption = "Refresh Stats",
    style = "tool_button",
  }

  -- Tab 3: Item Browser
  local items_tab = tabs.add{type = "tab", name = "items-tab", caption = "Items"}
  local items_content = tabs.add_tab(items_tab, "items-content")
  items_content.style.padding = 12
  items_content.style.vertical_spacing = 8

  items_content.add{
    type = "label",
    name = "items-label",
    caption = "Select an item:",
    style = "bold_label",
  }

  -- Choose element button (item picker)
  items_content.add{
    type = "choose-elem-button",
    name = "item-chooser",
    elem_type = "item",
  }

  -- Item info display
  local info_frame = items_content.add{
    type = "frame",
    name = "info-frame",
    style = "inside_shallow_frame",
    direction = "vertical",
  }
  info_frame.style.padding = 8
  info_frame.add{
    type = "label",
    name = "item-info",
    caption = "Select an item to see its details.",
  }

  -- Dropdown for category
  items_content.add{
    type = "drop-down",
    name = "category-dropdown",
    items = {"All", "Raw Materials", "Intermediate", "Products", "Space"},
    selected_index = 1,
  }
end

-- ===== EVENT HANDLERS =====

-- Close button
script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "close-btn" then
    if event.element.parent then
      event.element.parent.destroy()
    end
  end
end)

-- Open GUI button (add to top bar)
script.on_init(function()
  for _, player in pairs(game.players) do
    player.gui.top.add{
      type = "sprite-button",
      name = "mod-example-open",
      sprite = "utility/build",
      tooltip = "Open Mod Example GUI",
    }
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "mod-example-open" then
    local player = game.get_player(event.player_index)
    if player then
      create_main_gui(player)
    end
  elseif event.element.name == "send-btn" then
    local player = game.get_player(event.player_index)
    if player and player.gui.screen["mod-example-main"] then
      local msg = player.gui.screen["mod-example-main"]["tabbed-pane"]["controls-content"]["message-input"].text
      player.print("Message sent: " .. msg)
    end
  elseif event.element.name == "clear-btn" then
    local player = game.get_player(event.player_index)
    if player and player.gui.screen["mod-example-main"] then
      player.gui.screen["mod-example-main"]["tabbed-pane"]["controls-content"]["message-input"].text = ""
    end
  elseif event.element.name == "refresh-btn" then
    local player = game.get_player(event.player_index)
    if player and player.gui.screen["mod-example-main"] then
      local info_label = player.gui.screen["mod-example-main"]["tabbed-pane"]["status-content"]["info-label"]
      info_label.caption = "Current tick: " .. game.tick .. " (refreshed)"
    end
  end
end)

-- Item chooser changed
script.on_event(defines.events.on_gui_elem_changed, function(event)
  if event.element.name == "item-chooser" then
    local player = game.get_player(event.player_index)
    if not player then return end
    local elem = event.element.elem_value
    if elem then
      local item_proto = prototypes.item[elem.name]
      if item_proto and player.gui.screen["mod-example-main"] then
        local info_label = player.gui.screen["mod-example-main"]["tabbed-pane"]["items-content"]["info-frame"]["item-info"]
        info_label.caption = item_proto.localised_name .. " (stack: " .. item_proto.stack_size .. ")"
      end
    end
  end
end)

-- New player joins
script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  if player then
    player.gui.top.add{
      type = "sprite-button",
      name = "mod-example-open",
      sprite = "utility/build",
      tooltip = "Open Mod Example GUI",
    }
  end
end)
