local pirate = {}

local ship = require("ship")

local crit = 0.05
local dodge = 0.1
local hp = 30

local function oneOrNone()
    local roll = math.random(0, 1)
    if roll == 1 then
        return 1
    else
        return 0
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

local Pirate = {}

function Pirate:new()
    print("New Pirate\n")
    local armor = oneOrNone()
    local numAmmo = oneOrNone()
    local weapons = {}
    getRandomGun(weapons)

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    o.shipType = "pirate"
    return o
end

function Pirate:addWeapon(weaponName)
    self.weapons[weaponName] = true
end

function pirate.newPirate()
    return Pirate:new()
end

return pirate