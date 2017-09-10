local highLevelPirate = {}

local ship = require("ship")

local crit = 0.1
local dodge = 0.15
local armor = 1
local hp = 45

local HighLevelPirate = {}

function HighLevelPirate:new()
    print("New HighLevelPirate\n")
    local numAmmo = math.random(1, 2)
    local weapons = {}
    ship.getRandomGun(weapons)

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    o.shipType = "highLevelPirate"
    o.maxHp = hp
    return o
end

function highLevelPirate.newHighLevelPirate()
    return HighLevelPirate:new()
end

return highLevelPirate
