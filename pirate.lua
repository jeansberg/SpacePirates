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
  --  if roll == 0 then
  --      return nil
   -- else
        roll = math.random(1, 3)
        if roll == 1 then
            return "debuff"
        elseif roll == 2 then
            return "crit"
        elseif roll == 2 then
            return "pierce"
       -- end
    end
end

local Pirate = {}

function Pirate:new()
    local armor = oneOrNone()
    local numAmmo = oneOrNone()
    weapons[getRandomGun() or "standard"] = true

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