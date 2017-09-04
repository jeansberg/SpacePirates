local pirate = {}

local ship = require("ship")

local crit = 0.05
local dodge = 0.1
local hp = 30
local weapons = {standardCannon = true}

local function oneOrNone()
    local roll = math.random(0, 1)
    if roll == 1 then
        return 1
    else
        return 0
    end
end

local function getRandomGun()
    local roll = math.random(0, 1)
    if roll == 0 then
        return nil
    else
        roll = math.random(1, 3)
        if roll == 1 then
            return "debuffCannon"
        elseif roll == 2 then
            return "critCannon"
        elseif roll == 2 then
            return "pierceCannon"
        end
    end
end

local Pirate = {}

function Pirate:new()
    local armor = oneOrNone()
    local numAmmo = oneOrNone()
    weapons[getRandomGun() or "standardCannon"] = true

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Pirate:addWeapon(weaponName)
    self.weapons[weaponName] = true
end

function pirate.newPirate()
    return Pirate:new()
end

return pirate