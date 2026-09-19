-- Selbsttest-Vorlage: baut eine Testwelt, ruft die Mod über remote.call auf und loggt Ergebnisse.
-- Start mit scripts/headless-test.sh. Ergebnisse: „[SELFTEST] PASS/FAIL name -- info“.
local results = {}
local function check(name, ok, info)
  results[#results + 1] = (ok and "PASS " or "FAIL ") .. name .. (info and (" -- " .. tostring(info)) or "")
end

local st = {} -- Testzustand (nur in diesem Lauf, daher nicht in storage)
local done = false

script.on_nth_tick(10, function(e)
  if done then return end
  local s = game.surfaces["nauvis"]
  local force = game.forces["player"]
  if e.tick == 10 then
    s.request_to_generate_chunks({ 0, 0 }, 2)
    s.force_generate_chunk_requests()
    for _, ent in pairs(s.find_entities_filtered({ area = { { -30, -30 }, { 30, 30 } } })) do
      if ent.type ~= "character" then ent.destroy() end
    end
    -- Beispiel: Gleis + Haltestelle bauen (raise_built, damit die Mod das Bau-Event bekommt)
    for y = -20, 20, 2 do
      s.create_entity({ name = "straight-rail", position = { 1, y }, direction = defines.direction.north, force = force })
    end
    st.stop = s.create_entity({ name = "train-stop", position = { 3, 1 }, direction = defines.direction.north,
      force = force, raise_built = true })
    check("haltestelle gebaut", st.stop ~= nil)
    -- check("remote-interface da", remote.interfaces["my-mod"] ~= nil)
  elseif e.tick == 600 then
    -- Weitere Phasen: Zustand prüfen, nächste Aktion auslösen …
    check("haltestelle noch gültig", st.stop and st.stop.valid)
    done = true
    for _, r in ipairs(results) do log("[SELFTEST] " .. r) end
  end
end)
