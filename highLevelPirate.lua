local highLevelPirate = {}

local ship = require("ship")

local crit = 0.1
local dodge = 0.15
local armor = 1
local hp = 45
local weapons = {standardCannon = true}

local function oneOrTwo()
    local roll = math.random(0, 1)
    if roll == 1 then
        return 2
    else
        return 1
    end
end

local function getRandomGun()
    local roll = math.random(1, 3)
    if roll == 1 then
        return "debuff"
    elseif roll == 2 then
        return "crit"
    elseif roll == 2 then
        return "pierce"
    end
end

local HighLevelPirate = {}

function HighLevelPirate:new()
    local numAmmo = oneOrTwo()
    weapons[getRandomGun()] = true

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    o.shipType = "highLevelPirate"
    return o
end

function HighLevelPirate:addWeapon(weaponName)
    self.weapons[weaponName] = true
end

function highLevelPirate.newHighLevelPirate()
    return HighLevelPirate:new()
end

return highLevelPirate
