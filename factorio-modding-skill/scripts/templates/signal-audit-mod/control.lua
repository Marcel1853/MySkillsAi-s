--- Signal-Prüfung für einen Spielstand (scripts/signal-audit.sh). Wird als Mod zu einem vorhandenen
--- Spielstand hinzugefügt: on_init läuft dann beim Laden. Nur lesen, nichts ändern.
--- Einstellungen schreibt das Script nach audit-config.lua ({ min_length, surface, area, limit }).
local Blocks = require("signal-blocks")
local ok, config = pcall(require, "audit-config")
config = ok and config or {}

local function where(sig)
  local p = sig.position
  return ("[gps=%.1f,%.1f,%s] Richtung %d"):format(p.x, p.y, sig.surface.name, sig.direction)
end

script.on_init(function()
  local limit = config.limit or 30
  for _, surface in pairs(game.surfaces) do
    if not config.surface or surface.name == config.surface then
      local r = Blocks.audit(surface, config.area, { min_length = config.min_length })
      if r.signals > 0 then
        log(("[SIGNALS] %s: %d Signale, %d normale vor einem Knoten (→ Kettensignal), %d Blöcke kürzer als %d, %d doppelt, %d nicht messbar (auf einer Weiche oder am Gleisende)")
          :format(surface.name, r.signals, #r.chain_in, #r.short, config.min_length or 35, #r.double, r.unmeasured))
        if r.unmeasured > 0 then log("[SIGNALS] nicht messbar: " .. serpent.line(r.why)) end
        for i, f in ipairs(r.chain_in) do if i <= limit then log("[SIGNALS] Kettensignal nötig: " .. where(f.signal)) end end
        for i, f in ipairs(r.short) do if i <= limit then log(("[SIGNALS] Block %.0f lang: %s"):format(f.length, where(f.signal))) end end
        for i, f in ipairs(r.double) do if i <= limit then log(("[SIGNALS] doppelt (%.0f): %s"):format(f.length, where(f.signal))) end end
      end
    end
  end
  log("[SIGNALS] fertig")
end)
