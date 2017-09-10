local boss = {}

local ship = require("ship")

local crit = 0.25
local dodge = 0.2
local armor = 3
local hp = 120
local numAmmo = 8

local Boss = {}

function Boss:new()
    print("New Boss\n")
    local weapons = {"debuff", "crit", "pierce"}

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    o.shipType = "boss"
    o.maxHp = hp
    return o
end

function boss.newBoss()
    return Boss:new()
end

return boss
