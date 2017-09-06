local highLevelPirate = {}

local ship = require("ship")

local crit = 0.1
local dodge = 0.15
local armor = 1
local hp = 45

local function oneOrTwo()
    local roll = math.random(0, 1)
    if roll == 1 then
        return 2
    else
        return 1
    end
end

local function getRandomGun(weapons)
    local roll = math.random(0, 1)
    if roll == 0 then
        return
    else
        roll = math.random(1, 3)
        if roll == 1 then
            weapons["debuff"] = true
        elseif roll == 2 then
            weapons["crit"] = true
        elseif roll == 2 then
            weapons["pierce"] = true
        end
    end
end

local HighLevelPirate = {}

function HighLevelPirate:new()
    local numAmmo = oneOrTwo()
    local weapons = {}
    getRandomGun(weapons)

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    o.shipType = "highLevelPirate"
    return o
end

function highLevelPirate.newHighLevelPirate()
    return HighLevelPirate:new()
end

return highLevelPirate
