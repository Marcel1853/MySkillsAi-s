-- data-final-fixes.lua — Final prototype corrections

-- Make sure all our recipes have proper allow_productivity flags
if data.raw.recipe["crystal-processor-recipe"] then
  data.raw.recipe["crystal-processor-recipe"].allow_productivity = true
end
