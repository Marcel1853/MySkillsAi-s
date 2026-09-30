--- Signale und Blöcke prüfen bzw. ausdünnen (Factorio 2.1, im Spiel geprüft).
---
--- Regeln (Kettensignal rein, normales Signal raus):
---   * Vor jeden Knoten (Weiche, Einmündung, Gleiskreuzung) ein Kettensignal.
---   * Hinter jeder Ausfahrt ein normales Signal; der Block dahinter soll den längsten Zug fassen
---     (Richtwert 7 Felder je Teil: Lok + 4 Wagen ≈ 35).
---   * Keine zwei Signale so dicht hintereinander, dass kein Wagen dazwischen passt.
---
--- API-Fakten (lua-api.factorio.com, LuaEntity):
---   * Ein Signal liegt zwischen zwei Segmenten. sig.get_connected_rails() liefert je nach Lage das
---     Gleis davor (dort: get_rail_segment_signal(dir, false) == sig, der Block beginnt am nächsten
---     Gleis) oder das dahinter (get_rail_segment_signal(dir, true) == sig) – beides prüfen.
---   * Ein Segment endet an Weichen, Signalen und Haltestellen; ein Block nur an Signalen.
---   * Weiche = mehr als ein Anschluss an einem Gleisende (get_connected_rail je Richtung);
---     Gleiskreuzung = rail.get_rail_segment_overlaps() nicht leer.
---   * Sitzt ein Signal genau auf einem Weichengleis, findet die Segment-Abfrage es nicht
---     (block_after liefert nil) – solche Signale zählt audit() als „nicht messbar“.
local Blocks = {}

local D = defines.rail_direction
local CONN = { defines.rail_connection_direction.left, defines.rail_connection_direction.straight,
  defines.rail_connection_direction.right }
Blocks.RAILS = { "straight-rail", "curved-rail-a", "curved-rail-b", "half-diagonal-rail",
  "elevated-straight-rail", "elevated-curved-rail-a", "elevated-curved-rail-b", "elevated-half-diagonal-rail" }
Blocks.SIGNALS = { "rail-signal", "rail-chain-signal" }

--- Weiche oder Gleiskreuzung an diesem Gleis?
function Blocks.is_junction(rail)
  for _, d in ipairs({ D.front, D.back }) do
    local n = 0
    for _, c in ipairs(CONN) do
      if rail.get_connected_rail({ rail_direction = d, rail_connection_direction = c }) then n = n + 1 end
    end
    if n > 1 then return true end
  end
  return #rail.get_rail_segment_overlaps() > 0
end

