-- Screenshot-Helfer (nur mit Grafik, nie headless): wartet WAIT_SECONDS Spielzeit, arbeitet dann
-- die Liste STEPS ab – ein Schritt pro Sekunde – und schreibt am Ende shots/done.txt.
-- Regeln (teuer gelernt):
--   * take_screenshot rendert erst später → Fenster NICHT im selben Schritt schließen.
--   * Fenster über die Spielfigur öffnen (teleport + player.opened), nicht aus der Fernsicht.
--   * Unter das Motiv Gras legen (Labor-Boden sieht auf Werbebildern schlecht aus).
local SURFACE = "nauvis"       -- anpassen (z. B. Oberfläche eines Szenarios)
local WAIT_SECONDS = 60        -- Spielzeit, bis alles läuft (bei SPEED-facher Geschwindigkeit)
local SPEED = 4

local n = 0
local function player() return game.get_player(1) end
local function surface() return game.surfaces[SURFACE] end

local function grass(pos, rx, ry)
  local tiles = {}
  for x = math.floor(pos.x - rx), math.floor(pos.x + rx) do
    for y = math.floor(pos.y - ry), math.floor(pos.y + ry) do tiles[#tiles + 1] = { name = "grass-1", position = { x, y } } end
  end
  surface().set_tiles(tiles, true, false, true, false)
end

local function shot(name, position, zoom, gui)
  local p = player()
  n = n + 1
  game.take_screenshot({ player = p, by_player = p, surface = surface(), position = position, zoom = zoom,
    resolution = { 1920, 1080 }, show_gui = gui or false, show_entity_info = true, anti_alias = true,
    quality = 95, daytime = 0, path = ("shots/%02d-%s.jpg"):format(n, name) })
end

local function go(pos) -- Spielfigur neben das Motiv stellen
  local p = player()
  local target = surface().find_non_colliding_position("character", pos, 10, 0.5) or pos
  p.teleport(target, surface())
end

-- Schritte: jede Funktion ist ein Schritt (1 s Abstand). Beispiele – anpassen:
local function build_steps()
  local steps = {}
  local stop = surface().find_entities_filtered({ type = "train-stop", limit = 1 })[1]
  if stop then
    steps[#steps + 1] = function() grass(stop.position, 40, 24) end
    steps[#steps + 1] = function() shot("haltestelle", stop.position, 1.2) end
    steps[#steps + 1] = function() go(stop.position); player().opened = stop end
    steps[#steps + 1] = function() shot("fenster", player().position, 1, true) end
    steps[#steps + 1] = function() player().opened = nil end -- erst NACH dem Bild schließen
  end
  steps[#steps + 1] = function() helpers.write_file("shots/done.txt", "ok") end
  return steps
end

local waited, steps = 0, nil
script.on_nth_tick(60, function()
  if not (surface() and player() and player().character) then return end
  if not steps then
    waited = waited + 1
    if waited == 1 then game.speed = SPEED end
    if waited < WAIT_SECONDS then return end
    game.speed = 1
    steps = build_steps()
    return
  end
  local step = table.remove(steps, 1)
  if step then step() end
end)
