-- migrations/2.0.0.lua
-- Runs once when updating from a version < 2.0.0

-- Unlock new technology for all existing forces
for _, force in pairs(game.forces) do
  if force.technologies["crystal-processing"] then
    force.technologies["crystal-processing"].researched = true
  end
end

-- Migrate storage data from old format
if storage.old_furnace_count then
  storage.furnaces_built = storage.old_furnace_count
  storage.old_furnace_count = nil
end

game.print("Crystal Tech 2.0.0 migration complete!")