--- Gleise nach dem Ende des Segments von `rail` in Fahrtrichtung `dir`, je { Gleis, Richtung }.
local function step(rail, dir)
  local e, edir = rail.get_rail_segment_end(dir)
  local out = {}
  for _, c in ipairs(CONN) do
    local n = e.get_connected_rail({ rail_direction = edir, rail_connection_direction = c })
    if n then
      for _, x in ipairs({ D.front, D.back }) do
        for _, c2 in ipairs(CONN) do
          if n.get_connected_rail({ rail_direction = x, rail_connection_direction = c2 }) == e then
            out[#out + 1] = { n, x == D.front and D.back or D.front }
          end
        end
      end
    end
  end
  return out
end

--- Wo beginnt der Block hinter `sig`? Je nach Lage liefert get_connected_rails() das Gleis vor
--- dem Signal (dort ist es der Ausgang des Segments) oder das dahinter (dort ist es der Eingang).
--- Liefert Gleis, Richtung und true, wenn der Block schon auf diesem Gleis beginnt.
local function start_of(sig)
  for _, rail in pairs(sig.get_connected_rails()) do
    for _, d in ipairs({ D.front, D.back }) do
      local i = rail.get_rail_segment_signal(d, true)
      if i and i.unit_number == sig.unit_number then return rail, d, true end
    end
  end
  for _, rail in pairs(sig.get_connected_rails()) do
    for _, d in ipairs({ D.front, D.back }) do
      local o = rail.get_rail_segment_signal(d, false)
      if o and o.unit_number == sig.unit_number then return rail, d, false end
    end
  end
end

--- Block hinter `sig`: Länge, Signal am Ende und `junction` (Weiche/Kreuzung darin).
--- nil = nicht messbar (Signal sitzt auf einer Weiche) oder Gleis endet (Kartenrand).
--- Endet der Block an einer Weiche ohne erkennbares Signal, ist `last` nil und `junction` true.
---@param sig LuaEntity
---@return number? length
---@return LuaEntity? last
---@return boolean? junction
---@return string? why  Grund, wenn nicht messbar
function Blocks.block_after(sig)
  local rail, d, inside = start_of(sig)
  if not rail then return nil, nil, nil, "kein Gleis" end
  local r, dir = rail, d
  if not inside then
    local nexts = step(rail, d)
    if #nexts > 1 then return 0, nil, true end -- gleich hinter dem Signal eine Weiche
    if #nexts == 0 then return nil, nil, nil, "Gleisende" end
    r, dir = nexts[1][1], nexts[1][2]
  end
  local len, junction = 0, false
  for _ = 1, 200 do
    len = len + r.get_rail_segment_length()
    for _, x in pairs(r.get_rail_segment_rails(dir)) do
      if #x.get_rail_segment_overlaps() > 0 then junction = true end
    end
    local last = r.get_rail_segment_signal(dir, false)
    if last then return len, last, junction end
    local nexts = step(r, dir)
    if #nexts > 1 then return len, nil, true end
    if #nexts == 0 then return nil, nil, nil, "Gleisende" end
    r, dir = nexts[1][1], nexts[1][2]
  end
  return nil, nil, nil, "zu lang"
end

--- Alle Signale im Bereich prüfen. `opts.min_length` (35), `opts.min_gap` (7).
--- Liefert { chain_in = {…}, short = {…}, double = {…}, unmeasured = n, signals = n };
--- jeder Fund = { signal = LuaEntity, length = n? }.
---@param surface LuaSurface
---@param area BoundingBox?
---@param opts {min_length: number?, min_gap: number?}?
function Blocks.audit(surface, area, opts)
  opts = opts or {}
  local min_length, min_gap = opts.min_length or 35, opts.min_gap or 7
  local result = { chain_in = {}, short = {}, double = {}, unmeasured = 0, signals = 0, why = {} }
  -- normale Signale vor einem Block mit Weiche → sollten Kettensignale sein
  local seen = {}
  for _, rail in pairs(surface.find_entities_filtered({ area = area, type = Blocks.RAILS })) do
    if Blocks.is_junction(rail) then
      for _, sig in pairs(rail.get_inbound_signals()) do
        if sig.name == "rail-signal" and not seen[sig.unit_number] then
          seen[sig.unit_number] = true
          result.chain_in[#result.chain_in + 1] = { signal = sig }
        end
      end
    end
  end
  for _, sig in pairs(surface.find_entities_filtered({ area = area, type = Blocks.SIGNALS })) do
    result.signals = result.signals + 1
    local len, last, junction, why = Blocks.block_after(sig)
    if not len then
      result.unmeasured = result.unmeasured + 1
      local key = why or "?"
      result.why[key] = (result.why[key] or 0) + 1
    elseif not junction and last and len < min_gap then
      result.double[#result.double + 1] = { signal = sig, length = len }
    elseif sig.name == "rail-signal" and not junction and len < min_length then
      result.short[#result.short + 1] = { signal = sig, length = len }
    end
  end
  return result
end

--- Zu kurze Blöcke hinter normalen Signalen zusammenlegen: vom Anfang jeder Signalreihe in
--- Fahrtrichtung (sonst werden die Richtungen ungleich ausgedünnt). Entfernt nur normale Signale,
--- die keine Ausfahrt aus einem Knoten sind; `opts.keep(sig)` = true schützt weitere (z. B. fertige
--- Kreuzungen aus Blaupausen). Liefert die Zahl entfernter Signale.
---@param surface LuaSurface
---@param area BoundingBox?
---@param opts {min_length: number?, keep: (fun(sig: LuaEntity): boolean)?}?
function Blocks.fit(surface, area, opts)
  opts = opts or {}
  local min_length = opts.min_length or 35
  local keep = opts.keep or function(_) return false end
  local exits = {}
  for _, rail in pairs(surface.find_entities_filtered({ area = area, type = Blocks.RAILS })) do
    if Blocks.is_junction(rail) then
      for _, sig in pairs(rail.get_outbound_signals()) do exits[sig.unit_number] = true end
    end
  end
  local signals = surface.find_entities_filtered({ area = area, name = "rail-signal" })
  local reached = {}
  for _, sig in pairs(signals) do
    local _, last = Blocks.block_after(sig)
    if last and last.name == "rail-signal" then reached[last.unit_number] = true end
  end
  local removed = 0
  for _, start in pairs(signals) do
    local current = start.valid and not reached[start.unit_number] and start or nil
    for _ = 1, 100 do
      if not current then break end
      local len, last, junction = Blocks.block_after(current)
      if not len or junction then break end
      if not (last and last.valid) then break end
      if last.name == "rail-chain-signal" then
        -- kurz vor einer Einfahrt: das Signal selbst weg, wenn es keine Ausfahrt ist
        if len < min_length and not exits[current.unit_number] and not keep(current) then
          current.destroy()
          removed = removed + 1
        end
        break
      elseif len < min_length and not exits[last.unit_number] and not keep(last) then
        last.destroy() -- Block wird länger, gleich noch einmal messen
        removed = removed + 1
      else
        current = last
      end
    end
  end
  return removed
end

return Blocks
