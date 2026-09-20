-- 6x3 Tunnel-Graber mit Junk-Filter
-- Advanced Mining Turtle, CC:Tweaked
-- Graebt 6 breit x 3 hoch, wirft Junk-Bloecke weg, behaelt den Rest

-- ===== Konfiguration =====
local TUNNEL_WIDTH  = 6
local TUNNEL_HEIGHT = 3
local TUNNEL_LENGTH = 64
local FUEL_RESERVE  = 100

local junk = {
  ["minecraft:cobblestone"]       = true,
  ["minecraft:dirt"]              = true,
  ["minecraft:gravel"]            = true,
  ["minecraft:sand"]              = true,
  ["minecraft:stone"]             = true,
  ["minecraft:granite"]           = true,
  ["minecraft:diorite"]           = true,
  ["minecraft:andesite"]          = true,
  ["minecraft:cobbled_deepslate"] = true,
  ["minecraft:deepslate"]         = true,
  ["minecraft:tuff"]              = true,
  ["minecraft:netherrack"]        = true,
  ["minecraft:dripstone_block"]   = true,
}

-- ===== Hilfsfunktionen =====

local function checkFuel()
  if turtle.getFuelLevel() == "unlimited" then return true end
  if turtle.getFuelLevel() < FUEL_RESERVE then
    for slot = 1, 16 do
      turtle.select(slot)
      if turtle.refuel(1) then
        print("Nachgetankt aus Slot " .. slot)
        break
      end
    end
  end
  if turtle.getFuelLevel() < 1 then
    print("KEIN SPRIT! Bitte Brennstoff ins Inventar legen.")
    return false
  end
  return true
end

local function dropJunk()
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and junk[item.name] then
      turtle.select(slot)
      turtle.drop()
    end
  end
  turtle.select(1)
end

local function inventoryFull()
  for slot = 1, 16 do
    if turtle.getItemCount(slot) == 0 then
      return false
    end
  end
  return true
end

local function forward()
  while not turtle.forward() do
    turtle.dig()
    sleep(0.2)
  end
end

local function up()
  while not turtle.up() do
    turtle.digUp()
    sleep(0.2)
  end
end

local function down()
  while not turtle.down() do
    turtle.digDown()
    sleep(0.2)
  end
end

local function digForward()
  while turtle.detect() do
    turtle.dig()
    sleep(0.4)
  end
end

-- Eine Spalte in voller Hoehe graben: hoch arbeiten, dann zurueck runter
local function digColumn()
  digForward()
  for h = 1, TUNNEL_HEIGHT - 1 do
    up()
    digForward()
  end
  for h = 1, TUNNEL_HEIGHT - 1 do
    down()
  end
end

-- ===== Hauptprogramm =====

print("Starte " .. TUNNEL_WIDTH .. "x" .. TUNNEL_HEIGHT .. " Tunnel, Laenge " .. TUNNEL_LENGTH)
print("Sprit: " .. tostring(turtle.getFuelLevel()))

for length = 1, TUNNEL_LENGTH do

  if not checkFuel() then
    print("Abbruch: kein Sprit.")
    break
  end

  for w = 1, TUNNEL_WIDTH do
    digColumn()
    if w < TUNNEL_WIDTH then
      if w % 2 == 1 then
        turtle.turnRight()
        forward()
        turtle.turnLeft()
      else
        turtle.turnLeft()
        forward()
        turtle.turnRight()
      end
    end
  end

  -- zurueck zur Startseite der Scheibe (bei gerader Breite)
  if TUNNEL_WIDTH % 2 == 0 then
    turtle.turnLeft()
    for i = 1, TUNNEL_WIDTH - 1 do forward() end
    turtle.turnRight()
  end

  dropJunk()

  if inventoryFull() then
    print("Inventar voll - Pause. Leeren, dann Enter.")
    read()
  end

  forward()
  print("Scheibe " .. length .. "/" .. TUNNEL_LENGTH .. " fertig.")
end

print("Tunnel fertig!")
turtle.select(1)
